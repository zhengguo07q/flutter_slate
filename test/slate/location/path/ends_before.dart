import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';

void main(){
  group('endsBefore',(){
    test('above', (){
      final path = Path([0, 1, 2]);
      final another = Path([0]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('after', (){
      final path = Path([1, 1, 2]);
      final another = Path([0]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('before', (){
      final path = Path([0, 1, 2]);
      final another = Path([1]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('below', (){
      final path = Path([0]);
      final another = Path([0, 1]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('end-after', (){
      final path = Path([1]);
      final another = Path([0, 2]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('end-at', (){
      final path = Path([0]);
      final another = Path([0, 2]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('end-before', (){
      final path = Path([0]);
      final another = Path([1, 2]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, true);
    });
    test('equal', (){
      final path = Path([0, 1, 2]);
      final another = Path([0, 1, 2]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
    test('root', (){
      final path = Path([0, 1, 2]);
      final another = Path([]);
      final endsAfter = path.endsBefore(another);
      expect(endsAfter, false);
    });
  });
}