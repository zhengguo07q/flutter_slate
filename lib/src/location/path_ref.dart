import 'package:slate/src/operation/_operation.dart';

import '../types.dart';
import 'path.dart';

typedef UnRefFunction = Path? Function(PathRef ref);

/// 当新的操作应用到编辑器时，[PathRef]对象使文档中的特定路径的信息随时间同步。
///
/// 您可以随时访问它们的[current]属性，以获取最新的路径值。
class PathRef {
  PathRef(this.current, this.affinity, this._unRef);
  Path? current;
  Affinity? affinity;
  final UnRefFunction _unRef;

  Path? unRef(){
    return _unRef(this);
  }

  /// 通过操作转换路径ref的当前值。
  void transform(Operation op) {
    assert((){
      op.debugTransformPathList!.add(this);
      return true;
    }());
    if (current == null) {
      return;
    }

    final path = op.transformPath(current!, affinity: affinity);
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
