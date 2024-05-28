import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.isParent',(){
    test('above-grandparent', (){
      final path = Path.ofNull();
      final another = Path.of([0, 1]);
      final result = path.isParent(another);
      expect(result, false);
    });
    test('above-parent', (){
      final path = Path.of([0]);
      final another = Path.of([0, 1]);
      final result = path.isParent(another);
      expect(result, true);
    });

    test('after', (){
      final path = Path.of([1, 1, 2]);
      final another = Path.of([0]);
      final result = path.isParent(another);
      expect(result, false);
    });
    test('before', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([1]);
      final result = path.isParent(another);
      expect(result, false);
    });
    test('below', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([0]);
      final result = path.isParent(another);
      expect(result, false);
    });
    test('equal', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([0, 1, 2]);
      final result = path.isParent(another);
      expect(result, false);
    });
  });
}