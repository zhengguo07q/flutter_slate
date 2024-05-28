import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/location/point.dart';
import 'package:slate/src/location/range.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.hasBlocks', () {
    test('extension-packages.nested', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
    </extension>
  </main>
''';
      // var document = ConvertXml2Node.toNodeDocument(input);
      // ConvertXml2Node.parse(input).rootElement[0]
      // var output = Editor.hasBlocks(document, );
      //
      // var outValue = Point(path: Path.of([0, 0]), offset: 3);
      // expect(output, outValue);
    });

    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.end(document, Point.of([0, 0], 1));

      final outValue = Point(path: Path.of([0, 0]), offset: 1);
      expect(output, outValue);
    });

    test('inline-packages.nested', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.end(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 0],
              focusOffset: 2));

      final outValue = Point(path: Path.of([0, 0]), offset: 2);
      expect(output, outValue);
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.end(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 0],
              focusOffset: 2));

      final outValue = Point(path: Path.of([0, 0]), offset: 2);
      expect(output, outValue);
    });
  });
}
