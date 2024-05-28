import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/utils/string.dart';
void main(){
  group('string test', (){
    test('getCharacterDistance latin', () {
      final distance = getCharacterDistance('aaaaa');
      expect(distance, equals(1));
    });
    test('getCharacterDistance Emoji', () {
      final distance = getCharacterDistance('✈✈✈飞机');
      expect(distance, equals(1));
    });
  });
}
