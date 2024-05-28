import 'package:slate/slate.dart';
import 'package:common/common.dart';

/// 删除节点
///
/// 删除节点可能会删除选区所在的位置, 需要重新调整选区
/// 调整的方式为, 如果可以直接转换, 则说明没有影响到原来的选择, 只是影响到了里面的内容
/// 如果不能调整, 则说明直接删除了选区的位置, 这个时候就需要查找到当前删除的位置, 默认情况下吧选区定位在新删除的节点的前面
/// 如果不存在前面空间, 则定位在删除后的第一个节点的开头
class RemoveNodeOperation extends Operation {
  RemoveNodeOperation({required this.path, required this.node});

  late Path path;

  late Node node;

  @override
  Operation inverse() {
    return InsertNodeOperation(path: path, node: node);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    final op = this.path;

    if (op.equals(pathCp) || op.isAncestor(pathCp)) {
      // 相等与, 删除节点是原来的祖先, 则代表这个节点不存在了, 返回null
      return null;
    } else if (op.endsBefore(pathCp)) {
      // 如果删除的节点根变化的节点是同一层, 需要把这个受影响的节点向前移动一位
      pathCp[op.length - 1] -= 1;
    }
    return pathCp;
  }

  /// 通过操作变换一个点。
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    // 与路径相同或祖先，这个点不存在了
    if (path.equals(pointCp.path) ||
        path.isAncestor(pointCp.path)) {
      return null;
    }

    pointCp.path = transformPath(pointCp.path, affinity: affinity)!;
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    final ancestors = path.ancestors();
    return [...ancestors];
  }


  @override
  String toString() {
    return 'RemoveNodeOperation{path: $path, node: $node}';
  }

  @override
  Range? apply(Document document, Range? selection) {
    // 删除掉这个节点
    final index = path.last;
    final parent = document.parent(path);
    parent.children.removeAt(index);
    AppLogger.slateLog.i('删除节点操作，删除路径$path, 节点$node');
    // 转换选区定位的点，但如果点在节点被删除，我们需要更新范围或删除它。
    if (selection != null) {
      for (final pointEntry in selection.points()) {
        final point = pointEntry.point;
        final result = transformPoint(pointEntry.point);

        if (result != null) {
          // 选择出来的两个位置点可以直接转换, 那么说明没有删除这两个位置, 可以直接设置新的选区
          if (pointEntry.position == 'anchor') {
            selection!.anchor = result;
          } else if (pointEntry.position == 'focus') {
            selection!.focus = result;
          }
        } else {
          // 不能直接抓换, 说明这两个位置已经被删除, 则需要重新进行定位新的位置
          PathEntry? prev;
          PathEntry? next;

          // 找到新的位置
          for (final nodeEntry in document.texts()) {
            final n = nodeEntry.node;
            final p = nodeEntry.path;
            if (p.compare(path) == -1) {
              // 当前遍历出的路径p在删除的路径的前面, 作为默认的前一个路径
              prev = PathEntry(n, p);
            } else {
              // 相等或者在后面, 说明找到了相关对象, 作为后一个路径, 并且退出遍历
              next = PathEntry(n, p);
              break;
            }
          }

          // 优选前一个作为新的位置, 不然则使用后一个的第一个空间位
          if (prev != null) {
            point
              ..path = prev.path
              ..offset = prev.node.text!.length;
          } else if (next != null) {
            point
              ..path = next.path
              ..offset = 0;
          } else {
            selection = null;
          }
        }
      }
    }
    return selection;
  }
}
