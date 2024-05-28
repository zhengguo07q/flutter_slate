import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('TextTransforms.delete', () {
    test('basic-reverse', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>
      <cursor />
      two
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <cursor />
      two
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('basic', () {
      final input = '''
  <main>
    <extension>
      word
      <cursor />
    </extension>
    <extension>another</extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      word
      <cursor />
      another
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('depths-reverse', () {
      final input = '''
  <main>
    <extension>Hello</extension>
    <extension>
      <extension>
        <cursor />
        world!
      </extension>
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      Hello
      <cursor />
      world!
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-before-reverse', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>
      <cursor />
      two
      <inline>three</inline>
      four
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <cursor />
      two
      <inline>three</inline>
      four
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-before', () {
      final input = '''
  <main>
    <extension>
      word
      <cursor />
    </extension>
    <extension>
      <single />
      <inline void="true">
        <single />
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      word
      <cursor />
      <inline void>
        <single />
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

    test('inline-end', () {
      final input = '''
  <main>
    <extension>
      one
      <inline>
        two
        <cursor />
      </inline>
      <single />
    </extension>
    <extension>
      <single />
      <inline>three</inline>
      four
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <inline>two</inline>
      <single>
        <cursor />
      </single>
      <inline>three</inline>
      four
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-inside-reverse', () {
      final input = '''
  <main>
    <extension>
      one
      <inline>two</inline>
      <single />
    </extension>
    <extension>
      <single />
      <inline>
        <cursor />
        three
      </inline>
      four
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <inline>two</inline>
      <single>
        <cursor />
      </single>
      <inline>three</inline>
      four
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-void-reverse', () {
      final input = '''
  <main>
    <extension>
      <single />
      <inline void>
        <single />
      </inline>
      <single />
    </extension>
    <extension>
      <cursor />
      word
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
      <inline void>
        <single>
          <cursor />
        </single>
      </inline>
      word
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('inline-void', () {
      final input = '''
  <main>
    <extension>
      word
      <cursor />
    </extension>
    <extension>
      <single />
      <inline void>
        <single />
      </inline>
      <single />
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      word
      <cursor />
      <inline void>
        <single />
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

    test('inline', () {
      final input = '''
  <main>
    <extension>
      one
      <cursor />
    </extension>
    <extension>
      two<inline>three</inline>four
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <cursor />
      two<inline>three</inline>four
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('packages.nested-reverse', () {
      final input = '''
  <main>
    <extension>
      <extension>word</extension>
      <extension>
        <cursor />
        another
      </extension>
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <extension>
        word
        <cursor />
        another
      </extension>
    </extension>
  </main>
  ''';
      final document = ConvertXml2Node.toNodeDocument(input);
      TextTransforms.delete(document, reverse: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });

    test('packages.nested-reverse', () {
      final input = '''
  <main>
    <extension>
      <extension>
        word
        <cursor />
      </extension>
      <extension>another</extension>
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <extension>
        word
        <cursor />
        another
      </extension>
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