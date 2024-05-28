import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.parent', (){
    test('success', () {
      final p = Path.of([0, 1]);
      final result = p.parent();
      expect(result, equals([0]));
    });
  });

}