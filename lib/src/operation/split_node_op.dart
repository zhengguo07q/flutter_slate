import 'package:slate/slate.dart';
import 'package:common/common.dart';

/// 分割节点操作
class SplitNodeOperation extends Operation {
  SplitNodeOperation(
      {required this.path, required this.position, required this.attributes});
  // 需要被分割的节点
  late Path path;
  // 需要被分割的位置
  late int position;
  // 这个节点的属性
  late Map<String, Attribute> attributes;

  /// 合并节点
  @override
  Operation inverse() {
    return MergeNodeOperation(
        path: path.next(), position: position, properties: attributes);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    final op = this.path;

    if (op.equals(pathCp)) {
      // 这两个路径一样
      if (affinity == Affinity.forward) {
        pathCp[pathCp.length - 1] += 1;
      } else if (affinity == Affinity.backward) {
        // Nothing, because it still refers to the right path.
      } else {
        return null;
      }
    } else if (op.endsBefore(pathCp)) {
      // 操作路径在处理路径的前面
      pathCp[op.length - 1] += 1;
    } else if (op.isAncestor(pathCp) && path[op.length] >= position) {
      // 操作路径是当前路径的祖先
      pathCp[op.length - 1] += 1;
      pathCp[op.length] -= position;
    }
    return pathCp;
  }

  /// 通过操作变换一个点。
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    if (path.equals(pointCp.path)) {
      if (position == pointCp.offset && affinity == null) {
        return null;
      } else if (position < pointCp.offset ||
          (position == pointCp.offset && affinity == Affinity.forward)) {
        pointCp
          ..offset -= position
          ..path = transformPath(pointCp.path, affinity: Affinity.forward)!; // 强制向前，这样都需要节点位置向后+1
      }
    } else {
      pointCp.path = transformPath(pointCp.path, affinity: affinity)!;
    }
    return pointCp;
  }

  /// 路径下所有路径和下一个路径
  @override
  List<Path> getDirtyPaths() {
    final levels = path.levels();
    final nextPath = path.next();
    return [...levels, nextPath];
  }

  @override
  Range? apply(Document document, Range? selection) {
    assert(path.isNotEmpty,
        'Cannot apply a "split_node" operation at path [$path] because the root node cannot be split.');
    // 需要被分割的节点
    final node = document.get(path);
    // 需要被分割的节点的父节点
    final parent = document.parent(path);
    // 这个需要被分割的节点的索引位置, 未来新的节点要插在这个节点后面
    final index = path.last;
    // 新的节点
    Node newNode;

    if (KText.isText(node)) {
      // 需要被分割的节点是文本节点
      // 把文本分割成为两个文本。位置之前的保留在原来的节点。位置之后的创建一个新的节点
      final before = node.text!.substring(0, position);
      final after = node.text!.substring(position);
      node.text = before;
      newNode = Node(
          attributes: attributes
              .map<String, Attribute>((key, value) => MapEntry(key, value)),
          text: after);
      AppLogger.slateLog.i("分割文本节点操作, 分割节点$node 分割位置$position, 添加新后节点 $newNode 插入到${index + 1}");
    } else {
      // 把需要被分割的按照索引做成两个节点
      final before = node.children.sublist(0, position);
      final after = node.children.sublist(position);
      node.children = before;
      newNode = Node(
          attributes: attributes
              .map<String, Attribute>((key, value) => MapEntry(key, value)),
          children: after);
      AppLogger.slateLog.i("分割元素节点操作, 分割节点$node  位置$position, 添加新后节点 $newNode 插入到${index + 1}");
    }

    // 把新创建的节点添加到原来的位置
    parent.children.insert(index + 1, newNode);

    setSelection(selection, this);
    return selection;
  }
}
