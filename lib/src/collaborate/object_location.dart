import 'package:slate/slate.dart';
import 'package:crdt/crdt.dart';

class SyncNodeParent {
  SyncNodeParent(this.node, this.index);

  late dynamic node;
  late int index;
}

class SyncPathParent{
  SyncPathParent(this.path, this.index);
  late Path path;
  late int index;
}

bool isTree(dynamic node) => SyncNodeHelper.getChildren(node) != null;

/// 通过路径查找到需要的yjs子节点
dynamic getTarget(TypeArray<SyncNode> doc, Path path) {
  dynamic iterate(dynamic current, int idx) {
    final children = SyncNodeHelper.getChildren(current);
    final child = children?.get(idx);
    if (child == null) {
      throw UnsupportedError(
          'path ${path.toString()} does not match doc ${ObjectConvert.toSlateDoc(doc)}');
    }
    return child;
  }

  dynamic next = doc;
  for (final idx in path) {
    next = iterate(next, idx);
  }
  return next;
}

///获得父路径和索引位置
///
/// [level] 回退的级别
SyncPathParent getParentPath(Path path, {int level = 1}) {
  assert(level <= path.length, 'requested ancestor is higher than root');
  return SyncPathParent(
       Path.of(path.sublist(0, path.length - level)),
       path[path.length - level]);
}

/// 获得父对象和它在父对象中的偏移
SyncNodeParent getParent(TypeArray<SyncNode> doc, Path path, {int level = 1}) {
  final point = getParentPath(path, level: level);
  final dynamic parent = getTarget(doc, point.path);
  assert(parent != null, 'Parent node should exists');
  return SyncNodeParent(parent, point.index);
}

/// 返回同步项在其父数组中的位置。
int getArrayPosition(StructItem item) {
  var i = 0;
  var c = (item.parent as TypeArray<SyncNode>).innerStart;

  while (c != item && c != null) {
    if (!c.deleted) {
      i += 1;
    }
    c = c.right;
  }

  return i;
}

/// 返回同步数据的文档路径
Path getSyncNodePath(dynamic node) {
  assert(node.runtimeType == TypeMap || node.runtimeType == TypeArray);

  if (node == null) {
    return Path.ofNull();
  }

  final dynamic parent = node.parent;
  if (parent == null) {
    return Path.ofNull();
  }

  if (parent is TypeArray) {
    assert(node.innerItem != null, 'Parent should be associated with a item');
    return Path.of(getSyncNodePath(parent as SyncNodeHelper)
      ..add(getArrayPosition(node.innerItem as StructItem)));
  }

  if (parent is TypeMap) {
    return getSyncNodePath(parent as SyncNodeHelper);
  }

  throw UnsupportedError('Unknown parent type $parent');
}


