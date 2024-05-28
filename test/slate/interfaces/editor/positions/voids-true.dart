import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';


void main() {
  group('main.positions', () {
    test('extension-all-reverse', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), reverse: true, voids: true);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('extension-all', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), voids: true);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3)
      ];
      expect(output.toList(), outValue);
    });

    test('inline-all-reverse', () {
      final input = '''
  <main>
    <extension void="true">one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), reverse: true, voids: true);
      final outValue = [
        Point(path: Path.of([0, 2]), offset: 5),
        Point(path: Path.of([0, 2]), offset: 4),
        Point(path: Path.of([0, 2]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 3),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('inline-all', () {
      final input = '''
  <main>
    <extension void="true">one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), voids: true);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 4),
        Point(path: Path.of([0, 2]), offset: 5)
      ];
      expect(output.toList(), outValue);
    });
  });
}
