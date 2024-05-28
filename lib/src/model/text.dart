import 'package:slate/slate.dart';

/// “Text”对象表示包含Slate文档的实际文本内容以及任何格式化属性的节点。
///
/// 它们总是文档树中的叶节点，因为它们不能包含任何子节点。
///
class KText {
  /// 检查两个文本节点是否相等。
  static bool equals(Node text, Node another, {bool? loose}) {
    return false;
  }

  /// 检查一个值是否实现了' Text '接口。
  static bool isText(Node value) {
    return value.text != null;
  }

  /// 检查一个值是否为“Text”对象的列表。
  static bool isTextList(dynamic value) {
    return value is List<KText>;
  }

  /// 检查是否有些道具是部分文本。
  static bool isTextProps(dynamic props) {
    return true;
  }

  /// 检查文本是否匹配属性集。
  ///
  /// 注意:这是为匹配自定义属性，它不确保' single '属性是两个节点相等。
  static bool matches(Node text, dynamic props) {
    return false;
  }

  /// 获取给定装饰的文本节点的叶子。
  static List<Node> decorations(Node node, List<Range> decorations) {
    var leaves = <Node>[node.clone()];

    for (final dec in decorations) {
      final anchor = dec.anchor;
      final focus = dec.focus;
      final rangeEdge = dec.edges();
      final start = rangeEdge.start;
      final end = rangeEdge.end;
      final next = <Node>[];
      var o = 0;

      for (final leaf in leaves) {
        final length = leaf.text!.length;
        final offset = o;
        o += length;

        // If the range encompases the entire leaf, add the range.
        if (start.offset <= offset && end.offset >= o) {
          //Object.assign(leaf, rest);
          next.add(leaf);
          continue;
        }

        // If the range expanded and match the leaf, or starts after, or ends before it, continue.
        if ((start.offset != end.offset &&
                (start.offset == o || end.offset == offset)) ||
            start.offset > o ||
            end.offset < offset ||
            (end.offset == offset && offset != 0)) {
          next.add(leaf);
          continue;
        }

        // Otherwise we need to split the leaf, at the start, end, or both,
        // and add the range to the middle intersecting section. Do the end
        // split first since we don't need to update the offset that way.
        var middle = leaf;
        Node? before;
        Node? after;

        if (end.offset < o) {
          final off = end.offset - offset;
          after = Node(
            attributes: middle.attributes,
            text: middle.text!.substring(off),
          );
          middle = Node(
              attributes: middle.attributes,
              text: middle.text!.substring(0, off));
        }

        if (start.offset > offset) {
          final off = start.offset - offset;
          before = Node(
              attributes: middle.attributes,
              text: middle.text!.substring(0, off));
          middle = Node(
              attributes: middle.attributes, text: middle.text!.substring(off));
        }

        //Object.assign(middle, rest);

        if (before != null) {
          next.add(before);
        }

        next.add(middle);

        if (after != null) {
          next.add(after);
        }
      }

      leaves = next;
    }
    return leaves;
  }
}
