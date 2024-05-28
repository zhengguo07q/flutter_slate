import '_location.dart';
import 'path.dart';

class PointEntry {
  PointEntry(this.point, this.position);
  late Point point;
  String position;
}

/// “点”对象指的是石板中文本节点中的特定位置
///
/// 文档。它的路径指的是节点在树中的位置，而它的 [offset]表示到节点文本字符串的距离。
/// 点可以只参考“文本”节点。
/// 点的节点是必然存在文本节点里面的
class Point with Location {
  Point({required this.path, required this.offset});

  /// 得到一个起始点的位置
  factory Point.ofNull() {
    return Point(path: Path.ofNull(), offset: 0);
  }

  factory Point.of(Iterable<int> path, int offset){
    return Point(path: Path.of(path), offset: offset);
  }


  late Path path;
  late int offset;

  /// 是否为起始点
  bool isRoot(){
    if(path.isRoot() && offset == 0) {
      return true;
    }
    return false;
  }


  Point copy(){
    return Point.of(path,  offset);
  }


  @override
  bool operator ==(Object other){
    if(identical(this, other) ) {
      return true;
    }
    if(other is Point && path == other.path && offset == other.offset) {
      return true;
    }
    return false;
  }

  @override
  String toString(){
    return '(path: Path.of($path), offset:$offset)';
  }

  String toShortString(){
    return '$path : $offset';
  }

  /// 将一个点与另一个点进行比较，返回一个整数表示是否
  /// point在另一个之前，在，或在另一个之后。
  int compare(Point another) {
    final result = this.path.compare(another.path);

    if (result == 0) {
      if (this.offset < another.offset) return -1;
      if (this.offset > another.offset) return 1;
      return 0;
    }

    return result;
  }

  /// 检查一个点是否在另一个点之后。
  bool isAfter(Point another) {
    return this.compare(another) == 1;
  }

  /// 检查一个点是否在另一个点之前。
  bool isBefore(Point another) {
    return this.compare(another) == -1;
  }

  /// 检查一个点是否与另一个点完全相等。
  bool equals(Point another) {
    return this.offset == another.offset &&
        this.path.equals(another.path);
  }


  /// 判断是否没用赋值
  bool isNull(){
    return this == Point.ofNull();
  }

  Point inner(){
    return Point(path: path.inner(), offset: offset);
  }
}
