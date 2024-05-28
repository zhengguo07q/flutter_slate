import '../operation/_operation.dart';
import '../types.dart';
import 'point.dart';

typedef UnRefFunction = Point? Function(PointRef ref);

/// 当新操作应用到编辑器时，[PointRef]对象使文档中的特定点的信息随时间同步
///
/// 您可以在任何时候访问它们的[current]属性以获取最新的点值。
class PointRef {
  PointRef(this.current, this.affinity, this._unRef);
  Point? current;
  Affinity? affinity;
  final UnRefFunction _unRef;

  Point? unRef() {
    return _unRef(this);
  }

  /// 通过操作转换点ref的当前值。
  void transform(Operation op) {
    assert(() {
      op.debugTransformPointList!.add(this);
      return true;
    }());

    if (current == null) {
      return;
    }
    final point = op.transformPoint(current!, affinity: affinity);
    current = point;

    if (point == null) {
      _unRef(this);
    }
  }

  @override
  String toString() {
    return '${current} + $affinity';
  }
}
