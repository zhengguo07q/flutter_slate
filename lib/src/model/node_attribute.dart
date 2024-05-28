import '../../slate.dart';
import 'package:dartx/dartx.dart' as dartx;
import 'package:quiver/collection.dart';

class NodeAttribute {
  NodeAttribute({
    this.type,
    this.text,
    List<Node>? children,
    Map<String, Attribute>? attributes,
  }) {
    this.children = children ?? [];
    this.attributes = attributes ?? <String, Attribute>{};
  }
  /// 节点类型
  late String? type;

  late String? text;

  late List<Node> children;

  late Map<String, Attribute> attributes;

  bool get containsId{
    return attributes.containsKey(AttributeRegister.id.key);
  }

  /// 检查是否包含属性KEY
  ///
  /// 这个函数的目的是确保调用获得属性的时候，必定存在属性， 去掉空判断。
  bool containsAttributeKey(String attrKey){
    return attributes.containsKey(attrKey);
  }

  Attribute getAttribute(String attrKey, {required Attribute defaultValue}){
    return attributes.getOrElse(attrKey, () => defaultValue);
  }

  String get kId {
    assert(attributes.containsKey(AttributeRegister.id.key));
    return attributes[AttributeRegister.id.key]!.value;
  }
  set kId(String? value){
    if(value != null){
      attributes[AttributeRegister.id.key] = IdAttribute(value);
    }
  }

  /// 只要调用，则需要保证这个节点一定是由父节点ID的
  String get kParentId {
    assert(attributes.keys.contains(AttributeRegister.parentId.key));
    return attributes[AttributeRegister.parentId.key]!.value;
  }
  set kParentId(String? value){
    if(value != null){
      attributes[AttributeRegister.parentId.key] = ParentIdAttribute(value);
    }
  }
  Node? get parentNode{
    return SlateCache.getCacheNode(kParentId);
  }

  List<String>? get kChildrenIds {
    if (attributes.keys.contains(AttributeRegister.childrenIds.key)) {
      return attributes[AttributeRegister.childrenIds.key]?.value;
    }
    return null;
  }

  set kChildrenIds(List<String>? value){
    if(value != null){
        attributes[AttributeRegister.childrenIds.key] = ChildrenIdsAttribute(value);
    }
  }
  static String attrChildrenIdsTransform(List<String> value){
    return value.join(',');
  }

  bool get isEmpty => children.isEmpty;

  /// 这个比较只是用在比较这两个对象纯属性
  ///
  /// 不对 == 和 hashcode 进行重写，避免系统级调用的时候进行很大规模的比较
  bool equals(Object other) {
    if (identical(this, other) ||
        other is Node &&
            type == other.type &&
            text == other.text &&
            //    nodeCache == other.nodeCache &&
            listsEqual(children, other.children) &&
            mapsEqual(attributes, other.attributes)) return true;
    return false;
  }

  Node clone() {
    final node = Node()
      ..type = type
      ..text = text;
    for (final element in children) {
      node.children.add(element.clone());
    }
    attributes.forEach((key, value) {
      node.attributes[key] = value;
    });
    return node;
  }

  @override
  String toString() {
    return ConvertXml2Node.toXmlElement(this as Node).toXmlString();
  }

}
