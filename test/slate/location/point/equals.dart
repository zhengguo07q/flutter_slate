import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/point.dart';

void main(){
  group('Point.equals', (){
    test('path-after-offset-after', () {
      final point = Point.of([0, 4], 7);
      final another= Point.of([0, 1], 3,);
      final result = point.equals(another);
      expect(result, equals(false));
    });
  });

}