import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.isBefore',(){
    test('above', (){
      final path = Path([0, 1, 2]);
      final another = Path([0]);
      final result = path.isBefore(another);
      expect(result, false);
    });
    test('after', (){
      final path = Path([1, 1, 2]);
      final another = Path([0]);
      final result = path.isBefore(another);
      expect(result, false);
    });
    test('before', (){
      final path = Path([0, 1, 2]);
      final another = Path([1]);
      final result = path.isBefore(another);
      expect(result, true);
    });
    test('below', (){
      final path = Path([0]);
      final another = Path([0, 1]);
      final result = path.isBefore(another);
      expect(result, false);
    });
    test('equal', (){
      final path = Path([0, 1, 2]);
      final another = Path([0, 1, 2]);
      final result = path.isBefore(another);
      expect(result, false);
    });
  });
}