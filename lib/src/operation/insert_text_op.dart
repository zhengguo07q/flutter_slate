import 'package:slate/slate.dart';
import 'package:common/common.dart';

/// 插入文本操作
///
/// 插入只影响到之前的point, 如果是相同的节点, 需要检查文本偏移是否有变化
class InsertTextOperation extends Operation {
  InsertTextOperation(
      {required this.path, required this.offset, required this.text});

  late Path path;
  //插入的偏移
  late int offset;

  // 需要插入的文本
  late String text;

  @override
  String toString() {
    return 'InsertTextOperation{path: $path, offset: $offset, single: $text}';
  }

  /// 反转删除文本
  @override
  Operation inverse() {
    return RemoveTextOperation(path: path, offset: offset, text: text);
  }

  ///
  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    return path.copy();
  }

  /// 通过操作变换一个点。
  ///
  /// 插入文本的时候路径没用变化，位置如果是<插入的位置，向后移动文本偏移
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    if (path.equals(pointCp.path) && offset <= pointCp.offset) {
      // 移动文本偏移
      pointCp.offset += text.length;
    }
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    return path.levels();
  }

  @override
  Range? apply(Document document, Range? selection) {
    // 文本长度不为0 时插入
    if (text.isNotEmpty) {
      // 取这个插入的叶子节点。每个节点通过normal后一定有一个叶子节点也就是文本节点
      final node = document.leaf(path);
      // 把之前的文本分成两段
      final before = node.text!.substring(0, offset);
      final after = node.text!.substring(offset);
      // 组合文本
      node.text = before + text + after;

      AppLogger.slateLog.i("插入文本操作 插入文本$text  插入文本节点$node  插入位置$offset  插入后文本$node.part");
      setSelection(selection, this);
    }
    return selection;
  }
}
