import 'package:slate/slate.dart';

class ElementType {
  static const String tagLine = 'line';
  static const String tagBlock = 'block';

  static const String tagSingle = 'single';
}

/// [KElement]对象是Slate文档中的一种节点类型，它包含其他元素节点或文本节点。
/// 它们可以是block或inline，这取决于Slate编辑器的配置。
class KElement {
  /// 是否为行内节点
  ///
  /// 默认为false
  static bool isInline(Node node) {
    // if (node.type == ElementType.tagLine) {
    //   return true;
    // }
    return false;
  }


  /// 是否为void节点
  ///
  /// 默认为false
  static bool isVoid(Node node) => false;

  static bool isEditor(Node value) {
    return SlateCache.isEditorCache.get(value) ?? false;
  }

  /// 检查一个值是否实现了'Ancestor'接口。
  static bool isAncestor(Node value) {
    return Node.isNodeList(value.children);
  }

  /// 检查一个值是否实现了' Element '接口。
  static bool isElement(Node value) {
    return Node.isNodeList(value.children) &&
        !KText.isText(value) &&
        !EditorCondition.isEditor(value);
  }

  /// 检查一个值是否为“Element”对象的数组。
  static bool isElementList(List<Node> value) {
    return value.every(KElement.isElement);
  }

  /// 检查一组属性是否是Element的一部分。
  static bool isElementProps(dynamic props) {
    return false;
  }

  static bool matches(Node element, Map<String, String> props) {
    var ret = false;
    props.forEach((key, value) {
      if (element.attributes[key] != value) {
        ret = false;
      }
      ret = true;
    });
    return ret;
  }
}
