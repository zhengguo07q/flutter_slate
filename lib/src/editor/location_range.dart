import 'package:slate/slate.dart';

class LocationRange{

  /// 修正悬停范围，游览器的这种范围选择，会把最后一个位置选到下一个节点中， 这个在文档中是需要被修正的。
  ///
  /// “悬挂”范围是由浏览器的“三次单击”选择行为创建的。
  /// 当三次单击一个块时，浏览器会从该块的开头选择到下一个块的开头。
  /// 因此，该范围“悬停”到下一个块中。如果unhangRange给定了这样的范围，它将向后移动末端，直到它位于悬挂块之前的非空文本节点中。
  /// 请注意，它unhangRange是为修复三次单击的块而设计的，因此目前有许多警告：
  ///   它不修改范围的开始；只有结束。
  ///   例如，它不会“取消挂起”从前一个块的末尾开始的选择。
  ///   只有在开始块被完全选中时它才会做任何事情。
  ///   例如，它不处理通过双击段落结尾创建的范围（浏览器通过选择从该段落的结尾到下一个段落的开头来处理）
  /// <single>content</single><extension><focus></extension> =><single>content<focus></single><extension></extension>
  static Range unhangRange(Document document, Range range,
      {bool voids = false}) {
    // 取范围的两个边界
    final rangeEdge = range.edges();
    final start = rangeEdge.start;
    var end = rangeEdge.end;
    // PERF：如果我们能保证范围不在边界上，就退出。
    // 这里只要有一个满足就退出, 就是说只要有任意一个位在文本中, 则就退出.
    if (start.offset != 0 || end.offset != 0 || range.isCollapsed()) {
      return range;
    }

    // 结束的块
    final endBlock = LocationPathEntry.above(
      document,
      at: end,
      match: ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!),
    );
    final blockPath = endBlock != null ? endBlock.path : Path.ofNull();
    // 整个文档的第一个点到结束的点
    final first = LocationPoint.start(document, Path.ofNull());
    final before = Range(anchor: first, focus: end);

    // 计算结束的点
    // 从给定区域的结束位置开始到整个文档的第一个点遍历，
    var skip = true;
    for (final nodeEntry in LocationPathEntry.nodes(
      document,
      at: before,
      match: ({Node? node, Path? path}) => KText.isText(node!),
      reverse: true,
      voids: voids,
    )) {
      final node = nodeEntry.node;
      final path = nodeEntry.path;
      // 跳过最后一个块
      if (skip) {
        skip = false;
        continue;
      }
      // 找到一个存在文本内容的节点，并且确定这个节点是在之前定义的end的前面。
      if (node.text != '' || path.isBefore(blockPath)) {
        end = Point(path: path, offset: node.text!.length);
        break;
      }
    }

    return Range(anchor: start, focus: end);
  }


  /// 获取位置的开始和结束点。
  static List<Point> edges(Document document, Location at) {
    return [LocationPoint.start(document, at), LocationPoint.end(document, at)];
  }


  /// 获取一个位置范围。
  static Range range(Document document, Location at, {Location? to}) {
    if (at is Range && to == null) {
      return at;
    }

    final start = LocationPoint.start(document, at);
    final end = LocationPoint.end(document, to ?? at);
    return Range(anchor: start, focus: end);
  }
}