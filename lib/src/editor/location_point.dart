import 'package:slate/slate.dart';
import '../utils/string.dart';

class LocationPoint {
  /// 得到给定的位置后面的点。
  static Point? after(Document document, Location at,
      {int? distance, Unit? unit, bool voids = false}) {
    distance = distance ?? 1;
    // 开始的点的最后位置
    final anchor = LocationPoint.point(document, at, edge: Edge.end);
    // 结束的点， 整个区域的最后一个位置，文档就是围挡结束
    final focus = LocationPoint.end(document, Path.ofNull());
    final range = Range(anchor: anchor, focus: focus);

    var d = 0;
    Point? target;

    for (final p
        in LocationPoint.positions(document, at: range, unit: unit, voids: voids)) {
      if (d > distance) {
        break;
      }

      if (d != 0) {
        target = p;
      }

      d++;
    }

    return target;
  }

  /// 找到文档给定位置的前一个文本字符的位置， 可能跨节点
  static Point? before(Document document, Location at,
      {int? distance, Unit? unit, bool voids = false}) {
    distance = distance ?? 1;
    final anchor = LocationPoint.start(document, Point.ofNull());
    final focus = LocationPoint.point(document, at);
    final range = Range(anchor: anchor, focus: focus);
    var d = 0;
    Point? target;

    for (final p in LocationPoint.positions(document,
        at: range, reverse: true, unit: unit, voids: voids)) {
      if (d > distance) {
        break;
      }

      if (d != 0) {
        target = p;
      }
      d++;
    }

    return target;
  }


  /// 获取位置的起点。
  static Point start(Document document, Location at) {
    return LocationPoint.point(document, at);
  }


  /// 获取一个位置的终点。
  static Point end(Document document, Location at) {
    return LocationPoint.point(document, at, edge: Edge.end);
  }

  /// 把任意给定的位置转换成为开始或结束的点。
  ///
  /// 取需要的树的最左边第一个节点的0位置，或者取最右边最后一个节点的length位置
  /// 最终的节点一定要是文本节点
  static Point point(Document document, Location at, {Edge edge = Edge.start}) {
    if (at is Path) {
      Path path;
      if (edge == Edge.end) {
        final lastNode = document.last(at);
        path = lastNode.path;
      } else {
        final firstNode = document.first(at);
        path = firstNode.path;
      }

      final node = document.get(path);

      assert(KText.isText(node),
      'Cannot get the $edge point in the node at path [$at] because it has no $edge single node.');
      return Point(
          path: path, offset: edge == Edge.end ? node.text!.length : 0);
    }

    if (at is Range) {
      final rangeEdge = at.edges();
      return edge == Edge.start ? rangeEdge.start : rangeEdge.end;
    }

    return at as Point;
  }

  /// 返回 `at` 范围内可以放置 [Point] 的所有位置。
  ///
  /// 默认情况下，一次向前移动单个偏移量，但可以使用 [unit] 选项按字符、单词、行或块移动。
  /// [reverse] 选项可用于更改迭代方向。
  /// 注意：默认情况下，void=true 节点被视为单个点，除非您为 [voids] 选项传入 true，否则不会在其内容内发生迭代，然后会发生迭代。
  static Iterable<Point> positions(Document document,
      {Location? at,
        Unit? unit,
        bool reverse = false,
        bool voids = false}) sync* {
    at = at ?? document.selection;
    unit = unit ?? Unit.offset;

    // 算法注释：
    //
    // 每一步“距离”都是动态的，具体取决于底层文本和指定的“单位”。
    // 每个步骤，例如一行或一个单词，可能跨越多个文本节点，因此我们在 step-sync 中在两个级别上迭代文本：
    //    `leafText` 将文本存储在文本叶级别，并通过使用计数器 `leafTextOffset` 和 `leafTextRemaining` 进行推进。
    //    `blockText` 将文本存储在块级别，每次前进时都会缩短 `distance`。
    //
    // 我们只维护一个blockText 和一个leafText 的窗口，
    // 因为一个块节点总是出现在它的所有叶节点之前。
    if (at == null) {
      return;
    }
    // 计算文本距离
    int calcDistance(String text, Unit unit) {
      if (unit == Unit.character) {
        return getCharacterDistance(text);
      } else if (unit == Unit.word) {
        return getWordDistance(text);
      } else if (unit == Unit.line || unit == Unit.block) {
        return text.length;
      }
      return 1;
    }

    // 方向和位置
    final range = LocationRange.range(document, at);
    final rangeEdge = range.edges();
    final start = rangeEdge.start;
    final end = rangeEdge.end;
    final first = reverse ? end : start;

    var isNewBlock = false;
    var blockText = '';
    var distance = 0; // LeafText 赶上块 Text 的距离。
    var leafTextRemaining = 0;
    var leafTextOffset = 0;

    // 遍历范围内的所有节点，获取整个文本内容blockText 中的块节点和leafText 中的文本节点。
    // 利用节点以这样一种方式排序的事实，我们首先遇到块节点，然后是它的所有文本节点，
    // 所以在遍历 blockText 和 LeafText 时，我们只需要分别记住一个块节点和一个叶子节点的窗口。
    for (final nodeEntry
    in LocationPathEntry.nodes(document, at: at, reverse: reverse, voids: voids)) {
      final node = nodeEntry.node;
      final path = nodeEntry.path;
      // ELEMENT NODE -为空元素提供位置，为块收集blockText
      if (KElement.isElement(node)) {
        // Void节点是一种特殊情况，所以在默认情况下，我们总是会给出它们的第一个点。
        // 如果' void '选项设置为true，那么我们将遍历它们的内容。
        if (!voids && KElement.isVoid(node)) {
          yield LocationPoint.start(document, path);
          continue;
        }

        // 内联元素节点被忽略，因为它们本身不会对' blockText '或' leafText '做出贡献——它们的父节点和子节点做贡献。
        if (KElement.isInline(node)) continue;

        // 块元素节点-设置' blockText '为其文本内容。
        if (EditorCondition.hasInlines(document, node)) {
          // 在遇到一个新的节点之前，我们总是会把它排完:
          //   console.assert(blockText === '',
          //     `blockText='${blockText}' - `+
          //     `not exhausted before new extension node`, path)

          // 在开始/结束边缘的情况下，当block扩展超出range时，确保考虑的范围被限制为' range '。与此等价，但可能性能更好:
          //   blockRange = Editor.range(main, ...Editor.edges(main, path))
          //   blockRange = Range.intersection(range, blockRange) // intersect
          //   blockText = Editor.string(main, blockRange, { voids })
          final e = path.isAncestor(end.path)
              ? end
              : LocationPoint.end(document, path);
          final s = path.isAncestor(start.path)
              ? start
              : LocationPoint.start(document, path);

          blockText =
              EditorContent.string(document, Range(anchor: s, focus: e), voids: voids);
          blockText = reverse ? reverseText(blockText) : blockText;
          isNewBlock = true;
        }
      }

      // TEXT LEAF NODE -迭代文本内容，根据“单位”生成每个“距离”偏移的位置。
      if (KText.isText(node)) {
        final isFirst = path.equals(first.path);

        // 我们总是在遇到新的文本节点之前耗尽文本节点的证明:
        //   console.assert(leafTextRemaining <= 0,
        //     `leafTextRemaining=${leafTextRemaining} - `+
        //     `not exhausted before new leaf single node`, path)

        // 为新文本节点重置' leafText '计数器。
        if (isFirst) {
          leafTextRemaining =
          reverse ? first.offset : node.text!.length - first.offset;
          leafTextOffset = first.offset; // Works for reverse too.
        } else {
          leafTextRemaining = node.text!.length;
          leafTextOffset = reverse ? leafTextRemaining : 0;
        }

        // 节点开始的屈服位置(可能)。
        if (isFirst || isNewBlock || unit == Unit.offset) {
          yield Point(path: path, offset: leafTextOffset);
          isNewBlock = false;
        }

        // 每(动态计算的)收益率位置“距离”抵消。
        while (true) {
          // 如果' leafText '已经追上了' blockText ' (distance=0)，
          // 如果blockText已耗尽，则中断以获取另一个块节点，
          // 否则将blockText向前推进新的' distance '。
          if (distance == 0) {
            if (blockText == '') break;
            distance = calcDistance(blockText, unit);
            blockText = blockText.substring(distance);
          }

          // 将' leafText '按当前' distance '前进。
          leafTextOffset =
          reverse ? leafTextOffset - distance : leafTextOffset + distance;
          leafTextRemaining -= distance;

          // 如果' leafText '被耗尽，break以获得一个新的叶子节点，并将距离设置为溢出量，因此我们(可能)将赶上下一个叶子文本节点的blockText。
          if (leafTextRemaining < 0) {
            distance = -leafTextRemaining;
            break;
          }

          // 成功地通过' leafText '移动' distance '偏移量来追赶' blockText '，所以我们可以重置' distance '并在这个节点中产生这个位置。
          distance = 0;
          yield Point(path: path, offset: leafTextOffset);
        }
      }
    }
    //证明在完成时，我们已经耗尽了叶子和块文本:
    //控制台。assert(leafTextRemaining &lt;= 0，“leafText没有耗尽”)
    //控制台。assert(blockText === "， "blockText没有耗尽")
    //辅助:
    //返回长度为' unit '的步长的偏移量。
  }
}
