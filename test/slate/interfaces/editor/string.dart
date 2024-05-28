import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.string', () {
    test('extension-across', () {
      final input = '''
  <main>
    <extension>
      <single>one</single>
      <single>two</single>
    </extension>
    <extension>
      <single>three</single>
      <single>four</single>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([]));
      final outValue = 'onetwothreefour';
      expect(output, outValue);
    });

    test('extension-void', () {
      final input = '''
  <main>
    <extension void="true">
      <single>one</single>
      <single>two</single>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([]));
      final outValue = '';
      expect(output, outValue);
    });

    test('extension-void-true', () {
      final input = '''
  <main>
    <extension void="true">
      <single>one</single>
      <single>two</single>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([]), voids: true);
      final outValue = 'onetwo';
      expect(output, outValue);
    });

    test('extension', () {
      final input = '''
  <main>
    <extension>
      <single>one</single>
      <single>two</single>
    </extension>
    <extension>
      <single>three</single>
      <single>four</single>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([0]));
      final outValue = 'onetwo';
      expect(output, outValue);
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([0, 1]));
      final outValue = 'two';
      expect(output, outValue);
    });

    test('single', () {
      final input = '''
  <main>
    <extension>
      <single>one</single>
      <single>two</single>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = EditorContent.string(nodeObject, Path.of([0, 0]));
      final outValue = 'one';
      expect(output, outValue);
    });
  });
}