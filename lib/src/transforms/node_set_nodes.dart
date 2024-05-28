import 'package:slate/slate.dart';

/// 在某个位置的节点上设置新属性。
void nodeSetNodes(
  Document document,
  Map<String, Attribute?> props, {
  Location? atl,
  NodeMatch? match,
  Mode mode = Mode.lowest,
  bool hanging = false,
  bool split = false,
  bool voids = false,
}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;

    // 没有选择不设置
    if (at == null) {
      return;
    }

    // 是路径则匹配路径上的节点，不是则是任意的块都行
    match ??= at is Path
        ? matchPath(document, at)
        : ({Node? node, Path? path}) =>
            EditorCondition.isBlock(document, node!);

    // 修复悬停范围
    if (!hanging && at is Range) {
      at = LocationRange.unhangRange(document, at);
    }

    if (split && at is Range) {
      final rangeRef =
          EditorRef.makeRangeRef(document, at, affinity: Affinity.inward);
      final rangeEdge = at.edges();
      final start = rangeEdge.start;
      final end = rangeEdge.end;
      final splitMode = mode == Mode.lowest ? Mode.lowest : Mode.highest;
      final endAtEndOfNode = EditorCondition.isEnd(document, end, end.path);
      NodeTransforms.splitNodes(
        document,
        atl: end,
        match: match,
        mode: splitMode,
        voids: voids,
        always: !endAtEndOfNode,
      );
      final startAtStartOfNode =
          EditorCondition.isStart(document, start, start.path);
      NodeTransforms.splitNodes(document,
          atl: start,
          match: match,
          mode: splitMode,
          voids: voids,
          always: !startAtStartOfNode);
      at = rangeRef.unRef();

      if (atl == null) {
        SelectionTransforms.select(document, at!);
      }
    }

    for (final nodeEntry in LocationPathEntry.nodes(document,
        at: at, match: match, mode: mode, voids: voids)) {
      final node = nodeEntry.node;
      final path = nodeEntry.path;
      final properties = <String, Attribute?>{};
      final newProperties = <String, Attribute?>{};

      // You can't set properties on the document  node.
      if (path.isEmpty) {
        continue;
      }

      for (final k in props.keys) {
        if (k == 'children' || k == 'text') {
          continue;
        }

        if (props[k] != node.attributes[k]) {
          // Omit new properties from the old property list rather than set them to undefined
          if (node.attributes.containsKey(k)) {
            properties[k] = node.attributes[k]!;
          }
          newProperties[k] = props[k];
        }
      }

      if (newProperties.keys.isNotEmpty) {
        document.apply(SetNodeOperation(
            path: path, properties: properties, newProperties: newProperties));
      }
    }
  });
}
