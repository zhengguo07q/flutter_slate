import '../../slate.dart';

mixin TestSupport on Document{
  //测试用
  static const String tagBlock = 'extension';
  static const String tagInline = 'inline';

  @override
  void initialize() {
    super.initialize();
  }

  // @override
  // bool isInline(Node node){
  //   if(node.type == tagInline) {
  //     return true;
  //   }
  //   return super.isInline(node);
  // }
  //
  // /// 是否为void节点
  // ///
  // /// 默认为false
  // @override
  // bool isVoid(Node node){
  //   if(node.attributes.containsKey('void')) {
  //     return true;
  //   }
  //   return super.isVoid(node);
  // }
}