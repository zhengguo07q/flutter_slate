import 'package:slate/slate.dart';

import '../model/text.dart';

/// 在编辑器中的特定位置插入节点。
///
/// 提供了基本的插入节点能力，一般情况下先插入第一个节点。插入成功后再在这个节点后面插入其他节点
/// 节点插入的位置使用选区或者位置来判定，没有要么插入在最后，要么插入在第一个
/// 根据节点的属性判定，到底是选择插入在哪儿
///   比如说文本，只要随意的光标后面的文本都可以插入，但是如果是块，则不能够插入到文本的位置
///   块只能插入到块后面。行的话，也只能插入到行的后面
///
/// 插入的位置如果是一个[Point]
Future<void> nodeInsertNodes(Document document, List<Node> nodes,
    {Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool hanging = false,
    bool? select,
    bool voids = false}) async {
  EditorNormalizing.withoutNormalizing(document, () {
    if (nodes.isEmpty) {
      return;
    }

    // 获取第一个节点
    final firstNode = nodes.first;

    // 定位选区
    // 默认情况下，使用选区作为目标位置。
    // 但如果没有选择，则在文档的末尾插入，因为这是从非选择状态插入时的常见用例。
    var at = atl;
    if (at == null) {
      if (document.selection != null) {
        // 使用选区
        at = document.selection;
      } else if (document.children.isNotEmpty) {
        // 不存在选区，则插在整个文档的后面
        at = LocationPoint.end(document, Path.ofNull());
      } else {
        //没有任何内容，在位置为第一个位置
        at = Path.of([0]);
      }
      select = true;
    }

    // 标记为没有选区
    select ??= false;

    // 取一个具体的位置
    if (at is Range) {
      if (!hanging) {
        at = LocationRange.unhangRange(document, at);
      }

      if (at.isCollapsed()) {
        // 折叠了取第一个位置
        at = at.anchor;
      } else {
        // 取最后一个位置
        final rangeEdge = at.edges();
        final end = rangeEdge.end;
        final pointRef = EditorRef.makePointRef(document, end);
        // 删除这里面的文本 TODO
        TextTransforms.delete(document, atl: at);
        at = pointRef.unRef();
      }
    }

    // 根据节点内容，设置查找节点的条件
    if (at is Point) {
      if (match == null) {
        if (KText.isText(firstNode)) {
          match = ({Node? node, Path? path}) => KText.isText(node!);
        } else if (KElement.isInline(firstNode)) {
          match = ({Node? node, Path? path}) =>
              KText.isText(node!) || EditorCondition.isInline(document, node);
        } else {
          match = ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!);
        }
      }

      // 找到所有符合条件的节点
      final entryList = LocationPathEntry.nodes(
        document,
        at: at.path,
        match: match,
        mode: mode,
        voids: voids,
      );

      if (entryList.isNotEmpty) {
        final entry = entryList.first;
        final matchPath = entry.path;
        final pathRef = EditorRef.makePathRef(document, matchPath);
        final isAtEnd = EditorCondition.isEnd(document, at, matchPath);
        NodeTransforms.splitNodes(document,
            atl: at, match: match, mode: mode, voids: voids);
        final path = pathRef.unRef();
        at = isAtEnd ? path!.next() : path;
      } else {
        return;
      }
    }

    final parentPath = (at! as Path).parent();
    var index = (at as Path).last;

    if (!voids && LocationPathEntry.voids(document, at: parentPath) != null) {
      return;
    }

    for (final node in nodes) {
      final path = Path.of(parentPath.followedBy([index]));
      index++;
      document.apply(InsertNodeOperation(path: path, node: node));
    }

    // 把新的选择位置放在新插入的节点后面
    if (select == true) {
      final point = LocationPoint.end(document, at);
      SelectionTransforms.select(document, point);
    }
  });
}


