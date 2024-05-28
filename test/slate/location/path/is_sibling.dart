import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.isSibling',(){
    test('above', (){
      final path = Path.ofNull();
      final another = Path.of([0, 1]);
      final result = path.isSibling(another);
      expect(result, false);
    });
    test('after-sibling', (){
      final path = Path.of([1,4]);
      final another = Path.of([1, 2]);
      final result = path.isSibling(another);
      expect(result, true);
    });

    test('after', (){
      final path = Path.of([1, 2]);
      final another = Path.of([0]);
      final result = path.isSibling(another);
      expect(result, false);
    });
    test('before-sibling', (){
      final path = Path.of([0, 1]);
      final another = Path.of([0, 3]);
      final result = path.isSibling(another);
      expect(result, true);
    });
    test('before', (){
      final path = Path.of([0, 1]);
      final another = Path.of([1]);
      final result = path.isSibling(another);
      expect(result, false);
    });
    test('below', (){
      final path = Path.of([0,  2]);
      final another = Path.of([0]);
      final result = path.isSibling(another);
      expect(result, false);
    });
    test('equal', (){
      final path = Path.of([0, 1, 2]);
      final another = Path.of([0, 1, 2]);
      final result = path.isSibling(another);
      expect(result, false);
    });
  });
}