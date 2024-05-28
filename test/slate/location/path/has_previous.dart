import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.hasPrevious',() {
    test('root', () {
      final path = Path([0, 0]);
      final result = path.hasPrevious();
      expect(result, false);
    });
    test('success', () {
      final path = Path([1, 1, 2]);
      final result = path.hasPrevious();
      expect(result, true);
    });
  });
}