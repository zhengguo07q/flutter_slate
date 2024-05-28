import 'dart:math' as math;

import 'package:quiver/collection.dart';

import '_location.dart';

/// ' Path '数组是一个索引列表，用于描述一个节点在Slate节点树中的确切位置。
///
/// 路径代表的其实就是节点, 所有的函数都是, XX节点和XX节点等
/// 尽管它们通常相对于根“Editor”对象，但它们也可以相对于任何“Node”对象。
class Path extends DelegatingList<int> with Location {
  Path(this.list);

  factory Path.of(Iterable<int> elements, {bool growable = true}) {
    return Path(List.of(elements, growable: growable));
  }

  factory Path.ofNull() {
    return Path([]);
  }

  final List<int> list;

  bool isRoot() {
    if (list.isEmpty) {
      return true;
    }
    return false;
  }

  Path copy() {
    return Path.of(List.from(list));
  }

  Path copyWith({
    required final List<int> list,
  }) {
    return Path(
      list,
    );
  }

  @override
  List<int> get delegate => list;

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(covariant Path other) {
    if (identical(this, other) || listsEqual(list, other.list)) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return delegate.toString();
  }

  /// 获取给定路径的祖先路径列表。
  ///
  /// 路径是从最深的祖先到最浅的祖先分类的。如果[revers]: true '选项被传递，它们被反转。
  /// [0, 1, 2]=>[[], [0], [0, 1]]
  List<Path> ancestors({bool reverse = false}) {
    var paths = this.levels(reverse: reverse);

    if (reverse) {
      paths = paths.sublist(1); //排除掉列表里第一个后的结果
    } else {
      paths = paths.sublist(0, paths.length - 1); // 排除掉列表里第一个的结果
    }
    return paths;
  }

  /// 获取两个路径的共同祖先路径
  ///
  /// [0, 1, 2] [0, 3] => [0]
  Path common(Path another) {
    final common = Path([]);

    for (var i = 0; i < this.length && i < another.length; i++) {
      final av = this[i];
      final bv = another[i];

      if (av != bv) {
        break;
      }

      common.add(av);
    }
    return common;
  }

  /// 前面是1， 相同是0， 后面是-1
  /// 将一个路径与另一个路径进行比较，返回一个整数
  /// 指示路径是在另一个路径之前，在另一个路径之前，还是在另一个路径之后。
  ///
  /// 注意:两个长度不等的路径仍然可以收到一个' 0 '结果，
  /// 如果一个直接在另一个的上面或下面。如果需要精确匹配，请使用[Path.equals]。
  /// [1, 1, 2] [1] => 0
  /// [1, 1, 2] [0] => 1
  /// [1, 1, 2] [2] => -1
  int compare(Path another) {
    // 都是从根节点起始的, 从根节点开始找就行了
    final min = math.min(this.length, another.length);

    for (var i = 0; i < min; i++) {
      if (this[i] < another[i]) return -1;
      if (this[i] > another[i]) return 1;
    }

    return 0;
  }

  /// 检查路径是否在另一个索引的后面
  ///
  /// 取之前的比较相等性，然后再取最后一个
  /// [1] [0, 2] => true
  bool endsAfter(Path another) {
    final i = this.length - 1;
    final as = Path(this.sublist(0, i));
    final bs =
        Path(another.sublist(0, i < another.length ? i : another.length));
    final av = this[i];
    final bv = i < another.length ? another[i] : -1;
    return as.equals(bs) && av > bv;
  }

  /// 检查路径是否在另一个索引中的一个索引处结束。
  ///
  /// 取path相同的长度, 然后比较是否完全相等
  /// [0] [0, 1] => true
  /// [0] [0, 2] => true
  bool endsAt(Path another) {
    final i = this.length;
    final as = Path(this.sublist(0, i));
    final bs =
        Path(another.sublist(0, i < another.length ? i : another.length));
    return as.equals(bs);
  }

  /// 检查路径是否在另一个索引中的一个索引之前。
  ///
  /// 取相同长度,然后是否在它前面
  /// [0], [1, 2] => true
  bool endsBefore(Path another) {
    // 取当前节点父路径
    final i = this.length - 1;
    final as = Path(this.sublist(0, i));
    // 取与当前父路径匹配的路径，短的话取全部， 长的话取当前父路径长度
    final bs =
        Path(another.sublist(0, i < another.length ? i : another.length));
    final av = this[i];
    final bv = i < another.length ? another[i] : -1;
    return as.equals(bs) && av < bv;
  }

  /// 检查一条路径是否与另一条路径完全相等。
  bool equals(Path another) {
    var i = 0;
    return this.length == another.length &&
        this.every((n) {
          i++;
          return n == another[i - 1];
        });
  }

  /// 检查前一个同级节点的路径是否存在
  bool hasPrevious() {
    if (this.isNotEmpty) {
      return this.last > 0;
    }
    return false;
  }

  /// 检查路径是否在其他路径之后。
  bool isAfter(Path another) {
    return this.compare(another) == 1;
  }

  /// 检查一个路径是否是另一个路径的祖先。
  /// [0] [0, 1] => true
  bool isAncestor(Path another) {
    return this.length < another.length && this.compare(another) == 0;
  }

  /// 检查路径是否在其他路径之前。
  ///
  /// [0, 1, 2] [1] =>true
  bool isBefore(Path another) {
    return this.compare(another) == -1;
  }

  /// 检查一个路径是否是另一个路径的子路径。
  bool isChild(Path another) {
    return this.length == another.length + 1 &&
        this.compare(another) == 0;
  }

  /// 检查一个路径是否等于另一个路径的祖先。
  bool isCommon(Path another) {
    return this.length <= another.length && this.compare(another) == 0;
  }

  /// 检查一个路径是否是另一个路径的后代。
  bool isDescendant(Path another) {
    return this.length > another.length && this.compare(another) == 0;
  }

  /// 检查一个路径是否是另一个路径的父路径。
  bool isParent(Path another) {
    return this.length + 1 == another.length &&
        this.compare(another) == 0;
  }

  /// 检查一个路径是否为另一个的兄弟路径。
  bool isSibling(Path another) {
    if (this.length != another.length) {
      return false;
    }

    final as = Path(this.sublist(0, this.length - 1));
    final bs = Path(another.sublist(0, another.length - 1));
    final al = this.last;
    final bl = another.last;
    return al != bl && as.equals(bs);
  }

  /// 取节点上每个节点的路径
  ///
  /// 获取每一层的路径列表。注意:这与[Path]相同。祖先的，但包括路径本身。
  /// 一般有n+1个长度的列表，包含了[]列表
  /// 路径从最浅到最深排序。但是，如果传递了[reverse] true 选项，它们将被反转。
  /// [0, 1, 2, 4, 2] => [[],[0],[0,1],[0,1,2],[0,1,2,4],[0,1,2,4,2]]
  List<Path> levels({bool reverse = false}) {
    final list = <Path>[];

    for (var i = 0; i <= this.length; i++) {
      list.add(Path(this.sublist(0, i)));
    }

    if (reverse) {
      return List.of(list.reversed);
    }
    return list;
  }

  /// 给定一个路径，获取到下一个兄弟节点的路径。
  Path next() {
    assert(this.isNotEmpty,
        'Cannot get the next path of a root path [$this], because it has no next index.');

    final last = this.last;
    return Path(this.sublist(0, this.length - 1)..add(last + 1));
  }

  /// 给定一个路径，返回一个引用它上面父节点的新路径。
  ///
  /// [0, 1] => [0]
  Path parent() {
    assert(this.isNotEmpty,
        'Cannot get the parent path of the root path [$this].');
    return Path(this.sublist(0, this.length - 1));
  }

  /// 给定一个路径，获取上一个兄弟节点的路径。
  /// [0, 0, 3] => [0, 0, 2]
  Path previous() {
    assert(this.isNotEmpty,
        'Cannot get the previous path of a root path [$this], because it has no previous index.');
    final last = this.last;
    // 最后一个位置必须>0,这样才会有前一个兄弟
    assert(last > 0,
        'Cannot get the previous path of a first child path [$this] because it would result in a negative index.');

    return Path.of(this.sublist(0, this.length - 1)..add(last - 1));
  }

  /// 获取一个相对于祖先的路径。
  Path relative(Path ancestor) {
    assert(ancestor.isAncestor(this) || this.equals(ancestor),
        'Cannot get the relative path of [$this] inside ancestor [$ancestor], because it is not above or equal to the path.');
    return Path(this.sublist(ancestor.length));
  }

  /// 获取持有ID的顶层路径
  Path top() {
    return Path(this.sublist(0, 1));
  }

  Path inner(){
    return Path(list.sublist(1));
  }
}
