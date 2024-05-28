import 'package:slate/slate.dart';


/// 取消位置上节点上的属性。
///
/// 直接调用设置相关节点属性为null
void nodeUnsetNodes(Document document, dynamic prop,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool split = false,
    bool voids = false}) {
  late List<String> props;
  if (prop is List<String>) {
    props = prop;
  } else if (prop is String) {
    props = <String>[prop];
  }

  final obj = <String, Attribute?>{};

  for (final key in props) {
    obj[key] = null;
  }

  NodeTransforms.setNodes(document, obj,
      atl: atl, match: match, mode: mode, split: split, voids: voids);
}
