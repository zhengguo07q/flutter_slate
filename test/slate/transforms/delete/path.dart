import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('TextTransforms.delete', () {
    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final output = '''
  <main>
    <extension>one</extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, atl: Path.of([1]));
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>one</inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, atl: Path.of([0, 1]));
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('selection-inside', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>
      <single>
        t<cursor />
        wo
      </single>
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <cursor />
    </extension>
    <extension>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, atl: Path.of([1, 0]));
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('single', () {
      final input = '''
  <main>
    <extension>
      <single>one</single>
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, atl: Path.of([0, 0]));
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });
  });
}