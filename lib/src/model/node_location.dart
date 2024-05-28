import 'package:slate/src/attribute/attribute_type.dart';

import '../../slate.dart';
import 'package:tuple/tuple.dart';
import 'package:dartx/dartx.dart' as dartx;

class NodeOffset {
  NodeOffset(this.node, this.offset);

  Node? node;
  int offset;
}

/// 文档模式下的缓存
class NodeCache {
  Node? cacheParent;
  int? cacheIdx = -1;
  int? offset = 0; // 当前文本节点内部的偏移
  int? blockOffset = 0; // 当前文本区块中的位置

  int? length = 0; //不用清除的属性
  int? depth = 0;

  void clear() {
    cacheParent = null;
    cacheIdx = -1;
    offset = 0;
    blockOffset = 0;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NodeCache &&
            cacheIdx == other.cacheIdx &&
            length == other.length &&
            offset == other.offset &&
            blockOffset == other.blockOffset;
  }
}

class NodeLocation extends NodeAttribute {
  NodeLocation({
    String? type,
    String? text,
    List<Node>? children,
    Map<String, Attribute>? attributes,
  }) : super(
            type: type, text: text, children: children, attributes: attributes);

  final NodeCache nodeCache = NodeCache();

  /// 处理文本节点的更新
  ///
  /// 标记为脏的节点，父子的关系链也可以重新建立
  void updateTextNode() {
    if (type == AttributeType.single) {
      updateLength();
      updateNodeInfo();
      return;
    }
    children.forEach((child) {
      child.updateTextNode();
    });
  }

  /// 遍历缓存索引[NodeCache]信息
  void updateNodeInfo() {
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      child.nodeCache
        ..clear()
        ..cacheIdx = i
        ..cacheParent = this as Node;
      SlateCache.nodeToIndex[child] = i;
      child
        ..cacheOffset()
        ..cacheBlockOffset();
      child.updateNodeInfo();
    }
  }

  /// 在最顶层节点调用缓存长度，则会迭代进入子节点，获取文本长度
  ///
  /// 长度是父节点依赖于子节点， 从父节点开始遍历依次设置
  /// 长度的缓存，不需要清楚，每次都是自动覆盖
  int updateLength() {
    nodeCache.length = children.fold<int>(0, (cur, node) {
      if (node.text != null) {
        // 普通文本节点不会进入迭代，需要主动设置长度
        node.nodeCache.length = node.text!.length;
        return cur + node.text!.length;
      }
      return cur + node.updateLength();
    });
    return nodeCache.length!;
  }

  /// 获得当前节点和包含的所有的子节点里面[single]的长度
  int get length {
    return nodeCache.length!;
  }

  /// 计算当前节点在父节点里面的位置。
  void cacheOffset() {
    const offset = 0;
    // 第一个位置的偏移为0
    if (isFirst) {
      nodeCache.offset = offset;
    }else{
      // 后面的节点的偏移为 前面的偏移+前面的长度
      final previous = nodeCache.cacheParent!.children[nodeCache.cacheIdx! - 1];
      nodeCache.offset = previous.offset + previous.length;
    }
  }

  /// 计算当前节点在父节点里面的位置。
  ///
  /// 默认第一个节点偏移为0
  int get offset {
    return nodeCache.offset!;
  }

  /// 当前节点在整个块中的偏移
  ///
  /// 父节点的blockOffset + offset + len
  void cacheBlockOffset() {
    final parentNode = nodeCache.cacheParent!;
    nodeCache.blockOffset = parentNode.blockOffset + parentNode.offset;
  }

  int get blockOffset {
    return nodeCache.blockOffset!;
  }

  /// 判断当前的节点是否为父节点的第一个子节点, 前面建的索引， 这里只需要判断当前索引状态就可以
  bool get isFirst => nodeCache.cacheIdx == 0;

  /// 判断当前节点是否为父节点的最后一个节点
  bool get isLast => nodeCache.cacheParent!.children.last == this;

  NodeOffset queryChild(int offset, {bool inclusive = false}) {
    if (offset < 0 || offset > length) {
      return NodeOffset(null, 0);
    }

    for (final node in children) {
      final len = node.length;
      if (offset < len || (inclusive && offset == len && node.isLast)) {
        return NodeOffset(node, offset);
      }
      offset -= len;
    }
    return NodeOffset(null, 0);
  }

  /// TODO 错误的函数，要重新处理
  Tuple2<Node?, Node?> querySegmentLeafNode(int offset) {
    final result = queryChild(offset);
    if (result.node == null) {
      return const Tuple2(null, null);
    }
    final line = result.node!;
    final segmentResult = line.queryChild(result.offset, inclusive: false);
    if (segmentResult.node == null) {
      return Tuple2(line, null);
    }
    final segment = segmentResult.node;
    return Tuple2(line, segment);
  }

  /// 偏移是否在当前节点里面
  bool containsOffset(int offset) {
    final o = nodeCache.offset!;
    return o <= offset && offset <= o + length;
  }

  Path getPath({Node? parentNode}) {
    final path = Path.ofNull();
    var child = this;

    while (true) {
      final parent = child.nodeCache.cacheParent;

      if (parent == null) {
        if (EditorCondition.isEditor(child)) {
          return Path.of(path.reversed);
        } else {
          break;
        }
      }
      // 提供有父节点
      if (parentNode != null && parentNode == parent) {
        return Path.of(path.reversed);
      }
      final i = child.nodeCache.cacheIdx!;
      path.add(i);
      child = parent;
    }

    return path;
  }

  /// 获取组件
  Node getComponent() {
    Node node = (this) as Node;
    while (KElement.isElement(node) && !KElement.isEditor(node)) {
      if (KElement.isEditor(node.nodeCache.cacheParent!)) break;
      node = node.nodeCache.cacheParent!;
    }
    return node;
  }

  ///偏移位置在节点的[Location]
  static Point offsetLocation(Node root, int selectionOffset) {
    // 当前节点，文档偏移
    Node? findNode(Node parentNode, int offset) {
      Node? node;
      for (var child in parentNode.children) {
        if (child.containsOffset(offset)) {
          node = child;
          break;
        }
      }
      return node;
    }
    Node? lastNode;
    Node? nextNode = root;
    final path = Path.ofNull();
    var offsetTotal = 0;
    // 第一个节点的idx为null, 不用添加
    do {
      //当前的整个偏移
      nextNode = findNode(nextNode!, selectionOffset);
      if (nextNode != null) {
        lastNode = nextNode;
        offsetTotal += nextNode.offset;
        path.add(nextNode.nodeCache.cacheIdx!);
      }
    } while (nextNode != null);
    var localOffset = selectionOffset;
    if(lastNode != null){
      localOffset = selectionOffset - (lastNode.blockOffset + lastNode.offset);
    }
    return Point.of(path, localOffset);
  }
}
