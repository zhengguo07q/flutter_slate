import 'package:slate/slate.dart';

/// 在特定位置拆分节点。
void nodeSplitNodes(Document document,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool always = false,
    int height = 0,
    bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;
    // 默认的匹配条件是对块进行分割
    match ??= ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);

    if (at == null) {
      return;
    }

    // 不是对范围分割，范围是要排除掉删除的。如果是范围且非闭合，则删除范围内的内容。
    if (at is Range) {
      at = _deleteRange(document, at);
    }

    // 如果目标是一条给定路径，我们需要考虑默认的高度跳跃和位置计数器可能在非叶子上分裂。
    if (at is Path) {
      final path = at;
      final point = LocationPoint.point(document, path);
      final parentEntry = LocationPathEntry.parent(document, path);
      final parent = parentEntry.node;
      match = ({Node? node, Path? path}) => node == parent;
      height = point.path.length - path.length + 1;
      at = point;
      always = true;
    }

    final beforeRef = EditorRef.makePointRef(
      document,
      at as Point,
      affinity: Affinity.backward,
    );
    final highestList =
    LocationPathEntry.nodes(document, at: at, match: match, mode: mode, voids: voids);

    if (highestList.isEmpty) {
      return;
    }
    final highest = highestList.first;

    final voidMatch = LocationPathEntry.voids(document, at: at, mode: Mode.highest);
    const nudge = 0;

    if (!voids && voidMatch != null) {
      final voidNode = voidMatch.node;
      final voidPath = voidMatch.path;

      if (KElement.isElement(voidNode) && KElement.isInline(voidNode)) {
        var after = LocationPoint.after(document, voidPath);

        if (after == null) {
          final text = Node(text: '');
          final afterPath = voidPath.next();
          NodeTransforms.insertNodes(document, [text],
              atl: afterPath, voids: voids);
          after = LocationPoint.point(document, afterPath);
        }

        at = after;
        always = true;
      }

      final siblingHeight = at.path.length - voidPath.length;
      height = siblingHeight + 1;
      always = true;
    }

    final afterRef = EditorRef.makePointRef(document, at);
    final depth = at.path.length - height;
    final highestPath = highest.path;
    final lowestPath = Path.of(at.path.sublist(0, depth));
    var position = height == 0 ? at.offset : at.path[depth] + nudge;

    for (final entry in LocationPathEntry.levels(
      document,
      at: lowestPath,
      reverse: true,
      voids: voids,
    )) {
      final node = entry.node;
      final path = entry.path;
      var split = false;

      if (path.length < highestPath.length ||
          path.isEmpty ||
          (!voids && EditorCondition.isVoid(document, node))) {
        break;
      }

      final point = beforeRef.current!;
      final isEnd = EditorCondition.isEnd(document, point, path);

      if (always || !EditorCondition.isEdge(document, point, path)) {
        split = true;
        final properties = node.extractProps();
        document.apply(SplitNodeOperation(
            path: path, position: position, attributes: Map.from(properties)));

        position = path[path.length - 1] + (split || isEnd ? 1 : 0);
      }
    }
    // 作为单点分割的时候，重新设置选择位置位于特定的点
    if (atl == null) {
      var point = afterRef.current;
      point ??= LocationPoint.end(document, Path.ofNull());
      SelectionTransforms.select(document, point);
    }

    beforeRef.unRef();
    afterRef.unRef();
  });
}

/// 删除范围的内容
///
/// 然后将范围转换为点。
Point? _deleteRange(Document document, Range range) {
  if (range.isCollapsed()) {
    return range.anchor;
  } else {
    final rangeEdge = range.edges();
    final end = rangeEdge.end;
    final pointRef = EditorRef.makePointRef(document, end);
    TextTransforms.delete(document, atl: range);
    return pointRef.unRef();
  }
}
