import 'package:slate/slate.dart';

class LocationPathEntry {
  /// 获取位置上的第一个节点。
  static PathEntry first(Document document, Location at) {
    final path = LocationPathEntry.path(document, at, edge: Edge.start);
    return LocationPathEntry.node(document, path);
  }

  /// 获取位置上的最后一个节点。
  static PathEntry last(Document document, Location at) {
    final path = LocationPathEntry.path(document, at, edge: Edge.end);
    return LocationPathEntry.node(document, path);
  }


  /// 获取一个位置上的叶文本节点。
  static PathEntry leaf(Document document, Location at,
      {int? depth, Edge? edge}) {
    final path = LocationPathEntry.path(document, at, depth: depth, edge: edge);
    final node = document.leaf(path);
    return PathEntry(node, path);
  }


  /// 获取位置的父节点。
  static PathEntry parent(Document document, Location at,
      {int? depth, Edge? edge}) {
    final path = LocationPathEntry.path(document, at, depth: depth, edge: edge);
    final parentPath = path.parent();
    final entry = LocationPathEntry.node(document, parentPath);
    return entry;
  }


  /// 匹配一个空属性节点。
  static PathEntry? voids(Document document,
      {Location? at, Mode? mode, bool voids = false}) {
    return LocationPathEntry.above(
      document,
      at: at,
      mode: mode,
      voids: voids,
      match: ({Node? node, Path? path}) => EditorCondition.isVoid(document, node!),
    );
  }

  /// 找到节点的位置。
  static PathEntry node(Document document, Location at,
      {int? depth, Edge? edge}) {
    final path = LocationPathEntry.path(document, at, depth: depth, edge: edge);
    final node = document.get(path);
    return PathEntry(node, path);
  }

  /// 迭代编辑器中的所有节点。
  static Iterable<PathEntry> nodes(Document document,
      {Location? at,
      NodeMatch? match,
      Mode? mode = Mode.all,
      bool universal = false,
      bool reverse = false,
      bool voids = false}) sync* {
    at = at ?? document.selection;

    // 匹配函数, 默认匹配成功所有
    match ??= ({Node? node, Path? path}) => true;

    if (at == null) {
      return;
    }

    // 明确一个匹配区域
    Path from;
    Path to;

    if (Location.isSpan(at)) {
      // 代表当前传递的是一个区间[Point, Point]
      at as Span;
      from = at.path1;
      to = at.path2;
    } else {
      // 计算范围获取到的区间
      final first = LocationPathEntry.path(document, at, edge: Edge.start);
      final last = LocationPathEntry.path(document, at, edge: Edge.end);
      from = reverse ? last : first;
      to = reverse ? first : last;
    }

    // 区间迭代函数， 如果有void的话，则判断是否为void;
    // void判断最开始迭代的时候进行
    final nodeEntries = document.nodes(
        reverse: reverse,
        from: from,
        to: to,
        pass: ({Node? node, Path? path}) {
          return voids ? false : EditorCondition.isVoid(document, node!);
        });

    // 区间匹配结果
    final matches = <PathEntry>[];
    PathEntry? hit;

    for (final entry in nodeEntries) {
      // 判断是否为上一次匹配节点的内部节点
      final isLower = hit != null && entry.path.compare(hit.path) == 0;

      // 在高模式下，低于最后一次命中的任何节点都不算匹配成功。
      // 匹配方式是先从父到孩子的， 如果新的路径属于之前的路径的低层路径，在highest模式下则丢弃
      if (mode == Mode.highest && isLower) {
        continue;
      }

      // 进行外部需求的匹配函数判断，匹配不成功执行这个，用于返回和跳出
      if (!match(node: entry.node, path: entry.path)) {
        // 如果我们到达的叶文本节点不低于最后一次命中，那么我们已经找到了一个不包含匹配的分支，这意味着匹配不是通用的。
        if (universal && !isLower && KText.isText(entry.node)) {
          return;
        } else {
          continue;
        }
      }

      // 如果匹配成功，并且是lowest状态，更新被匹配节点。
      if (mode == Mode.lowest && isLower) {
        hit = PathEntry(entry.node, entry.path);
        continue;
      }

      // 在lowest模式下，一旦它被保证最低，我们发射最后一次匹配。
      // 低位时候，高位的是不能被发射到外面的。
      final emit =
          mode == Mode.lowest ? hit : PathEntry(entry.node, entry.path);

      if (emit != null) {
        if (universal) {
          matches.add(emit);
        } else {
          yield emit;
        }
      }

      hit = PathEntry(entry.node, entry.path);
    }

    // 因为最低的总是落后一，最后就会赶上来。
    if (mode == Mode.lowest && hit != null) {
      if (universal) {
        matches.add(hit);
      } else {
        yield hit;
      }
    }

    // 通用延迟以确保匹配发生在每个分支中，因此我们在迭代后生成所有匹配。
    if (universal) {
      yield* matches;
    }
  }


  /// 获取文档分支中某个位置之前的匹配节点。
  static PathEntry? previous(Document document,
      {Location? at,
      NodeMatch? match,
      Mode? mode = Mode.lowest,
      bool voids = false}) {
    at = at ?? document.selection;

    if (at == null) {
      return null;
    }

    final pointBeforeLocation = LocationPoint.before(document, at, voids: voids);

    if (pointBeforeLocation == null) {
      return null;
    }

    final firstEntry = LocationPathEntry.first(document, Path([]));

    // 搜索位置是从文档的开始到位置传入之前的点的路径
    final span = Span(pointBeforeLocation.path, firstEntry.path);

    assert((at is Path) && at.length != 0, 'Cannot get the previous node from the root node!');

    if (match == null) {
      if (at is Path) {
        final parentEntry = LocationPathEntry.parent(document, at);
        match = ({Node? node, Path? path}) =>
            parentEntry.node.children.contains(node);
      } else {
        match = ({Node? node, Path? path}) => true;
      }
    }

    // 取反转后第一个位置
    final previous = LocationPathEntry.nodes(
      document,
      reverse: true,
      at: span,
      match: match,
      mode: mode,
      voids: voids,
    );

    return previous.first;
  }


  /// 在位置之后获取文档分支中的匹配节点。
  static PathEntry? next(Document document,
      {Location? at, NodeMatch? match, Mode? mode, bool voids = false}) {
    at = at ?? document.selection;
    if (at == null) {
      return null;
    }

    final pointAfterLocation = LocationPoint.after(document, at, voids: voids);

    if (pointAfterLocation == null) return null;

    final nodeEntry = LocationPathEntry.last(document, Path([]));

    final span = Span(pointAfterLocation.path, nodeEntry.path);

    assert(at is Path && at.isNotEmpty,
    'Cannot get the next node from the root node!');

    if (match == null) {
      if (at is Path) {
        final parentEntry = LocationPathEntry.parent(document, at);
        match = ({Node? node, Path? path}) =>
            parentEntry.node.children.contains(node!);
      } else {
        match = ({Node? node, Path? path}) => true;
      }
    }

    final nodeEntryList = LocationPathEntry.nodes(document,
        at: span, match: match, mode: mode, voids: voids);
    return nodeEntryList.first;
  }


  /// 获取文给定或选择位置上方的祖先节点
  static PathEntry? above(Document document,
      {Location? at,
        NodeMatch? match,
        Mode? mode = Mode.lowest,
        bool voids = false}) {
    at = at ?? document.selection;
    if (at == null) {
      return null;
    }

    final path = LocationPathEntry.path(document, at);
    // 低位的话，使用反转处理，从最里面开始
    // 一般情况下是反转的， 从最后一个开始处理
    final reverse = mode == Mode.lowest;

    for (final nodeEntry in LocationPathEntry.levels(
      document,
      at: path,
      voids: voids,
      match: match,
      reverse: reverse,
    )) {
      // 条目要求最后一个不等于条目位置，而且不能是文本
      if (!KText.isText(nodeEntry.node) && !path.equals(nodeEntry.path)) {
        return nodeEntry;
      }
    }
    return null;
  }


  /// 在某个位置遍历所有level。
  ///
  /// 这个位置是在一个根节点内部执行的
  /// 一般情况下， 遇到节点是void的则跳出处理，就是不处理后续，但是如果有设置voids 则继续处理voids
  static Iterable<PathEntry> levels(Document document,
      {Location? at, NodeMatch? match, bool reverse=false, bool voids=false}) sync* {
    at ??= document.selection;
    match ??= ({node, path}) => true;

    if (at == null) {
      return;
    }

    final levels = <PathEntry>[];
    final path = LocationPathEntry.path(document, at);

    for (final nodeEntry in document.levels(path)) {
      if (!match(node: nodeEntry.node, path: nodeEntry.path)) {
        continue;
      }

      levels.add(nodeEntry);
      if (!voids && EditorCondition.isVoid(document, nodeEntry.node)) {
        break;
      }
    }

    if (reverse == true) {
      yield* levels.reversed;
    }

    yield* levels;
  }

  /// 把其他所有定位转换成为路径
  ///
  /// [depth] 允许获取的从根节点到获取的子节点的最大深度
  /// [edge] 边缘
  static Path path(Document document, Location at, {int? depth, Edge? edge}) {
    // 路径，取开头，或结尾， 没有给定则就是at自身
    if (at is Path) {
      if (edge == Edge.start) {
        final firstNode = document.first(at);
        at = firstNode.path;
      } else if (edge == Edge.end) {
        final lastNode = document.last(at);
        at = lastNode.path;
      }
    }
    // 范围，取开头，结尾，没有则是公共部分
    if (at is Range) {
      if (edge == Edge.start) {
        at = at.start();
      } else if (edge == Edge.end) {
        at = at.end();
      } else {
        at = at.anchor.path.common(at.focus.path);
      }
    }
    // 点直接取路径
    if (at is Point) {
      at = at.path;
    }

    at as Path;
    // 路径要求的最大深度
    if (depth != null) {
      at = Path(at.sublist(0, depth));
    }

    return at;
  }
}
