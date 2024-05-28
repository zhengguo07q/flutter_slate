import 'package:slate/slate.dart';

/// 使用但是不影响节点内容的数据， 比如说查找和文本高亮等， 而且可能存在多个
///
/// 选区为null的时候，一般是用来做查找的
class EditorMark {
  /// 获取将添加到当前选择的文本中的标记。
  static Map<String, Attribute> getMarks(Document document, {bool isCollapsed=true}) {
    final selection = document.selection;
    if (selection == null || isCollapsed) {
      return {};
    }

    // 存在mark则直接返回marks
    final marks = document.marks;
    if (marks != null) {
      return marks;
    }

    //不存在现成mark
    if (selection.isExpanded()) {
      // 是展开状态， 则取第一个文本节点的属性
      final nodeEntryList =
          LocationPathEntry.nodes(document, match: ({Node? node, Path? path}) {
        return KText.isText(node!);
      });

      if (nodeEntryList.isNotEmpty) {
        final node = nodeEntryList.first.node;
        return node.attributes;
      } else {
        return {};
      }
    } else {
      final anchor = selection.anchor;
      final path = anchor.path;
      final nodeEntry = LocationPathEntry.leaf(document, path);
      var node = nodeEntry.node;
      if (anchor.offset == 0) {
        // 当前的锚点在上一个节点的最后，需要取上一个节点的属性
        final prev = LocationPathEntry.previous(document,
            at: path, match: ({Node? node, Path? path}) => KText.isText(node!));
        final block = LocationPathEntry.above(
          document,
          match: ({Node? node, Path? path}) =>
              EditorCondition.isBlock(document, node!),
        );

        // 做同一个区块的前一行的判断
        if (prev != null && block != null) {
          final prevNode = prev.node;
          final prevPath = prev.path;
          final blockPath = block.path;

          if (blockPath.isAncestor(prevPath)) {
            node = prevNode;
          }
        }
      }

      return node.attributes;
    }
  }

  /// 给选择区域添加属性
  static void addMark(Document document, String key, Attribute value) {
    final selection = document.selection;

    if (selection != null) {
      if (selection.isExpanded()) {
        // 展开状态，找到文本节点，并为这个文本节点设置属性， 设置属性后按照选区进行分割
        NodeTransforms.setNodes(document, <String, Attribute>{key: value},
            match: ({Node? node, Path? path}) => KText.isText(node!),
            split: true);
      } else {
        // 闭合状态，没有任何选择， 则属性设置在文档上
        final currMarks = EditorMark.getMarks(document);
        final marks = <String, Attribute>{}
          ..addAll(currMarks)
          ..[key] = value;
        document.marks = marks;
        final isFlushing = SlateCache.flushing.get(document)??false;
        if (isFlushing == false) {
          document.onChange();
        }
      }
    }
  }

  /// 删除选择区域的属性
  static void removeMark(Document document, String key) {
    final selection = document.selection;

    if (selection != null) {
      if (selection.isExpanded()) {
        // 展开状态，删除这个属性
        NodeTransforms.unsetNodes(
          document,
          key,
          match: ({Node? node, Path? path}) => KText.isText(node!),
          split: true,
        );
      } else {
        final oldMarks = EditorMark.getMarks(document);
        final marks = {...oldMarks}..remove(key);
        document.marks = marks;
        final isFlushing = SlateCache.flushing.get(document)??false;
        if (isFlushing == false) {
          document.onChange();
        }
      }
    }
  }
}
