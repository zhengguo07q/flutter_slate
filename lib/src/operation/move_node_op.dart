import 'package:slate/slate.dart';
import 'package:common/common.dart';
import 'package:dartx/dartx.dart';

import '../location/range.dart' as interfaces;

class MoveNodeOperation extends Operation {
  MoveNodeOperation({required this.path, required this.newPath});

  @override
  String toString() {
    return 'MoveNodeOperation{path: $path, newPath: $newPath}';
  }

  late Path path;
  late Path newPath;

  @override
  Operation inverse() {
    // PERF:在这种情况下移动操作是一个空操作。
    if (newPath.equals(path)) {
      return this;
    }

    // 如果移动完全发生在一个父路径中，路径和newPath相对于彼此是稳定的。
    if (path.isSibling(newPath)) {
      return MoveNodeOperation(path: newPath, newPath: path);
    }

    // 如果移动没有在单个父节点中发生，那么移动可能会影响到节点被移除和被插入位置的真实路径。
    // 我们必须对此进行调整并找到原始路径。
    // 我们可以通过查看移动操作对原始移动路径之后的节点的影响来实现这一点(仅在非同级移动中)。
    final inversePath = transformPath(path)!;
    final inverseNewPath = transformPath(path.next())!;
    return MoveNodeOperation(path: inversePath, newPath: inverseNewPath);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    final op = this.path;
    final onp = newPath;

    // 操作路径没用变化，直接返回
    if (op.equals(onp)) {
      return null;
    }

    if (op.isAncestor(pathCp) || op.equals(pathCp)) {
      final copy = Path(onp.sublist(0));

      if (op.endsBefore(onp) && op.length < onp.length) {
        copy[op.length - 1] -= 1;
      }

      return copy..addAll(pathCp.slice(op.length));
    } else if (op.isSibling(onp) &&
        (onp.isAncestor(pathCp) || onp.equals(pathCp))) {
      if (op.endsBefore(pathCp)) {
        pathCp[op.length - 1] -= 1;
      } else {
        pathCp[op.length - 1] += 1;
      }
    } else if (onp.endsBefore(pathCp) ||
        onp.equals(pathCp) ||
        onp.isAncestor(pathCp)) {
      if (op.endsBefore(pathCp)) {
        pathCp[op.length - 1] -= 1;
      }

      pathCp[onp.length - 1] += 1;
    } else if (op.endsBefore(pathCp)) {
      if (onp.equals(pathCp)) {
        pathCp[onp.length - 1] += 1;
      }

      pathCp[op.length - 1] -= 1;
    }
    return pathCp;
  }

  /// 通过操作变换一个点。
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    pointCp.path = transformPath(pointCp.path, affinity: affinity)!;
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    if (path.equals(newPath)) {
      return [];
    }

    final oldAncestors = <Path>[];
    final newAncestors = <Path>[];

    for (final ancestor in path.ancestors()) {
      final p = transformPath(ancestor) ?? Path.ofNull();
      oldAncestors.add(p);
    }

    for (final ancestor in newPath.ancestors()) {
      final p = transformPath(ancestor) ?? Path.ofNull();
      newAncestors.add(p);
    }

    final newParent = newAncestors[newAncestors.length - 1];
    final newIndex = newPath[newPath.length - 1];
    final resultPath = Path.of(newParent.followedBy([newIndex]));

    return [...oldAncestors, ...newAncestors, resultPath];
  }

  @override
  List<DirtyNode> getDirtyNodes(Document document) {
    final dirtyNodes = <DirtyNode>[];
    // 原来节点要删除
    final srcTopNode = document.get(path.top());
    if(path.length == 1){
      dirtyNodes.add(DirtyNode(srcTopNode, DirtyType.delete));
      final srcParentNode = SlateCache.getCacheNode(srcTopNode.kParentId);
      dirtyNodes.add(DirtyNode(srcParentNode!, DirtyType.update));
    }else{
      dirtyNodes.add(DirtyNode(srcTopNode, DirtyType.update));
    }
    // 目的节点
    final destTopNode = document.get(path.top());
    if(newPath.length == 1){
      dirtyNodes.add(DirtyNode(destTopNode, DirtyType.insert));
      final destParentNode = SlateCache.getCacheNode(destTopNode.kParentId);
      dirtyNodes.add(DirtyNode(destParentNode!, DirtyType.update));
    }else{
      dirtyNodes.add(DirtyNode(destTopNode, DirtyType.update));
    }

    return dirtyNodes;
  }

  @override
  interfaces.Range? apply(Document document, interfaces.Range? selection) {
    assert(path.isAncestor(newPath) == false,
        'Cannot move a path [$path] to new path [$newPath] because the destination is inside itself.');

    final node = document.get(path);
    final parent = document.parent(path);
    final index = path[path.length - 1];

    // 这是棘手的
    // 但由于' path '和' newPath '都指的是同一时间的快照，这是不匹配的。
    // 在移除原始位置之后，第二步的路径可能会过期。
    // 我们不用op。newPath，我们直接转换op。以确定应用操作后的newPath是什么。
    parent.children.removeAt(index);
    final truePath = transformPath(path)!;
    final newParent = document.get(truePath.parent());
    final newIndex = truePath[truePath.length - 1];

    newParent.children.insert(newIndex, node);

    AppLogger.slateLog.i("移动节点操作， 把节点$node  从$path路径删除，并添加到 新路径$truePath 节点新位置$newIndex");
    setSelection(selection, this);
    return selection;
  }
}
