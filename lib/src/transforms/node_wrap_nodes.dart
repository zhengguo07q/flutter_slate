import 'package:slate/slate.dart';

import '../model/text.dart';

/// 包装节点在一个新的容器节点的位置，首先分割范围的边缘，以确保只有在范围内的内容被包装。
void nodeWrapNodes(Document document, Node element,
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

    if (match == null) {
      if (at is Path) {
        match = matchPath(document, at);
      } else if (KElement.isInline(element)) {
        match = ({Node? node, Path? path}) =>
        EditorCondition.isInline(document, node!) || KText.isText(node);
      } else {
        match = ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);
      }
    }

    if (split && at is Range) {
      final rangeEdge = at.edges();
      final start = rangeEdge.start;
      final end = rangeEdge.end;
      final rangeRef = EditorRef.makeRangeRef(
        document,
        at,
        affinity: Affinity.inward,
      );
      NodeTransforms.splitNodes(document, atl: end, match: match, voids: voids);
      NodeTransforms.splitNodes(document,
          atl: start, match: match, voids: voids);
      at = rangeRef.unRef();

      if (atl == null) {
        SelectionTransforms.select(document, at!);
      }
    }

    final roots = LocationPathEntry.nodes(
      document,
      at: at,
      match: KElement.isInline(element)
          ? ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!)
          : ({Node? node, Path? path}) => EditorCondition.isEditor(node!),
      mode: Mode.lowest,
      voids: voids,
    );

    for (final entry in roots) {
      final rootPath = entry.path;
      final a = at is Range
          ? at.intersection(LocationRange.range(document, rootPath))
          : at;

      if (a == null) {
        continue;
      }

      final matches =
      LocationPathEntry.nodes(document, at: a, match: match, mode: mode, voids: voids);

      if (matches.isNotEmpty) {
        final first = matches.first;
        final last = matches.last;
        final firstPath = first.path;
        final lastPath = last.path;
        final commonPath = firstPath.equals(lastPath)
            ? firstPath.parent()
            : firstPath.common(lastPath);

        final range = LocationRange.range(document, firstPath, to: lastPath);
        final commonNodeEntry = LocationPathEntry.node(document, commonPath);
        final commonNode = commonNodeEntry.node;
        final depth = commonPath.length + 1;
        final wrapperPath = Path.of(lastPath.sublist(0, depth)).next();
        element.children = [];
        final wrapper = element;
        NodeTransforms.insertNodes(document, [wrapper],
            atl: wrapperPath, voids: voids);

        NodeTransforms.moveNodes(
          document,
          atl: range,
          match: ({Node? node, Path? path}) =>
              KElement.isAncestor(commonNode) &&
              commonNode.children.contains(node!),
          to: Path.of(wrapperPath.followedBy([0])),
          voids: voids,
        );
      }
    }
  });
}
