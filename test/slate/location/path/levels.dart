import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('path.levels', (){
    test('reverse', () {
      final p = Path([0, 1, 2, 4, 2]);
      final pList = p.levels();
      expect(pList, equals([<int>[],[0],[0,1],[0,1,2],[0,1,2,4],[0,1,2,4,2]]));
    });
    test('reverse=true', () {
      final p = Path([0, 1, 2, 4, 2]);
      final pList = p.levels(reverse: true);
      expect(pList, equals([[0, 1, 2, 4, 2], [0, 1, 2, 4], [0, 1, 2], [0, 1], [0], <int>[]]));
    });
  });

}