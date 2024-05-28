import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';


void main() {
  group('main.range', () {
    test('path', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationRange.range(nodeObject, Path.of([0]));
      final outValue = Range(
          anchor: Point(path: Path.of([0, 0]), offset: 0),
          focus: Point(path: Path.of([0, 0]), offset: 3));
      expect(output, outValue);
    });

    test('point', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationRange.range(nodeObject, Point.of(Path.of([0, 0]), 1));
      final outValue = Range(
          anchor: Point(path: Path.of([0, 0]), offset: 1),
          focus: Point(path: Path.of([0, 0]), offset: 1));
      expect(output, outValue);
    });

    test('range-backward', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationRange.range(
          nodeObject,
          Range.of(
              anchorPath: Path.of([0, 0]),
              anchorOffset: 2,
              focusPath: Path.of([0, 0]),
              focusOffset: 1));
      final outValue = Range(
          anchor: Point(path: Path.of([0, 0]), offset: 2),
          focus: Point(path: Path.of([0, 0]), offset: 1));
      expect(output, outValue);
    });

    test('range', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationRange.range(
          nodeObject,
          Range.of(
              anchorPath: Path.of([0, 0]),
              anchorOffset: 1,
              focusPath: Path.of([0, 0]),
              focusOffset: 2));
      final outValue = Range(
          anchor: Point(path: Path.of([0, 0]), offset: 1),
          focus: Point(path: Path.of([0, 0]), offset: 2));
      expect(output, outValue);
    });
  });
}
