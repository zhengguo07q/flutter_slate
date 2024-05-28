import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main() {
  group('path.ancestors', () {
    test('reverse=false', () {
      final p = Path.of([0, 1, 2]);
      final output = p.ancestors();
      expect(output, equals([<int>[], [0], [0, 1]]));
    });
    test('reverse=true', () {
      final p = Path.of([0, 1, 2]);
      final output = p.ancestors(reverse: true);
      expect(output, [[0, 1], [0], <int>[]]);
    });
  });
}