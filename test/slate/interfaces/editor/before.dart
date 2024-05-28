import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/editor/location_point.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/location/point.dart';
import 'package:slate/src/location/range.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.before', () {
    test('path-void', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
    <extension void="true">two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(document, Path.of([1, 0]), voids: true);

      final outValue = Point.of([0, 0], 3);
      expect(output, outValue);
    });

    test('path', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(document, Path.of([1, 0]));

      final outValue = Point.of([0, 0], 3);
      expect(output, outValue);
    });

    test('point-void', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(document, Point.of([0, 0], 1), voids: true);

      final outValue = Point.of([0, 0], 0);
      expect(output, outValue);
    });

    test('point', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(document, Point.of([0, 0], 1));

      final outValue = Point.of([0, 0], 0);
      expect(output, outValue);
    });

    test('range-void', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
    <extension void="true">two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 1],
              focusOffset: 2),
          voids: true);

      final outValue = Point.of([0, 0], 0);
      expect(output, outValue);
    });

    test('range', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 1],
              focusOffset: 2));

      final outValue = Point.of([0, 0], 0);
      expect(output, outValue);
    });

    test('start', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.before(document, Path.of([0, 0]));

      expect(output, null);
    });
  });
}
