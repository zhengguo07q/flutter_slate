import 'package:quiver/core.dart';

import 'attribute_define.dart';

enum AttributeScope {
  block,
  inline,
  embeds,
  ignore,
  mindmap,     // 思维导图
  document,      // 文档
}

class Attribute<T> {
  Attribute(this.key, this.scope, this.value);

  final String key;
  final AttributeScope scope;
  final T value;

  bool get isInline => scope == AttributeScope.inline;

  bool get isBlockExceptHeader =>
      AttributeRegister.blockKeysExceptHeader.contains(key);

  Map<String, dynamic> toJson() => <String, dynamic>{key: value};

  static Attribute? fromKeyValue(String key, dynamic value) {
    final origin = AttributeRegister.registry[key];
    if (origin == null) {
      return null;
    }
    final attribute = clone(origin, value);
    return attribute;
  }

  static int getRegistryOrder(Attribute attribute) {
    var order = 0;
    for (final attr in AttributeRegister.registry.values) {
      if (attr.key == attribute.key) {
        break;
      }
      order++;
    }

    return order;
  }

  static Attribute clone(Attribute origin, dynamic value) {
    return Attribute(origin.key, origin.scope, value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attribute) return false;
    final typedOther = other;
    return key == typedOther.key &&
        scope == typedOther.scope &&
        value == typedOther.value;
  }

  @override
  int get hashCode => hash3(key, scope, value);

  @override
  String toString() {
    return 'Attribute{key: $key, scope: $scope, value: $value}';
  }
}
