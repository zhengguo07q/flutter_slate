import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/editor/location_point.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/location/point.dart';
import 'package:slate/src/location/range.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.start', () {
    test('path', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.start(nodeObject, Path.of([0]));
      final outValue = Point.of([0, 0], 0);
      expect(output, outValue);
    });

    test('point', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.start(nodeObject, Point.of([0, 0], 1));
      final outValue = Point.of([0, 0], 1);
      expect(output, outValue);
    });

    test('range', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.start(
          nodeObject,
          Range.of(
            anchorPath: [0, 0],
            anchorOffset: 1,
            focusPath: [0, 0],
            focusOffset: 3,
          ));
      final outValue = Point.of([0, 0], 1);
      expect(output, outValue);
    });
  });
}
