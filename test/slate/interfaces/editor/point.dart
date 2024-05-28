import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('main.point', () {
    test('path-end', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(document, Path.of([0]), edge: Edge.end);

      final value = Point.of([0, 0], 3);
      expect(output, value);
    });

    test('path-start', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(document, Path.of([0]));

      final value = Point.of([0, 0], 0);
      expect(output, value);
    });

    test('path', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(
        document,
        Path.of([0]),
      );

      final value = Point.of([0, 0], 0);
      expect(output, value);
    });

    test('point', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(
        document,
        Point.of([0, 0], 1),
      );

      final value = Point.of([0, 0], 1);
      expect(output, value);
    });

    test('range-end', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(
        document,
        Range.of(
            anchorPath: [0, 0],
            anchorOffset: 1,
            focusPath: [0, 1],
            focusOffset: 2),
        edge: Edge.end
      );

      final value = Point.of([0, 1], 2);
      expect(output, value);
    });

    test('range-start', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 1],
              focusOffset: 2));
      final value = Point.of([0, 0], 1);
      expect(output, value);
    });

    test('range', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.point(
          document,
          Range.of(
              anchorPath: [0, 0],
              anchorOffset: 1,
              focusPath: [0, 1],
              focusOffset: 2));
      final value = Point.of([0, 0], 1);
      expect(output, value);
    });

  });
}
