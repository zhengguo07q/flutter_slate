import 'package:slate/slate.dart';

/// “编辑器”界面存储了Slate编辑器的所有状态。
///
/// 它由插件扩展，这些插件希望添加自己的助手并实现新的行为。
class EditorContent {
  /// 获取一个位置的文本字符串内容。
  ///
  /// 注意:默认情况下，void属性节点的文本被认为是一个空字符串，无论内容如何，除非你为void选项传入true
  static String string(Document document, Location at, {bool voids = false}) {
    // 提取给定区域的两个边界
    final range = LocationRange.range(document, at);
    final rangeEdge = range.edges();
    final start = rangeEdge.start;
    final end = rangeEdge.end;
    final text = StringBuffer();

    // 找出里面的所有文本
    for (final nodeEntry in LocationPathEntry.nodes(
      document,
      at: range,
      match: ({Node? node, Path? path}) => KText.isText(node!),
      voids: voids,
    )) {
      final node = nodeEntry.node;
      final path = nodeEntry.path;
      var t = node.text!;

      // 提取结束
      if (path.equals(end.path)) {
        t = t.substring(0, end.offset);
      }

      // 提取开头
      if (path.equals(start.path)) {
        t = t.substring(start.offset);
      }

      // 其他全部提取
      text.write(t);
    }

    return text.toString();
  }
}
