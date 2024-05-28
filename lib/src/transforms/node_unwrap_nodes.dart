import 'package:slate/slate.dart';

/// 从父节点展开一个位置的节点，如果需要拆分父节点，以确保只有在范围内的内容被展开。
void nodeUnwrapNodes(Document document,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool split = false,
    bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;

    if (at == null) {
      return;
    }

    match ??= at is Path
        ? matchPath(document, at)
        : ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);

    if (at is Path) {
      at = LocationRange.range(document, at);
    }

    final rangeRef =
        at is Range ? EditorRef.makeRangeRef(document, at) : null;
    final matches =
    LocationPathEntry.nodes(document, at: at, match: match, mode: mode, voids: voids);
    final pathRefs =
        matches.map((entry) => EditorRef.makePathRef(document, entry.path));

    for (final pathRef in pathRefs) {
      final path = pathRef.unRef();
      final nodeEntry = LocationPathEntry.node(document, path!);
      final nodeR = nodeEntry.node;
      var range = LocationRange.range(document, path);

      if (split && rangeRef != null) {
        range = rangeRef.current!.intersection(range)!;
      }

      NodeTransforms.liftNodes(
        document,
        atl: range,
        match: ({Node? node, Path? path}) =>
            KElement.isAncestor(nodeR) && nodeR.children.contains(node!),
        voids: voids,
      );
    }

    if (rangeRef != null) {
      rangeRef.unRef();
    }
  });
}
