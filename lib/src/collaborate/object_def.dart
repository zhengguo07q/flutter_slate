import 'package:crdt/crdt.dart';
import 'package:slate/slate.dart';


/// [YMap] => [Node]
/// 在YJS里代表节点
class SyncNode extends TypeMap<dynamic> {
  static final attrNameType = 'type';
  static final attrNameChildren = 'children';
  static final attrNameText = 'single';
  static final attrNodeAttributes = 'attributes';

  SyncNode({TypeMap? map}) : super(map?.entries());

  factory SyncNode.from(Node node) {
    final syncNode = SyncNode();
    // children
    if (KElement.isElement(node)) {
      // 把转化子节点转化为YArray数组，迭代调用这个转化
      final childElements = node.children.map((childNode)=>SyncNode.from(childNode)).toList();
      final childContainer = TypeArray<dynamic>();
      childContainer.insert(0, childElements);

      // 设置转化结果到自身
      syncNode.kChildren = childContainer;
    }
    // single
    if (KText.isText(node)) {
      // 直接封装成为YText
      final textElement = TypeText(node.text);
      syncNode.kText = textElement;
    }

    // type
    if(node.type != null){
      syncNode.kType = node.type;
    }

    // attributes
    node.attributes.forEach((key, Attribute value) {
      // 其他属性直接设置到当前这个对象里
      final stringValue = AttributeUtil.convertTToString(key, value);
      syncNode.set(key, stringValue);
    });

    return syncNode;
  }

  Node to(){
    final children = this.kChildren;
    final text = this.kText;
    final type = this.kType;

    final node = Node();
    // children
    if (children != null) {
      node.children = children.map((child) {
        return (child as SyncNode).to();
      }).toList();
    }
    // single
    if (text != null) {
      node.text = text.toString();
    }
    // type
    if(type != null){
      node.type = type;
    }

    // attributes
    this.entries().forEach((element) {
      final key = element.key;
      final stringValue = element.value;
      if(excludeAttrName(key) == false){
        final convertValue = AttributeUtil.convertStringToT(key, stringValue);
        node.attributes[key] = Attribute.fromKeyValue(key, convertValue)!;
      }
    });
    return node;
  }

  bool excludeAttrName(String attrName){
    if(attrName == attrNameChildren
        || attrName == attrNameText
        || attrName == attrNameType){
      return true;
    }
    return false;
  }

  set kText(TypeText? value) {
    this.set(attrNameText, value);
  }

  TypeText? get kText {
    return this.get(attrNameText);
  }

  set kType(String? value) {
    this.set(attrNameType, value);
  }

  String? get kType {
    return this.get(attrNameType);
  }

  set kChildren(TypeArray<dynamic>? value) {
    this.set(attrNameChildren, value);
  }

  TypeArray<dynamic>? get kChildren {
    return this.get(attrNameChildren);
  }

  set kAttribute(TypeArray<SyncNode>? value) {
    this.set(attrNodeAttributes, value);
  }

  /// 属性基本上就是排除掉其他三种后剩下的数据
  TypeArray<SyncNode> get kAttribute{
    return this.get(attrNodeAttributes);
  }

  SyncNode kClone() {
    final text = this.kText;
    final children = this.kChildren;

    final clone = SyncNode();
    if (text != null) {
      final textElement = TypeText(text.toString());
      clone.set(SyncNode.attrNameText, textElement);
    }

    if (children != null) {
      final childElements = children.map((child) {
        return (child as SyncNode).kClone();
      });
      final childContainer = TypeArray<SyncNode>();
      childContainer.insert(0, childElements.toList());
      clone.set(SyncNode.attrNameChildren, childContainer);
    }

    this.entries().forEach((element) {
      final key = element.key;
      final dynamic value = element.value;
      if (key != SyncNode.attrNameChildren &&
          key != SyncNode.attrNameText ) {
        clone.set(key, value);
      }
    });

    return clone;
  }
}

/// 用来排除掉持有的对象外面的结构数组
class SyncNodeHelper {
  static TypeArray<dynamic>? getChildren(dynamic node) {
    if (node is TypeArray) {
      return node;
    }

    return (node as SyncNode).kChildren;
  }

  static TypeText? getText(dynamic node) {
    if (node is TypeArray) {
      return null;
    }

    return (node as SyncNode).kText;
  }
}
