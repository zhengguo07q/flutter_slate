import 'package:slate/src/utils/weak_map.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../../slate.dart';

class ConvertXml2Node {
  static WeakMap<Node, int> focusCache = WeakMap();
  static WeakMap<Node, int> anchorCache = WeakMap();

  static const String tagText = 'part';
  static const String tagBlock = 'extension';
  static const String tagInline = 'inline';
  static const String tagCursor = 'cursor';
  static const String tagFocus = 'focus';
  static const String tagAnchor = 'anchor';

  static const String attrId = 'id';
  static const String attrChildrenIds = 'cIds';
  static const String attrParentId = 'pid';

  /// 用于打印
  static XmlDocument parse(String xmlString) {
    final xmlStringPrep = prepareXmlString(xmlString);
    return XmlDocument.parse(xmlStringPrep);
  }

  /// 转换xml数据到节点
  static DocumentRoot toNodeDocument(String xmlString) {
    final xml2Node = _Xml2Node();
    final document = xml2Node.transform(parse(xmlString));
    return document;
  }

  /// 把字符串转换成为节点
  static Node toNode(String xmlString) {
    final xml2Node = _Xml2Node();
    final node = xml2Node.transformNode(parse(xmlString));
    return node;
  }

  /// 转换节点数据到xml
  static XmlElement toXmlElement(Node documentNode) {
    final node2Xml = _Node2Xml();
    final document = node2Xml.transform(documentNode);
    return document;
  }
}

class _Xml2Node {
  void checkTagName(XmlElement element, Node node) {
    if (element.name.local == ConvertXml2Node.tagText) {
      node.text = '';
    }
  }

  /// 通过属性名，判断是否为顶级元素
  bool checkTopElementByAttrName(XmlElement element, Node node, String attrName){
    if(attrName == ConvertXml2Node.attrId || attrName == ConvertXml2Node.attrChildrenIds || attrName == ConvertXml2Node.attrParentId){
      return true;
    }
    return false;
  }

  /// 如果节点没有标记为文本，则都需要添加新节点
  bool _isNewNode(XmlText xmlText) {
    final parent = xmlText.parentElement;
      if (parent!.name.local != ConvertXml2Node.tagText) return true;
    return false;
  }

  /// 处理文本类节点
  Node _handlerText(dynamic xmlNode, Node objNode) {
    final sanitisedNodeData = escapeTextForJson(xmlNode.text as String);
    // 每一个XML内部的文本节点，如果没有标记为text类型，则都要转化为独立的节点
    if (_isNewNode(xmlNode as XmlText)) {
      //父对象是块的时候，需要添加为新的节点
      final p = Node()..text = sanitisedNodeData;
      objNode.children.add(p);
      return p;
    } else {
      objNode.text = sanitisedNodeData;
      return objNode;
    }
  }

  bool _isElementExtension(XmlElement xmlElement) {
    if (xmlElement.name.local == ConvertXml2Node.tagCursor ||
        xmlElement.name.local == ConvertXml2Node.tagFocus ||
        xmlElement.name.local == ConvertXml2Node.tagAnchor) {
      return true;
    }
    return false;
  }

  /// 处理其他元素扩展信息
  String? _handlerElementExtension(XmlElement xmlElement, Node objNode) {
    final previousElement = xmlElement.previousSibling;
    final nextSiblingElement = xmlElement.nextSibling;
    if (previousElement != null &&
        previousElement.nodeType == XmlNodeType.TEXT) {
      // 在文本节点里面
      Node textNode;
      if (objNode.children.isNotEmpty) {
        textNode = objNode.children.last;
      } else {
        textNode = objNode;
      }
      final xmlText = previousElement as XmlText;
      final offset = escapeTextForJson(xmlText.text).length;
      _settingExtension(xmlElement.name.local, textNode, offset);
    } else if (previousElement == null && nextSiblingElement == null) {
      // 前后都没用内容，创建一个空白的节点加进去
      final blankNode = Node(text: '');
      objNode.children.add(blankNode);
      _settingExtension(xmlElement.name.local, blankNode, 0);
    } else {
      return xmlElement.name.local;
    }
    return null;
  }

  void _settingExtension(String extension, Node node, int offset) {
    if (extension == ConvertXml2Node.tagAnchor) {
      ConvertXml2Node.anchorCache[node] = offset;
    } else if (extension == ConvertXml2Node.tagFocus) {
      ConvertXml2Node.focusCache[node] = offset;
    } else if (extension == ConvertXml2Node.tagCursor) {
      ConvertXml2Node.focusCache[node] = offset;
      ConvertXml2Node.anchorCache[node] = offset;
    }
  }

  /// 处理普通的元素信息
  Node _handlerElement(XmlElement xmlElement, Node document) {
    final newNode = Node()..type = xmlElement.name.toString();
    checkTagName(xmlElement, newNode);
    for (final attr in xmlElement.attributes) {
      final attrKey = attr.name.qualified;
      final attrValue = escapeTextForJson(getRawTextAttrValue(attr.value));

      // if(checkTopElementByAttrName(xmlElement, newNode, attrKey)){
      //   if(newNode.nodeGraph == null){
      //     newNode.nodeGraph = NodeGraph();
      //   }
      // }
      // // 特殊处理
      // if (attrKey == ConvertXml2Node.attrId) {
      //   newNode.nodeGraph!.id = attrValue;
      // } else if (attrKey == ConvertXml2Node.attrChildrenIds) {
      //   newNode.nodeGraph!.childrenIds = attrValue.split(',');
      // } else if (attrKey == ConvertXml2Node.attrParentId) {
      //   newNode.nodeGraph!.parentId = attrValue;
      // } else {
        newNode.attributes[attrKey] = Attribute.fromKeyValue(attrKey, attrValue)!;
   //   }
    }

    document.children.add(newNode);
    return newNode;
  }

  /// 获得纯文本属性值
  String getRawTextAttrValue(String attrValue) {
    if (attrValue.startsWith('"') && attrValue.endsWith('"')) {
      attrValue = attrValue.substring(1, attrValue.length - 1);
    }
    return attrValue;
  }

  void _transform(XmlNode node, Node document) {
    String? postExtension; //说明位置在最文本最前面，延后处理

    void _process(XmlNode _xmlNode, Node _document) {
      if (_xmlNode is XmlText) {
        final textNode = _handlerText(_xmlNode, _document);
        if (postExtension != null) {
          _settingExtension(postExtension!, textNode, 0);
          postExtension = null;
        }
        // xml name == cursor / focus / anchor
      } else if (_xmlNode is XmlElement && _isElementExtension(_xmlNode)) {
        postExtension = _handlerElementExtension(_xmlNode, _document);
        // standard xml
      } else if (_xmlNode is XmlElement) {
        final p = _handlerElement(_xmlNode, _document);
        for (var j = 0; j < _xmlNode.children.length; j++) {
          _process(
            _xmlNode.children[j],
            p,
          );
        }
      }
    }

    // 设置文档节点类型 为document
    document.type = (node as XmlElement).name.toString();
    for (final xmlNode in node.children) {
      _process(xmlNode, document);
    }
    // print(document);
  }

  /// 转换成为documentRoot
  DocumentRoot transform(XmlDocument? xmlNode) {
    final document = DocumentRoot();
    try {
      _transform(xmlNode!.firstChild!, document);
      final selection = Range.ofNull();
      final textEntryIter = document.texts();
      for (final textEntry in textEntryIter) {
        final anchorOffset = ConvertXml2Node.anchorCache[textEntry.node];
        if (anchorOffset != null) {
          selection.anchor.path = textEntry.path.copy();
          selection.anchor.offset = anchorOffset;
        }
        final focusOffset = ConvertXml2Node.focusCache[textEntry.node];
        if (focusOffset != null) {
          selection.focus.path = textEntry.path.copy();
          selection.focus.offset = focusOffset;
        }
      }
      if (selection != Range.ofNull()) {
        document.selection = selection;
      }
    } on Exception catch (e) {
      throw Xml2JsonException(
          'JSX internal transform error => ${e.toString()}');
    }
    return document;
  }

  /// 转换成为documentRoot
  Node transformNode(XmlDocument? xmlNode) {
    final node = Node();
    try {
      _transform(xmlNode!.firstChild!, node);
    } on Exception catch (e) {
      throw Xml2JsonException(
          'JSX internal transform error => ${e.toString()}');
    }
    return node;
  }
}

/// 先去除空格，再去除尾部的回车换行
String escapeTextForJson(String text) {
  var text1 = text.trim();
  text1 = text1.endsWith('\n') ? text1.substring(0, text1.length - 1) : text1;
  text1 = text1.replaceAll('\n', '\\\\n');
  text1 = text1.replaceAll(r'\', r'\\');
  text1 = text1.replaceAll(r'"', r'\"');
  text1 = text1.replaceAll('\r', '\\\\r');
  text1 = text1.replaceAll('\t', '\\\\t');
  text1 = text1.replaceAll('\b', '\\\\f');
  return text1;
}

String prepareXmlString(String xmlString) {
  var xmlString1 = xmlString.trim();
  xmlString1 = xmlString1.replaceAll('>\n', '>');
  final regex = RegExp(r'>\s*<');
  return xmlString1 = xmlString1.replaceAll(regex, '><');
}

class _Node2Xml {
  XmlElement _transform(Node node) {
    void _process(Node node, XmlElement parentXmlElement) {
      if (node.children.isNotEmpty || node.type != null || node.text != null) {
        //存在类型名需要构建成xml标签
        XmlElement element;
        if (node.text != null) {
          element = XmlElement(XmlName('text'));
        } else {
          element = XmlElement(XmlName(node.type!));
        }
        parentXmlElement.children.add(element);

        addAttributeText(node, element);
        for (final childNode in node.children) {
          _process(childNode, element);
        }
      } else if (KText.isText(node)) {
        addAttributeText(node, parentXmlElement);
      }
    }

    final element = XmlElement(XmlName(node.type ?? 'part'));
    for (final childNode in node.children) {
      _process(childNode, element);
    }
    addAttributeText(node, element);
    return element;
  }

  void addAttributeText(Node node, XmlElement element) {
    node.attributes.forEach((key, Attribute value) {
      final valueStr = value.value?.toString();
      final xmlAttribute = XmlAttribute(XmlName(key), valueStr??'');
      element.attributes.add(xmlAttribute);
    });

    if (node.text != null) {
      element.innerText = node.text!;
    }
  }

  XmlElement transform(Node documentNode) {
    XmlElement xmlDoc;
    try {
      xmlDoc = _transform(documentNode);
    } on Exception catch (e) {
      throw Xml2JsonException(
          'JSX internal transform error => ${e.toString()}');
    }
    return xmlDoc;
  }
}
