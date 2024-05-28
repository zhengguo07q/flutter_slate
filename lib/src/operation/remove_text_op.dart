import 'dart:math' as math;
import 'package:common/common.dart';

import 'package:slate/slate.dart';

/// 删除文本
///
/// 删除只影响到之前的point, 如果是相同的节点, 需要检查文本偏移是否有变化
class RemoveTextOperation extends Operation {
  RemoveTextOperation(
      {required this.path, required this.offset, required this.text});

  late Path path;
  late int offset;
  late String text;

  @override
  String toString() {
    return 'RemoveTextOperation{path: $path, offset: $offset, single: $text}';
  }

  @override
  Operation inverse() {
    return InsertTextOperation(path: path, offset: offset, text: text);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    return pathCp;
  }

  /// 通过操作变换一个点。
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    if (path.equals(pointCp.path) && offset <= pointCp.offset) {
      pointCp.offset -= math.min(pointCp.offset - offset, text.length);
    }
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    return path.levels();
  }


  @override
  Range? apply(Document document, Range? selection) {
    if (text.isNotEmpty) {
      final node = document.leaf(path);
      final before = node.text!.substring(0, offset);
      final after = node.text!.substring(offset + text.length);

      AppLogger.slateLog.i("删除节点内部文档操作, $node, 删除之前: ${node.text} 删除之后: ${before + after}");

      node.text = before + after;
      setSelection(selection, this);
    }
    return selection;
  }
}
