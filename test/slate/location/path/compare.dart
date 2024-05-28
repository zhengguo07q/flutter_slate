import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.compare', (){
    test('root', () {
      final path = Path([0, 1, 2]);
      final another = Path([]);
      final comparePath = path.compare(another);
      expect(comparePath, 0);
    });
    test('above', () {
      final path = Path([0, 1, 2]);
      final another = Path([0]);
      final comparePath = path.compare(another);
      expect(comparePath, 0);
    });
    test('after', () {
      final path = Path([1, 1, 2]);
      final another = Path([0]);
      final comparePath = path.compare(another);
      expect(comparePath, 1);
    });
    test('before', () {
      final path = Path([0, 1, 2]);
      final another = Path([1]);
      final comparePath = path.compare(another);
      expect(comparePath, -1);
    });
    test('below', () {
      final path = Path([0]);
      final another = Path([0, 1]);
      final comparePath = path.compare(another);
      expect(comparePath, 0);
    });
    test('equal', () {
      final path = Path([0, 1, 2]);
      final another = Path([0, 1, 2]);
      final comparePath = path.compare(another);
      expect(comparePath, 0);
    });

  });

}