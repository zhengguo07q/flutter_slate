import 'package:slate/slate.dart';

/// 将某个位置的节点移动到新位置。
void nodeMoveNodes(Document document,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    required Path to,
    bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    final at = atl ?? document.selection;
    if (at == null) {
      return;
    }

    match ??= at is Path
        ? matchPath(document, at)
        : ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);

    final toRef = EditorRef.makePathRef(document, to);
    final targets =
        LocationPathEntry.nodes(document, at: at, match: match, mode: mode, voids: voids);
    final pathRefs =
        targets.map((entry) => EditorRef.makePathRef(document, entry.path));

    for (final pathRef in pathRefs) {
      final path = pathRef.unRef()!;
      final newPath = toRef.current!;

      if (path.isNotEmpty) {
        document.apply(MoveNodeOperation(path: path, newPath: newPath));
      }

      if (toRef.current != null &&
          newPath.isSibling(path) &&
          newPath.isAfter(path)) {
        // When performing a sibling move to a later index, the path at the destination is shifted
        // to before the insertion point instead of after. To ensure our group of nodes are inserted
        // in the correct order we increment toRef to account for that
        toRef.current = toRef.current!.next();
      }
    }

    toRef.unRef();
  });
}
