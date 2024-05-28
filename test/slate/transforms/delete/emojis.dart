import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/types.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('TextTransforms.delete', () {
    test('inline-end-reverse', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>word📛<cursor />
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
        <main>
    <extension>
      <single />
      <inline>word<cursor />
      </inline>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-middle-reverse', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>wor📛<cursor />d</inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
      <inline>wor<cursor />d</inline>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-middle', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>
        wo
        <cursor />
        📛rd
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
      <inline>
        wo
        <cursor />
        rd
      </inline>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-only-reverse', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>
        📛
        <cursor />
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
      <inline>
        <cursor />
      </inline>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-start', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline>
        <cursor />
        📛word
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
      <inline>
        <cursor />
        word
      </inline>
      <single />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('single-end-reverse', () {
      final input = '''
  <main>
    <extension>
      word📛
      <cursor />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      word
      <cursor />
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('single-start', () {
      final input = '''
  <main>
    <extension>
      <cursor />
      📛word
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <cursor />
      word
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });
  });
}
