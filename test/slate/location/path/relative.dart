import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.relative', (){
    test('grandparent', () {
      final path = Path.of([0, 1, 2]);
      final another = Path.of([0]);
      final result = path.relative(another);
      expect(result, equals([1, 2]));
    });

    test('parent', () {
      final path = Path.of([0, 1]);
      final another = Path.of([0]);
      final result = path.relative(another);
      expect(result, equals([1]));
    });

    test('root', () {
      final path = Path.of([0, 1]);
      final another = Path.of([]);
      final result = path.relative(another);
      expect(result, equals([0, 1]));
    });

  });

}