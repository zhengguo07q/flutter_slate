import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/location/point.dart';
import 'package:slate/src/types.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.positions', () {
    test('all, extension-multiple-reverse', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
    <extension>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), reverse: true);
      final outValue = [
        Point(path: Path.of([2, 0]), offset: 5),
        Point(path: Path.of([2, 0]), offset: 4),
        Point(path: Path.of([2, 0]), offset: 3),
        Point(path: Path.of([2, 0]), offset: 2),
        Point(path: Path.of([2, 0]), offset: 1),
        Point(path: Path.of([2, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 3),
        Point(path: Path.of([1, 0]), offset: 2),
        Point(path: Path.of([1, 0]), offset: 1),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0),
      ];
      expect(output.toList(), outValue);
    });

    test('all, extension-multiple', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
    <extension>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 1),
        Point(path: Path.of([1, 0]), offset: 2),
        Point(path: Path.of([1, 0]), offset: 3),
        Point(path: Path.of([2, 0]), offset: 0),
        Point(path: Path.of([2, 0]), offset: 1),
        Point(path: Path.of([2, 0]), offset: 2),
        Point(path: Path.of([2, 0]), offset: 3),
        Point(path: Path.of([2, 0]), offset: 4),
        Point(path: Path.of([2, 0]), offset: 5),
      ];
      expect(output.toList(), outValue);
    });

    test('all, extension-multiple', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
    </extension>
    <extension>
      <extension>two</extension>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0, 0]), offset: 0),
        Point(path: Path.of([0, 0, 0]), offset: 1),
        Point(path: Path.of([0, 0, 0]), offset: 2),
        Point(path: Path.of([0, 0, 0]), offset: 3),
        Point(path: Path.of([1, 0, 0]), offset: 0),
        Point(path: Path.of([1, 0, 0]), offset: 1),
        Point(path: Path.of([1, 0, 0]), offset: 2),
        Point(path: Path.of([1, 0, 0]), offset: 3),
      ];
      expect(output.toList(), outValue);
    });

    test('all, extension-reverse', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), reverse: true);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0),
      ];
      expect(output.toList(), outValue);
    });

    test('all, extension', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3),
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-fragmentation-empty-single', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>
        <single />
        <inline>
          <single />
        </inline>
        <single />
      </inline>
      <single />
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 2]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-fragmentation-reverse', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>
        <single />
        <inline>
          <single />
        </inline>
        <single />
      </inline>
      <single />
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), reverse: true);
      final outValue = [
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 1, 2]), offset: 0),
        Point(path: Path.of([0, 1, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-fragmentation', () {
      final input = '''
  <main>
    <extension>1<inline>2</inline>3</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 1)
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-multiple', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three<inline>four</inline>five</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
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
        Point(path: Path.of([0, 2]), offset: 5),
        Point(path: Path.of([0, 3, 0]), offset: 0),
        Point(path: Path.of([0, 3, 0]), offset: 1),
        Point(path: Path.of([0, 3, 0]), offset: 2),
        Point(path: Path.of([0, 3, 0]), offset: 3),
        Point(path: Path.of([0, 3, 0]), offset: 4),
        Point(path: Path.of([0, 4]), offset: 0),
        Point(path: Path.of([0, 4]), offset: 1),
        Point(path: Path.of([0, 4]), offset: 2),
        Point(path: Path.of([0, 4]), offset: 3),
        Point(path: Path.of([0, 4]), offset: 4)
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-packages.nested', () {
      final input = '''
  <main>
    <extension>one<inline>two<inline>three</inline>four</inline>five</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3),
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
        Point(path: Path.of([0, 1, 2]), offset: 4),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 4)
      ];
      expect(output.toList(), outValue);
    });

    test('all, inline-reverse', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), reverse: true);
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

    test('all, inline', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject, at: Path.ofNull());
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

    test('all, unit-extension-reverse', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.block, reverse: true);
      final outValue = [
        Point(path: Path.of([1, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('all, unit-extension', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.block);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 13)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-character-inline-fragmentation-multibyte', () {
      final input = '''
  <main>
    <extension>😀<inline>😀</inline>😀</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.character);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 2)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-character-inline-fragmentation-reverse', () {
      final input = '''
  <main>
    <extension>1<inline>2</inline>3</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.character, reverse: true);
      final outValue = [
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-character-inline-fragmentation', () {
      final input = '''
  <main>
    <extension>1<inline>2</inline>3</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.character);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 1)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-character-reverse', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
    <extension>four<inline>five</inline>six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.character, reverse: true);
      final outValue = [
        Point(path: Path.of([1, 2]), offset: 3),
        Point(path: Path.of([1, 2]), offset: 2),
        Point(path: Path.of([1, 2]), offset: 1),
        Point(path: Path.of([1, 2]), offset: 0),
        Point(path: Path.of([1, 1, 0]), offset: 3),
        Point(path: Path.of([1, 1, 0]), offset: 2),
        Point(path: Path.of([1, 1, 0]), offset: 1),
        Point(path: Path.of([1, 1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 3),
        Point(path: Path.of([1, 0]), offset: 2),
        Point(path: Path.of([1, 0]), offset: 1),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 5),
        Point(path: Path.of([0, 2]), offset: 4),
        Point(path: Path.of([0, 2]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 0),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-character', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
    <extension>four<inline>five</inline>six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.character);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 2),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 1, 0]), offset: 1),
        Point(path: Path.of([0, 1, 0]), offset: 2),
        Point(path: Path.of([0, 1, 0]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 2]), offset: 2),
        Point(path: Path.of([0, 2]), offset: 3),
        Point(path: Path.of([0, 2]), offset: 4),
        Point(path: Path.of([0, 2]), offset: 5),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 1),
        Point(path: Path.of([1, 0]), offset: 2),
        Point(path: Path.of([1, 0]), offset: 3),
        Point(path: Path.of([1, 0]), offset: 4),
        Point(path: Path.of([1, 1, 0]), offset: 1),
        Point(path: Path.of([1, 1, 0]), offset: 2),
        Point(path: Path.of([1, 1, 0]), offset: 3),
        Point(path: Path.of([1, 1, 0]), offset: 4),
        Point(path: Path.of([1, 2]), offset: 1),
        Point(path: Path.of([1, 2]), offset: 2),
        Point(path: Path.of([1, 2]), offset: 3)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-line-inline-fragmentation-reverse', () {
      final input = '''
  <main>
    <extension>he<inline>ll</inline>o wo<inline>rl</inline>d</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      var output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.line, reverse: true);
      final outValue = [
        Point(path: Path.of([0, 4]), offset: 1),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-line-inline-fragmentation', () {
      final input = '''
  <main>
    <extension>he<inline>ll</inline>o wo<inline>rl</inline>d</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.line);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 4]), offset: 1)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-line-reverse', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.line, reverse: true);
      final outValue = [
        Point(path: Path.of([1, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-line', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.line);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 13)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-word-inline-fragmentation', () {
      final input = '''
  <main>
    <extension>he<inline>ll</inline>o wo<inline>rl</inline>d</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.word);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 2]), offset: 1),
        Point(path: Path.of([0, 4]), offset: 1)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-word-reverse', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPoint.positions(nodeObject,
          at: Path.ofNull(), unit: Unit.word, reverse: true);
      final outValue = [
        Point(path: Path.of([1, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 10),
        Point(path: Path.of([1, 0]), offset: 5),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([0, 0]), offset: 8),
        Point(path: Path.of([0, 0]), offset: 4),
        Point(path: Path.of([0, 0]), offset: 0)
      ];
      expect(output.toList(), outValue);
    });

    test('unit-word', () {
      final input = '''
  <main>
    <extension>one two three</extension>
    <extension>four five six</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output =
          LocationPoint.positions(nodeObject, at: Path.ofNull(), unit: Unit.word);
      final outValue = [
        Point(path: Path.of([0, 0]), offset: 0),
        Point(path: Path.of([0, 0]), offset: 3),
        Point(path: Path.of([0, 0]), offset: 7),
        Point(path: Path.of([0, 0]), offset: 13),
        Point(path: Path.of([1, 0]), offset: 0),
        Point(path: Path.of([1, 0]), offset: 4),
        Point(path: Path.of([1, 0]), offset: 9),
        Point(path: Path.of([1, 0]), offset: 13)
      ];
      expect(output.toList(), outValue);
    });
  });
}
