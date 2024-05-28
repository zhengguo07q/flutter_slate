import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.isDescendant',(){
    test('above', (){
      final path = Path.of([0]);
      final another = Path.of([0, 1]);
      final result = path.isDescendant(another);
      expect(result, false);
    });
    test('after', (){
      final path = Path.of([1, 1, 2]);
      final another = Path.of([0]);
      final result = path.isDescendant(another);
      expect(result, false);
    });
    test('before', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([1]);
      final result = path.isDescendant(another);
      expect(result, false);
    });
    test('below-child', (){
      final path = Path.of([0, 1]);
      final another = Path.of([0]);
      final result = path.isDescendant(another);
      expect(result, true);
    });
    test('below-grandchild', (){
      final path = Path.of([0, 1]);
      final another = Path.ofNull();
      final result = path.isDescendant(another);
      expect(result, true);
    });
    test('equal', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([0, 1, 2]);
      final result = path.isChild(another);
      expect(result, false);
    });
  });
}