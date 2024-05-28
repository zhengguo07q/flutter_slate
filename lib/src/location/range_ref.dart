import '../operation/_operation.dart';
import '../types.dart';
import 'range.dart';

typedef UnRefFunction = Range? Function(RangeRef ref);

/// 当新操作应用到编辑器时，[RangeRef]对象使文档中的特定范围的信息随时间同步
///
/// 您可以随时访问它们的[current]属性以获取最新的范围值。
class RangeRef {
  RangeRef(this.current, this.affinity, this._unRef);

  Range? current;
  Affinity? affinity;
  final UnRefFunction _unRef;

  Range? unRef() {
    return _unRef(this);
  }

  /// 通过操作转换范围[ref]的当前值。
  void transform(Operation op) {
    assert((){
      op.debugTransformRangeList!.add(this);
      return true;
    }());
    if (current == null) {
      return;
    }

    final path = op.transformRange(current!, affinity: affinity);
    current = path;

    if (path == null) {
      unRef();
    }
  }

  @override
  String toString() {
    return '${current} + $affinity';
  }
}
