import 'package:slate/slate.dart';

/// 删除文档中特定位置的节点。
void nodeRemoveNodes(Document document,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool hanging = false,
    bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;
    if (at == null) {
      return;
    }

    match ??= at is Path
        ? matchPath(document, at)
        : ({Node? node, Path? path}) =>
            EditorCondition.isBlock(document, node!);

    if (!hanging && at is Range) {
      at = LocationRange.unhangRange(document, at);
    }

    final depths = LocationPathEntry.nodes(document,
        at: at, match: match, mode: mode, voids: voids);

    // 根据这些路径构建了新的路径引用对象
    final pathRefs = depths
        .map((entry) => EditorRef.makePathRef(document, entry.path))
        .toList();

    // 解开这些路径
    for (final pathRef in pathRefs) {
      final path = pathRef.unRef();

      if (path != null) {
        final nodeEntry = LocationPathEntry.node(document, path);
        document.apply(RemoveNodeOperation(path: path, node: nodeEntry.node));
      }
    }
  });
}
