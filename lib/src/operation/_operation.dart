import 'package:slate/slate.dart';

import '../location/path_ref.dart';
import '../location/point_ref.dart';
import '../location/range_ref.dart';

enum DirtyType {
  insert,
  delete,
  update,
  select,
}

class DirtyNode {
  DirtyNode(this.node, this.dirtyType);
  Node node;
  DirtyType dirtyType;
}

/// [Operation]对象定义了底层指令，Slate编辑器使用这些指令来对其内部状态进行更改。
/// 将所有更改表示为操作使得Slate编辑器可以轻松地实现历史记录、协作和其他特性。
///
/// 所有的转换操作返回的都是全新的对象， 会被赋给原来需要被赋的地方
abstract class Operation {
  List<PathRef>? debugTransformPathList;
  List<PointRef>? debugTransformPointList;
  List<RangeRef>? debugTransformRangeList;

  Operation(){
    assert(() {
      debugTransformPathList = [];
      debugTransformPointList = [];
      debugTransformRangeList = [];
      return true;
    }());
  }

  Path? get path;

  Operation inverse() {
    throw UnimplementedError();
  }

  /// 变化路径
  ///
  /// 一般只有节点操作才会影响到路径变化
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    throw UnimplementedError();
  }

  /// 通过操作变换一个点。
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.inward}) {
    final pointCp = point.copy();
    return pointCp;
  }

  /// 范围是两个点的转换[transformPoint]
  Range? transformRange(Range range, {Affinity? affinity = Affinity.inward}) {
    Affinity? affinityAnchor;
    Affinity? affinityFocus;

    if (affinity == Affinity.inward) {
      if (range.isForward()) {
        //向前拖拽， 锚点在后面，焦点在前面， 锚点向前，焦点向后
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      } else {
        // 向后拖拽， 锚点在前，焦点在后，向前
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      }
    } else if (affinity == Affinity.outward) {
      if (range.isForward()) {
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      } else {
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      }
    } else {
      affinityAnchor = affinity;
      affinityFocus = affinity;
    }

    final anchor = transformPoint(range.anchor, affinity: affinityAnchor);
    final focus = transformPoint(range.focus, affinity: affinityFocus);

    if (anchor == null || focus == null) {
      return null;
    }

    return Range(anchor: anchor, focus: focus);
  }

  List<Path> getDirtyPaths() {
    throw UnimplementedError();
  }

  /// 默认情况下的脏节点，都只是更新当前这个节点
  ///
  /// 只有当插入和
  List<DirtyNode> getDirtyNodes(Document document) {
    final dirtyNodes = <DirtyNode>[];
    if (path == null) {
      return dirtyNodes;
    }
    final topNode = document.get(path!.top());
    dirtyNodes.add(DirtyNode(topNode, DirtyType.update));
    return dirtyNodes;
  }

  Range? apply(Document document, Range? selection) {
    throw UnimplementedError();
  }

  /// 检查一个值是一个[NodeOperation]对象。
  static bool isNodeOperation(Operation value) {
    return value is InsertNodeOperation ||
        value is MergeNodeOperation ||
        value is MoveNodeOperation ||
        value is RemoveNodeOperation ||
        value is SplitNodeOperation ||
        value is SetNodeOperation;
  }

  /// 值的检查是一个[SetSelectionOperation]对象。
  static bool isSelectionOperation(dynamic value) {
    return value is SetSelectionOperation;
  }

  /// 检查一个值是[InsertTextOperation]对象。
  static bool isTextOperation(dynamic value) {
    return value is InsertTextOperation || value is RemoveTextOperation;
  }
}

void setSelection(Range? selection, Operation op) {
  if (selection != null) {
    for (final pointEntry in selection.points()) {
      final point = pointEntry.point;
      if (pointEntry.position == 'anchor') {
        selection.anchor = op.transformPoint(point)!;
      } else if (pointEntry.position == 'focus') {
        selection.focus = op.transformPoint(point)!;
      }
    }
  }
}
