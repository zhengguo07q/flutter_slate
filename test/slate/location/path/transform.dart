import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/operation/move_node_op.dart';

void main(){
  group('path.transform', (){
    test('ancestor-sibling-ends-after-to-ancestor', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([4]), newPath:  Path.of([3]));
      final output = op.transformPath(path);
      expect(output, equals([4,3, 3]));
    });
    test('ancestor-sibling-ends-after-to-ends-after', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([4]), newPath:  Path.of([2]));
      final output = op.transformPath(path);
      expect(output, equals([4,3, 3]));
    });
    test('ancestor-sibling-ends-before-to-ancestor', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([2]), newPath:  Path.of([3]));
      final output = op.transformPath(path);
      expect(output, equals([2, 3, 3]));
    });
    test('ancestor-sibling-ends-before-to-ends-after', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([2]), newPath:  Path.of([4]));
      final output = op.transformPath(path);
      expect(output, equals([2, 3, 3]));
    });
    test('ancestor-to-ends-after', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([3]), newPath:  Path.of([5, 1]));
      final output = op.transformPath(path);
      expect(output, equals([4, 1, 3, 3]));
    });
    test('ancestor-to-ends-before', () {
      final path = Path.of([3, 3, 3]);
      final op = MoveNodeOperation(path: Path.of([3]), newPath:  Path.of([2, 5]));
      final output = op.transformPath(path);
      expect(output, equals([2, 5, 3, 3]));
    });
  });

}