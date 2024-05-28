import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.common', (){
    test('equal', () {
      final path = Path([0, 1, 2]);
      final another = Path([0, 1, 2]);
      final commonPath = path.common(another);
      expect(commonPath, equals([0, 1, 2]));
    });
    test('root', () {
      final path = Path([0, 1, 2]);
      final another = Path([3, 2]);
      final commonPath = path.common(another);
      expect(commonPath, equals(<int>[]));
    });
    test('success', () {
      final path = Path([0, 1, 2]);
      final another = Path([0, 2]);
      final commonPath = path.common(another);
      expect(commonPath, equals([0]));
    });
  });
}