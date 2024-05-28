import 'package:slate/slate.dart';

import '../model/text.dart';

/// 在编辑器的特定位置插入一个片段。
void textInsertFragment(Document document, List<Node> fragment,
    {Location? atl, bool hanging = false, bool voids = false}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;

    if (fragment.isEmpty) {
      return;
    }

    if (at == null) {
      return;
    } else if (at is Range) {
      if (!hanging) {
        at = LocationRange.unhangRange(document, at);
      }

      if (at.isCollapsed()) {
        at = at.anchor;
      } else {
        final rangeEdge = at.edges();
        final end = rangeEdge.end;
        if (voids == false &&
            LocationPathEntry.voids(document, at: end) != null) {
          return;
        }

        final pointRef = EditorRef.makePointRef(document, end);
        TextTransforms.delete(document, atl: at);
        at = pointRef.unRef();
      }
    } else if (at is Path) {
      at = LocationPoint.start(document, at);
    }

    if (voids == false && LocationPathEntry.voids(document, at: at) != null) {
      return;
    }

    // If the insert point is at the edge of an inline node, move it outside
    // instead since it will need to be split otherwise.
    final inlineElementMatch = LocationPathEntry.above(
      document,
      at: at,
      match: ({Node? node, Path? path}) =>
          EditorCondition.isInline(document, node!),
      mode: Mode.highest,
      voids: voids,
    );

    at as Point;

    if (inlineElementMatch != null) {
      final inlinePath = inlineElementMatch.path;

      if (EditorCondition.isEnd(document, at, inlinePath)) {
        final after = LocationPoint.after(document, inlinePath)!;
        at = after;
      } else if (EditorCondition.isStart(document, at, inlinePath)) {
        final before = LocationPoint.before(document, inlinePath)!;
        at = before;
      }
    }

    final blockMatch = LocationPathEntry.above(
      document,
      match: ({Node? node, Path? path}) =>
          EditorCondition.isBlock(document, node!),
      at: at,
      voids: voids,
    )!;
    final blockPath = blockMatch.path;
    final isBlockStart = EditorCondition.isStart(document, at, blockPath);
    final isBlockEnd = EditorCondition.isEnd(document, at, blockPath);
    final mergeStart = !isBlockStart || (isBlockStart && isBlockEnd);
    final mergeEnd = !isBlockEnd;
    final firstEntry = Node(children: fragment).first(Path.ofNull());
    final firstPath = firstEntry.path;
    final lastEntry = Node(children: fragment).last(Path.ofNull());
    final lastPath = lastEntry.path;

    final matches = <PathEntry>[];
    final matcher = ({Node? node, Path? path}) {
      if (mergeStart &&
          path!.isAncestor(firstPath) &&
          KElement.isElement(node!) &&
          !KElement.isVoid(node) &&
          !KElement.isInline(node)) {
        return false;
      }

      if (mergeEnd &&
          path!.isAncestor(lastPath) &&
          KElement.isElement(node!) &&
          !KElement.isVoid(node) &&
          !KElement.isInline(node)) {
        return false;
      }

      return true;
    };

    for (final entry in Node(children: fragment).nodes(
      pass: matcher,
    )) {
      if (entry.path.isNotEmpty &&
          matcher(node: entry.node, path: entry.path)) {
        matches.add(entry);
      }
    }

    final starts = <Node>[];
    final middles = <Node>[];
    final ends = <Node>[];
    var starting = true;
    var hasBlocks = false;

    for (final nodeEntry in matches) {
      final node = nodeEntry.node;
      if (KElement.isElement(node) && !KElement.isInline(node)) {
        starting = false;
        hasBlocks = true;
        middles.add(node);
      } else if (starting) {
        starts.add(node);
      } else {
        ends.add(node);
      }
    }

    final inlineMatchList = LocationPathEntry.nodes(
      document,
      at: at,
      match: ({Node? node, Path? path}) =>
          KText.isText(node!) || EditorCondition.isInline(document, node),
      mode: Mode.highest,
      voids: voids,
    );

    final firstMatch = inlineMatchList.first;
    final inlinePath = firstMatch.path;
    final isInlineStart = EditorCondition.isStart(document, at, inlinePath);
    final isInlineEnd = EditorCondition.isEnd(document, at, inlinePath);

    final middleRef = EditorRef.makePathRef(
      document,
      isBlockEnd ? blockPath.next() : blockPath,
    );

    final endRef = EditorRef.makePathRef(
      document,
      isInlineEnd ? inlinePath.next() : inlinePath,
    );

    NodeTransforms.splitNodes(
      document,
      atl: at,
      match: ({Node? node, Path? path}) => hasBlocks
          ? EditorCondition.isBlock(document, node!)
          : KText.isText(node!) || EditorCondition.isInline(document, node),
      mode: hasBlocks ? Mode.lowest : Mode.highest,
      voids: voids,
    );

    final startRef = EditorRef.makePathRef(
      document,
      !isInlineStart || (isInlineStart && isInlineEnd)
          ? inlinePath.next()
          : inlinePath,
    );

    NodeTransforms.insertNodes(
      document,
      starts,
      atl: startRef.current,
      match: ({Node? node, Path? path}) =>
          KText.isText(node!) || EditorCondition.isInline(document, node),
      mode: Mode.highest,
      voids: voids,
    );

    NodeTransforms.insertNodes(
      document,
      middles,
      atl: middleRef.current,
      match: ({Node? node, Path? path}) =>
          EditorCondition.isBlock(document, node!),
      voids: voids,
    );

    NodeTransforms.insertNodes(
      document,
      ends,
      atl: endRef.current,
      match: ({Node? node, Path? path}) =>
          KText.isText(node!) || EditorCondition.isInline(document, node),
      mode: Mode.highest,
      voids: voids,
    );

    if (atl == null) {
      Path path;

      if (ends.isNotEmpty) {
        path = endRef.current!.previous();
      } else if (middles.isNotEmpty) {
        path = middleRef.current!.previous();
      } else {
        path = startRef.current!.previous();
      }

      final end = LocationPoint.end(document, path);
      SelectionTransforms.select(document, end);
    }

    startRef.unRef();
    middleRef.unRef();
    endRef.unRef();
  });
}
