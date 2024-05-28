import 'package:slate/slate.dart';
import 'package:common/common.dart';

/// 合并节点操作
///
/// 把当前路径所代表的节点向前合并
class MergeNodeOperation extends Operation {
  MergeNodeOperation(
      {required this.path, required this.position, required this.properties});

  late Path path;
  // 合并的位置, 这个如果前一个子节点是元素节点，则是这个元素节点里孩子的长度，也就是未来合并的节点要放入的节点
  late int position;
  // 属性
  late Map<String, Attribute> properties;

  /// 分割
  @override
  Operation inverse() {
    return SplitNodeOperation(
        path: path.previous(), position: position, attributes: properties);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if(path.isEmpty){
      return null;
    }

    final op = this.path;

    // 合并之后需要同位置向前位移一位
    if (op.equals(pathCp) || op.endsBefore(pathCp)) {
      pathCp[op.length - 1] -= 1;
    } else if (op.isAncestor(pathCp)) {
      pathCp[op.length - 1] -= 1;
      pathCp[op.length] += position;
    }
    return pathCp;
  }

  /// 通过操作变换一个点。
  @override
  Point? transformPoint(Point point, {Affinity? affinity = Affinity.forward}) {
    final pointCp = point.copy();
    // 偏移需要加上追加后的位置长度
    if (path.equals(pointCp.path)) {
      pointCp.offset += position;
    }

    pointCp.path = transformPath(pointCp.path, affinity: affinity)!;
    return pointCp;
  }

  @override
  List<Path> getDirtyPaths() {
    final ancestors = path.ancestors();
    final previousPath = path.previous();
    return [...ancestors, previousPath];
  }


  @override
  Range? apply(Document document, Range? selection) {
    // 需要合并的节点
    final node = document.get(path);
    final prevPath = path.previous();
    // 需要合并的节点的前一个节点
    final prev = document.get(prevPath);
    // 需要合并的节点的父节点
    final parent = document.parent(path);
    // 当前节点的索引位置
    final index = path[path.length - 1];

    if (KText.isText(node) && KText.isText(prev)) {
      // 合并的这两个节点都是文本节点, 则这两个节点文本追加到第一个节点里去
      prev.text = prev.text! + node.text!;
      AppLogger.slateLog.i("合并文本节点操作 前一个文本${prev.text}  后一个文本${node.text} 删除原来的${index}位置");
    } else if (!KText.isText(node) && !KText.isText(prev)) {
      // 合并的这两个节点都不是文本节点, 把当前的节点的孩子全部追加到前一个节点的孩子里面
      prev.children.addAll(node.children);
      AppLogger.slateLog.i("合并元素节点操作 把后一个节点${node}的所有子节点，添加到前一个节点$prev  删除原来的${index}位置");
    } else {
      assert(false,
          'Cannot apply a "merge_node" operation at path [$path] to nodes of different model: $node $prev');
    }

    // 删除合并的这个节点
    parent.children.removeAt(index);
    setSelection(selection, this);

    return selection;
  }
}
