import '../../slate.dart';

class NodeUtil {
  static Path findPath(Document document, Node node) {
    final path = Path.ofNull();
    var child = node;

    while (true) {
      final parent = child.nodeCache.cacheParent;

      if (parent == null) {
        if (EditorCondition.isEditor(child)) {
          return Path.of(path.reversed);
        } else {
          break;
        }
      }

      final i = child.nodeCache.cacheIdx!;
      path.add(i);
      child = parent;
    }

    throw UnsupportedError(
      'Unable to find the path for Slate node: $node',
    );
  }

  static bool isInSelection(Document document, Node node) {
    // print("test");
    if (document.selection == null ||
        document.selection!.isCollapsed() == false) {
      return false;
    }
    final path = document.selection!.anchor.path;
    final nodePath = node.getPath();
    final inSelection = nodePath.isAncestor(path) || nodePath.equals(path);
    return inSelection;
  }

  static Node refInstance(String string) {
    Node instance;
    if (SlateCache.itemToNode.contains(string) == false) {
      instance = ConvertXml2Node.toNode(string);
      SlateCache.itemToNode[string] = instance;
    } else {
      instance = SlateCache.itemToNode[string]!;
    }
    return instance.clone();
  }
}
