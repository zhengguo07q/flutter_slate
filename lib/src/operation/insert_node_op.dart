import 'package:slate/slate.dart';
import 'package:common/common.dart';


/// 插入节点操作
///
/// 路径影响: 插入操作影响到插入后面的节点的路径
/// 节点影响: 如果是顶级的节点, 就是思维导图节点, 影响插入节点, 影响关联节点
class InsertNodeOperation extends Operation {
  InsertNodeOperation({required this.path, required this.node});

  late Path path;
  // 插入的节点
  late Node node;

  @override
  String toString() {
    return 'InsertNodeOperation{path: $path, node: $node}';
  }

  /// 反转插入变为删除
  @override
  Operation inverse() {
    return RemoveNodeOperation(path: path, node: node);
  }

  /// 插入之后，如果之前影响到的路径(一般是选区) 是同一个或者在后面或者是子对象， 则影响到的路径后移一位
  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    // 空的路径不需要处理, 脏路径最顶层节点可能为[]
    if(path.isEmpty){
      return null;
    }

    final op = this.path;
    if (op.equals(pathCp) || // 相同
        op.endsBefore(pathCp) || // 相同父节点之前
        op.isAncestor(pathCp)) { // 是第二个的祖先, 原先占位被挤占, 祖先位置也向后偏移
      //子节点
      pathCp[op.length - 1] += 1; // 把需要变换的节点向后移一位, 原来的位置被占据了
    }
    return pathCp;
  }

  /// 变换一个点， 只需要变换路径
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    pointCp.path = transformPath(pointCp.path, affinity:  affinity)!;
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    final levels = path.levels();
    final descendants = KText.isText(node)
        ? <Path>[]
        : List<Path>.from(node.nodes()
        .map<Path>((PathEntry entry) => Path.of(path.followedBy(entry.path))));
    return [...levels, ...descendants];
  }

  @override
  List<DirtyNode> getDirtyNodes(Document document) {
    final dirtyNodes = <DirtyNode>[];
    final topPath = path.top();
    final topNode = document.get(topPath);

    // 只有顶级插入才会建立关系
    if(path.length == 1){
      dirtyNodes.add(DirtyNode(topNode, DirtyType.insert));
      // 同时对父节点保存更新
      final parentNode = SlateCache.getCacheNode(topNode.kParentId);
      dirtyNodes.add(DirtyNode(parentNode!, DirtyType.update));
    }else{
      dirtyNodes.add(DirtyNode(topNode, DirtyType.update));
    }
    return dirtyNodes;
  }

  @override
  Range? apply(Document document, Range? selection) {
    // 需要插入的位置的休息父节点
    final parent = document.parent(path);
    // 需要插入的位置
    final index = path.last;

    assert(index <= parent.children.length,
        'Cannot apply an "insert_node" operation at path [$path] because the destination is past the end of the node.');

    // 插入
    parent.children.insert(index, node);

    AppLogger.slateLog.i("插入元素节点操作, 插入父节点$node  插入位置$index  插入节点$node");
    // 把光标设置在相关的选区的位置
    setSelection(selection, this);
    return null;
  }
}
