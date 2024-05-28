import 'package:slate/slate.dart';

/// 向上提升文档树中特定位置的节点，必要时将其父节点拆分为两部分。
void nodeLiftNodes(Document document,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    final at = atl ?? document.selection;
    if (at == null) {
      return;
    }

    match ??= at is Path
        ? matchPath(document, at)
        : ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);

    final matches =
        LocationPathEntry.nodes(document, at: at, match: match, mode: mode, voids: voids);
    final pathRefs =
        matches.map((entry) => EditorRef.makePathRef(document, entry.path));

    for (final pathRef in pathRefs) {
      final path = pathRef.unRef();

      // assert (path.length >= 2, 'Cannot lift node at a path [$path] because it has a depth of less than \`2\`.'),

      final parentNodeEntry = LocationPathEntry.node(document, path!.parent());
      final parent = parentNodeEntry.node;
      final parentPath = parentNodeEntry.path;
      final index = path[path.length - 1];
      final length = parent.children.length;

      if (length == 1) {
        final toPath = parentPath.next();
        NodeTransforms.moveNodes(document, atl: path, to: toPath, voids: voids);
        NodeTransforms.removeNodes(document, atl: parentPath, voids: voids);
      } else if (index == 0) {
        NodeTransforms.moveNodes(document,
            atl: path, to: parentPath, voids: voids);
      } else if (index == length - 1) {
        final toPath = parentPath.next();
        NodeTransforms.moveNodes(document, atl: path, to: toPath, voids: voids);
      } else {
        final splitPath = path.next();
        final toPath = parentPath.next();
        NodeTransforms.splitNodes(document, atl: splitPath, voids: voids);
        NodeTransforms.moveNodes(document, atl: path, to: toPath, voids: voids);
      }
    }
  });
}
