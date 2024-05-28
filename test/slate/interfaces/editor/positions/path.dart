import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';


void main() {
  group('main.positions', () {
    test('extension-packages.nested', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
      <extension>two</extension>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.of([0]));
      final outValue = [
        Point(path: Path.of([0, 0, 0]), offset: 0),
        Point(path: Path.of([0, 0, 0]), offset: 1),
        Point(path: Path.of([0, 0, 0]), offset: 2),
        Point(path: Path.of([0, 0, 0]), offset: 3),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 3)
      ];
      expect(output.toList(), outValue);
    });

    test('extension-reverse', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
      <extension>two</extension>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.of([0, 0]), reverse: true);
      final outValue = [
        Point(path: Path.of([0, 0, 0]), offset: 3),
        Point(path: Path.of([0, 0, 0]), offset: 2),
        Point(path: Path.of([0, 0, 0]), offset: 1),
        Point(path: Path.of([0, 0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.of([1, 0]));
      final outValue = [
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 1),
        Point(path: Path.of([1, 0]), offset: 2),
        Point(path: Path.of([1, 0]), offset: 3)
      ];
      expect(output.toList(), outValue);
    });

    test('inline-packages.nested', () {
      final input = '''
  <main>
    <extension>one<inline>two<inline>three</inline>four</inline>five</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject, at: Path.of([0, 1]));
      final outValue = [
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 3),
        Point(path: Path.of([0, 1, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 1, 0]), offset: 3),
        Point(path: Path.of([0, 1, 1, 0]), offset: 4),
        Point(path: Path.of([0, 1, 1, 0]), offset: 5),
        Point(path: Path.of([0, 1, 2]), offset: 0),
        Point(path: Path.of([0, 1, 2]), offset: 1),
        Point(path: Path.of([0, 1, 2]), offset: 2),
        Point(path: Path.of([0, 1, 2]), offset: 3),
        Point(path: Path.of([0, 1, 2]), offset: 4)
      ];
      expect(output.toList(), outValue);
    });

    test('inline-reverse', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.of([0, 1]), reverse: true);
      final outValue = [
        Point(path: Path.of([0, 1, 0]), offset: 3),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject, at: Path.of([0, 1]));
      final outValue = [
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 3)
      ];
      expect(output.toList(), outValue);
    });
  });
}
