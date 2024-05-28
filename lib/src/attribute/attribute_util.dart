import 'attribute_define.dart';

import 'attribute.dart';

class AttributeUtil {
  /// 获得给定集合里[BlocksExceptHeader]的集合
  static Map<String, Attribute> getBlocksExceptHeader(
      Map<String, Attribute> attributes) {
    final m = <String, Attribute>{};
    attributes.forEach((key, value) {
      if (AttributeRegister.blockKeysExceptHeader.contains(key)) {
        final attribute = Attribute.fromKeyValue(key, value);
        m[key] = attribute!;
      }
    });
    return m;
  }

  static dynamic convertStringToT(String key, String value){
    if(key == AttributeRegister.childrenIds.key){
      if(value == ''){
        return <String>[];
      }
      return value.split(',');
    }
    return value;
  }

  static String convertTToString(String key, Attribute attribute){
    final value = attribute.value;
    if(key == AttributeRegister.childrenIds.key){
      return (value as List<String>).join(',');
    }
    if(value is String){
      return value;
    }
    return value.toString();
  }
}
