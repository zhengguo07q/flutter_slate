import 'package:slate/slate.dart';

class EditorTransform {
  /// 在当前所选区域插入一个块分隔符。
  ///
  /// 如果当前选择是展开的，它将首先被删除。
  static void insertBreak(Document document) {
    NodeTransforms.splitNodes(document, always: true);
  }

  /// 在当前选择中插入一个片段。
  ///
  /// 如果当前选择是展开的，它将首先被删除。
  static void insertFragment(Document document, List<Node> fragment) {
    TextTransforms.insertFragment(document, fragment);
  }

  /// 在当前选区插入一个节点。
  ///
  /// 如果当前选择是展开的，它将首先被删除。
  static void insertNode(Document document, Node node) {
    NodeTransforms.insertNodes(document, [node]);
  }

  /// 在当前选区插入文本。
  ///
  /// 如果当前选择是展开的，它将首先被删除。
  static void insertText(Document document, String text) {
    final selection = document.selection;
    final marks = document.marks;

    if (selection != null) {
      //如果游标位于内联末尾，则在插入前将其移出内联
      if (selection.isCollapsed()) {
        final inline = LocationPathEntry.above(
          document,
          match: ({Node? node, Path? path}) =>
              EditorCondition.isInline(document, node!),
          mode: Mode.highest,
        );

        if (inline != null) {
          final inlinePath = inline.path;

          if (EditorCondition.isEnd(document, selection.anchor, inlinePath)) {
            final point = LocationPoint.after(document, inlinePath)!;
            SelectionTransforms.setSelection(
                document, Range(anchor: point, focus: point));
          }
        }
      }

      if (marks != null) {
        final node = Node(text: text, attributes: marks);
        NodeTransforms.insertNodes(document, [node]);
      } else {
        TextTransforms.insertText(document, text);
      }

      document.marks = null;
    }
  }

  void deleteBackward(Document document,
      {Unit unit = Unit.character, int distance = 1}) {
    final selection = document.selection;

    // 闭合选区删除
    if (selection != null && selection.isCollapsed()) {
      TextTransforms.delete(document,
          unit: unit, distance: distance, reverse: true);
    } else {
      TextTransforms.delete(document,
          unit: unit, distance: distance, reverse: true);
    }
  }

  /// 从当前选择中删除编辑器向前的内容。
  static void deleteForward(Document document, {Unit unit = Unit.character}) {
    final selection = document.selection;

    if (selection != null && selection.isCollapsed()) {
      TextTransforms.delete(document, unit: unit);
    }
  }

  /// 删除当前所选内容。
  static void deleteFragment(Document document,
      {Direction direction = Direction.forward}) {
    final selection = document.selection;

    if (selection != null && selection.isExpanded()) {
      TextTransforms.delete(document, reverse: direction == Direction.backward);
    }
  }

  static List<dynamic> getFragment(Document document) {
    final selection = document.selection;

    if (selection != null) {
      return document.fragment(selection);
    }
    return <dynamic>[];
  }

  /// 找到一个位置获取碎片。
  static List<Node> fragment(Document document, Location at) {
    final range = LocationRange.range(document, at);
    final fragment = document.fragment(range);
    return fragment;
  }
}
