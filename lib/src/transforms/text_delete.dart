library TextTransforms;

import 'package:slate/slate.dart';

/// 删除编辑器中的内容。
///
/// 根据当前的位置，找出需要删除的位置区间
/// 会进行VOID判断，
/// 删除规则：
///   如果没用给定位置，则会删除选区里的内容
///   没用给定位置，使用光标位置：
///     如果删除的方向上是文本，则会直接对相关的文本字符，或者单词进行删除。
///     如果删除的方向上不是文本，则会把这个块，或者下一个块的块属性删除，
///   没用给定位置，光标是选区
///   给定位置
///     则直接是把位置里面的所有子节点删除
void textDelete(
  Document document, {
  Location? atl,
  int distance = 1,
  Unit unit = Unit.character,
  bool reverse = false,
  bool hanging = false,
  bool voids = false,
}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;
    if (at == null) {
      return;
    }

    // 先要找一个要删除的位置的点
    if (at is Range && at.isCollapsed()) {
      at = at.anchor;
    }
    // 找到这个点后，要根据条件找到这个点相关的要删除的节点范围
    // 比如说是否跨节点等
    if (at is Point) {
      // 从外向内匹配，找到第一个voids节点
      final furthestVoid = LocationPathEntry.voids(document, at: at, mode: Mode.highest);
      // 不允许为void 且存在void，则删除整个节点
      if (voids == false && furthestVoid != null) {
        final voidPath = furthestVoid.path;
        at = voidPath;
      } else {
        // 找出删除这个字符字符之前或者之后的位置
        var before =
        LocationPoint.before(document, at, unit: unit, distance: distance);
        before ??= LocationPoint.start(document, Path.ofNull());
        var after = LocationPoint.after(document, at, unit: unit, distance: distance);
        after ??= LocationPoint.end(document, Path.ofNull());
        // 是否反转位置
        final target = reverse ? before : after;
        at = Range(anchor: at, focus: target);
        hanging = true;
      }
    }
    // 在VOID状态下，直接删除路径给定的节点
    if (at is Path) {
      NodeTransforms.removeNodes(document, atl: at, voids: voids);
      return;
    }

    if (at is Range) {
      // 如果是范围，但是筛选出来还是闭合，也就是选不出要删除的区域，则直接返回
      if (at.isCollapsed()) {
        return;
      }

      // 一般的范围需要处理悬挂
      if (!hanging) {
        final rangeEdge = at.edges();
        final end = rangeEdge.end;
        final endOfDoc = LocationPoint.end(document, Path.ofNull());

        if (!end.equals(endOfDoc)) {
          at = LocationRange.unhangRange(document, at, voids: voids);
        }
      }

      // 根据范围位置，找到要删除的范围的块
      final rangeEdge = at.edges();
      var start = rangeEdge.start;
      var end = rangeEdge.end;
      final startBlock = LocationPathEntry.above(
        document,
        match: ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!),
        at: start,
        voids: voids,
      );
      final endBlock = LocationPathEntry.above(
        document,
        match: ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!),
        at: end,
        voids: voids,
      );
      // 开始点或结束点是否跨越了块节点
      final isAcrossBlocks = startBlock != null &&
          endBlock != null &&
          !startBlock.path.equals(endBlock.path);
      // 是否是简单的文本
      final isSingleText = start.path.equals(end.path);
      final startVoid =
          voids ? null : LocationPathEntry.voids(document, at: start, mode: Mode.highest);
      final endVoid =
          voids ? null : LocationPathEntry.voids(document, at: end, mode: Mode.highest);

      // 如果开始点或结束点在内联void中，将它们移出。
      if (startVoid != null) {
        final before = LocationPoint.before(document, start);

        if (before != null &&
            startBlock != null &&
            startBlock.path.isAncestor(before.path)) {
          start = before;
        }
      }

      if (endVoid != null) {
        final after = LocationPoint.after(document, end);

        if (after != null &&
            endBlock != null &&
            endBlock.path.isAncestor(after.path)) {
          end = after;
        }
      }

      // 获取完全在该范围内的最高节点，以及开始和结束节点。
      final matches = <PathEntry>[];
      Path? lastPath;

      for (final entry in LocationPathEntry.nodes(document, at: at, voids: voids)) {
        final node = entry.node;
        final path = entry.path;

        if (lastPath != null && path.compare(lastPath) == 0) {
          continue;
        }

        if ((!voids && EditorCondition.isVoid(document, node)) ||
            (!path.isCommon(start.path) && !path.isCommon(end.path))) {
          matches.add(entry);
          lastPath = path;
        }
      }

      final pathRefs =
          matches.map((entry) => EditorRef.makePathRef(document, entry.path));
      final startRef = EditorRef.makePointRef(document, start);
      final endRef = EditorRef.makePointRef(document, end);

      // 不是简单文本，进行开始删除文本操作
      if (!isSingleText && (startVoid == null)) {
        final point = startRef.current!;
        final nodeEntry = LocationPathEntry.leaf(document, point);
        final node = nodeEntry.node;
        final path = point.path;
        final offset = start.offset;
        final text = node.text!.substring(offset);
        if (text.isNotEmpty) {
          document.apply(
              RemoveTextOperation(path: path, offset: offset, text: text));
        }
      }
      // 删除中间节点操作
      for (final pathRef in pathRefs) {
        final path = pathRef.unRef();
        NodeTransforms.removeNodes(document, atl: path, voids: voids);
      }

      // 进行结束区域文档删除工作
      if (endVoid == null) {
        final point = endRef.current!;
        final nodeEntry = LocationPathEntry.leaf(document, point);
        final node = nodeEntry.node;
        final path = point.path;
        final offset = isSingleText ? start.offset : 0;
        final text = node.text!.substring(offset, end.offset);
        if (text.isNotEmpty) {
          document.apply(
              RemoveTextOperation(path: path, offset: offset, text: text));
        }
      }
      // 删除后，如果是跨了节点，需要进行合并节点操作
      if (!isSingleText &&
          isAcrossBlocks &&
          endRef.current != null &&
          startRef.current != null) {
        NodeTransforms.mergeNodes(document,
            atl: endRef.current, hanging: true, voids: voids);
      }

      Point? point;
      final startPoint = startRef.unRef();
      final endPoint = endRef.unRef();
      if (reverse) {
        point = startPoint ?? endPoint;
      } else {
        point = endPoint ?? startPoint;
      }

      // 重置选区
      if (atl == null && point != null) {
        SelectionTransforms.select(document, point);
      }
    }
  });
}
