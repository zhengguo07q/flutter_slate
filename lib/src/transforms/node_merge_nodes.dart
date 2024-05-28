import 'package:slate/slate.dart';

import '../model/text.dart';
import '../location/path_ref.dart';

/// 合并一个节点的位置与前一个节点的深度相同，如果必要的话，删除合并后的任何空节点。
void nodeMergeNodes(Document document,
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

    if (match == null) {
      if (at is Path) {
        final parent = LocationPathEntry.parent(document, at);
        match =
            ({Node? node, Path? path}) => parent.node.children.contains(node);
      } else {
        match = ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);
      }
    }

    if (!hanging && at is Range) {
      at = LocationRange.unhangRange(document, at);
    }

    if (at is Range) {
      if (at.isCollapsed()) {
        at = at.anchor;
      } else {
        final rangeEdges = at.edges();
        final pointRef = EditorRef.makePointRef(document, rangeEdges.end);
        TextTransforms.delete(document, atl: at);
        at = pointRef.unRef();

        if (atl == null) {
          SelectionTransforms.select(document, at!);
        }
      }
    }

    final currentList =
        LocationPathEntry.nodes(document, at: at, match: match, voids: voids, mode: mode);
    final current = currentList.first;
    final prev = LocationPathEntry.previous(document,
        at: at, match: match, voids: voids, mode: mode);

    if (prev == null) {
      return;
    }

    final node = current.node;
    final path = current.path;
    final prevNode = prev.node;
    final prevPath = prev.path;

    if (path.isEmpty || prevPath.isEmpty) {
      return;
    }

    final newPath = prevPath.next();
    final commonPath = path.common(prevPath);
    final isPreviousSibling = path.isSibling(prevPath);
    var levels = LocationPathEntry.levels(document, at: path)
        .map((entry) => entry.node)
        .toList()
        .sublist(commonPath.length);

    levels = levels.sublist(0, levels.length - 1);

    // Determine if the merge will leave an ancestor of the path empty as a
    // result, in which case we'll want to remove it after merging.
    final emptyAncestor = LocationPathEntry.above(
      document,
      at: path,
      mode: Mode.highest,
      match: ({Node? node, Path? path}) =>
          levels.contains(node) && _hasSingleChildNest(document, node!),
    );

    PathRef? emptyRef;
    if (emptyAncestor != null) {
      emptyRef = EditorRef.makePathRef(document, emptyAncestor.path);
    }

    Map<String, Attribute>? properties;
    int? position;

    // Ensure that the nodes are equivalent, and figure out what the position
    // and extra properties of the merge will be.
    if (KText.isText(node) && KText.isText(prevNode)) {
      final text = node.text;
      position = prevNode.text!.length;
      properties = node.attributes;
    } else if (KElement.isElement(node) && KElement.isElement(prevNode)) {
      final children = node.children;
      position = prevNode.children.length;
      properties = node.attributes;
    } else {
      assert(false,
          'Cannot merge the node at path [$path] with the previous sibling because it is not the same kind: $node, $prevNode');
    }

    // If the node isn't already the next sibling of the previous node, move
    // it so that it is before merging.
    if (!isPreviousSibling) {
      NodeTransforms.moveNodes(document, atl: path, to: newPath, voids: voids);
    }

    // If there was going to be an empty ancestor of the node that was merged,
    // we remove it from the tree.
    if (emptyRef != null) {
      NodeTransforms.removeNodes(document,
          atl: emptyRef.current!, voids: voids);
    }

    // If the target node that we're merging with is empty, remove it instead
    // of merging the two. This is a common rich single document  behavior to
    // prevent losing formatting when deleting entire nodes when you have a
    // hanging selection.
    if ((KElement.isElement(prevNode) && EditorCondition.isEmpty(document, prevNode)) ||
        (KText.isText(prevNode) && prevNode.text == '')) {
      NodeTransforms.removeNodes(document, atl: prevPath, voids: voids);
    } else {
      document.apply(MergeNodeOperation(
          path: newPath, position: position!, properties: properties!));
    }

    if (emptyRef != null) {
      emptyRef.unRef();
    }
  });
}



bool _hasSingleChildNest(Document document, Node node) {
  if (KElement.isElement(node)) {
    final element = node;
    if (EditorCondition.isVoid(document, node)) {
      return true;
    } else if (element.children.length == 1) {
      return _hasSingleChildNest(document, element.children[0]);
    } else {
      return false;
    }
  } else if (EditorCondition.isEditor(node)) {
    return false;
  } else {
    return true;
  }
}
