import 'package:slate/slate.dart';
import 'package:common/common.dart';

class RangeEdge {
  RangeEdge(this.start, this.end);

  Point start;
  Point end;
}

/// [Range]对象是特定跨度的点集合
///
/// 表示一个包含节点与文本节点的一部分的 文档片段。俗称拖蓝
/// 范围的两个点是必然是存在于文本节点上的
class Range with Location {
  Range({required this.anchor, required this.focus});

  factory Range.ofNull() {
    return Range(anchor: Point.ofNull(), focus: Point.ofNull());
  }

  /// 没有选择的状态，就是默认值
  ///
  /// 默认的时候选择位置为[], 位置为-1
  factory Range.ofCollapsedNotSelection() {
    return Range(
        anchor: Point.of(Path.of([]), -1), focus: Point.of(Path.of([]), -1));
  }

  factory Range.of(
      {required Iterable<int> anchorPath,
      required int anchorOffset,
      required Iterable<int> focusPath,
      required int focusOffset}) {
    return Range(
        anchor: Point.of(anchorPath, anchorOffset),
        focus: Point.of(focusPath, focusOffset));
  }

  factory Range.ofPoint(Point anchor, Point focus) {
    return Range(anchor: anchor, focus: focus);
  }

  factory Range.ofCollapsed(
      {required Iterable<int> path, required int offset}) {
    return Range(anchor: Point.of(path, offset), focus: Point.of(path, offset));
  }

  factory Range.ofCollapsedPoint(Point collapsed) {
    return Range.ofCollapsed(path: collapsed.path, offset: collapsed.offset);
  }

  /// 指向用户开始选择的地方
  late Point anchor;

  /// 指向用户结束选择的地方
  late Point focus;

  /// 用来临时存选择属性
  late Map<String, String>? attributes = null;

  bool get isValid {
    if (anchor.path.length > 0 || focus.path.length > 0) return true;
    return false;
  }

  Range copy() {
    final range = Range.of(
        anchorPath: anchor.path,
        anchorOffset: anchor.offset,
        focusPath: focus.path,
        focusOffset: focus.offset)
      ..attributes = attributes;
    return range;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Range && anchor == other.anchor && focus == other.focus)
      return true;
    return false;
  }

  @override
  String toString() {
    return '(anchor: Point.of$anchor, focus: Point.of$focus)';
  }

  String toShortString() {
    return '${anchor.toShortString()}, ${focus.toShortString()}';
  }

  /// 获取范围的起始点和结束点，按它们在文件中出现的顺序
  RangeEdge edges({bool reverse = false}) {
    final anchor = this.anchor;
    final focus = this.focus;
    return this.isBackward() == reverse
        ? RangeEdge(anchor, focus)
        : RangeEdge(focus, anchor);
  }

  /// 得到一个范围的起始点。
  Point start() {
    final rangeList = this.edges();
    return rangeList.start;
  }

  /// 得到一个范围的结束点
  Point end() {
    final rangeList = this.edges();
    return rangeList.end;
  }

  /// 检查一个范围是否恰好等于另一个
  bool equals(Range another) {
    return this.anchor.equals(another.anchor) &&
        this.focus.equals(another.focus);
  }

  /// 检查一个范围是否包含一个路径、一个点或另一个范围的一部分。
  bool includes(Location target) {
    if (this.noSelection()) {
      return false;
    }
    if (target is Range) {
      if (this.includes(target.anchor) || this.includes(target.focus)) {
        return true;
      }

      final r = this.edges();
      final t = target.edges();
      return r.start.isBefore(t.start) && r.end.isAfter(t.end);
    }

    final edge = this.edges();
    var isAfterStart = false;
    var isBeforeEnd = false;

    if (target is Point) {
      isAfterStart = target.compare(edge.start) >= 0;
      isBeforeEnd = target.compare(edge.end) <= 0;
    } else {
      target = target as Path;
      isAfterStart = target.compare(edge.start.path) >= 0;
      isBeforeEnd = target.compare(edge.end.path) <= 0;
    }

    return isAfterStart && isBeforeEnd;
  }

  /// 求一个范围与另一个范围的交点
  Range? intersection(Range another) {
    final rangeEdges = this.edges();
    final s1 = rangeEdges.start;
    final e1 = rangeEdges.end;
    final anotherEdges = another.edges();
    final s2 = anotherEdges.start;
    final e2 = anotherEdges.end;
    final start = s1.isBefore(s2) ? s2 : s1;
    final end = e1.isBefore(e2) ? e1 : e2;

    if (end.isBefore(start)) {
      return null;
    } else {
      return Range(anchor: start, focus: end);
    }
  }

  /// 取公共的路径
  Path common(){
    return anchor.path.common(focus.path);
  }

  /// 检查范围是否向后，这意味着它的定位点出现在文档在它的焦点之后。
  ///
  /// 正常拖拽的方式， 向后
  bool isBackward() {
    return this.anchor.isAfter(this.focus);
  }

  /// 检查一个范围是否向前。
  ///
  /// 与[isBackward]相反，为了便于阅读。
  bool isForward() {
    return !this.isBackward();
  }

  /// 检查范围是否闭合，这意味着它的锚和焦点是文件中完全相同的位置。
  bool isCollapsed() {
    return this.anchor.equals(this.focus);
  }

  /// 检查一个范围是否展开。
  ///
  /// 与[isCollapsed]相反，为了便于阅读。
  bool isExpanded() {
    return !this.isCollapsed();
  }

  /// 检查是否有值实现了[Range]接口。
  bool isRange(Location value) {
    return value is Range;
  }

  /// 遍历范围内的所有点条目。
  ///
  /// 很多逻辑需要对这两个节点进行相同的处理, 所以需要作为范围点来进行执行逻辑
  /// 这里不可以更改.
  Iterable<PointEntry> points() sync* {
    yield PointEntry(this.anchor, 'anchor');
    yield PointEntry(this.focus, 'focus');
  }

  bool noSelection() {
    if (this.focus.path.length == 0 && this.focus.offset == -1) {
      return true;
    }
    return false;
  }

  Range inner() {
    return Range(
      anchor: Point(path: anchor.path.inner(), offset: anchor.offset),
      focus: Point(path: focus.path.inner(), offset: focus.offset),
    );
  }
}
