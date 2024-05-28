import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/editor/editor_content.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('main.nodes', () {
    test('extension-multiple', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>one</extension><extension>two</extension></main>,
      // [0] <extension>one</extension>,
      // [0, 0] <single>one</single>,
      // [1] <extension>two</extension>,
      // [1, 0] <single>two</single>]
    });

    test('extension-packages.nested', () {
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
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension><extension>one</extension></extension><extension><extension>two</extension></extension></main>,
      // [0] <extension><extension>one</extension></extension>,
      // [0, 0] <extension>one</extension>,
      // [0, 0, 0] <single>one</single>,
      // [1] <extension><extension>two</extension></extension>,
      // [1, 0] <extension>two</extension>,
      // [1, 0, 0] <single>two</single>]
    });

    test('extension-reverse', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(), reverse: true);
      print(output.toList());

      // [
      // [] <main><extension>one</extension><extension>two</extension></main>,
      // [1] <extension>two</extension>,
      // [1, 0] <single>two</single>,
      // [0] <extension>one</extension>,
      // [0, 0] <single>one</single>]
    });

    test('extension-void', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension void="true">one</extension></main>,
      // [0] <extension void="true">one</extension>]
    });

    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>one</extension></main>,
      // [0] <extension>one</extension>,
      // [0, 0] <single>one</single>]
    });

    test('inline-multiple', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three<inline>four</inline>five</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>five</extension></main>,
      // [0] <extension>five</extension>,
      // [0, 0] <single>one</single>,
      // [0, 1] <inline>two</inline>,
      // [0, 1, 0] <single>two</single>,
      // [0, 2] <single>three</single>,
      // [0, 3] <inline>four</inline>,
      // [0, 3, 0] <single>four</single>,
      // [0, 4] <single>five</single>]
    });

    test('inline-packages.nested', () {
      final input = '''
  <main>
    <extension>one<inline>two<inline>three</inline>four</inline>five</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>five</extension></main>,
      // [0] <extension>five</extension>,
      // [0, 0] <single>one</single>,
      // [0, 1] <inline>four</inline>,
      // [0, 1, 0] <single>two</single>,
      // [0, 1, 1] <inline>three</inline>,
      // [0, 1, 1, 0] <single>three</single>,
      // [0, 1, 2] <single>four</single>,
      // [0, 2] <single>five</single>]
    });

    test('inline-reverse', () {
      final input = '''
  <main>
    <extension>one<inline>two</inline>three<inline>four</inline>five</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(), reverse: true);
      print(output.toList());

      // [
      // [] <main><extension>five</extension></main>,
      // [0] <extension>five</extension>,
      // [0, 4] <single>five</single>,
      // [0, 3] <inline>four</inline>,
      // [0, 3, 0] <single>four</single>,
      // [0, 2] <single>three</single>,
      // [0, 1] <inline>two</inline>,
      // [0, 1, 0] <single>two</single>,
      // [0, 0] <single>one</single>]
    });

    test('inline-void', () {
      final input = '''
  <main>
    <extension>one<inline void="true">two</inline>three</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>three</extension></main>,
      // [0] <extension>three</extension>,
      // [0, 0] <single>one</single>,
      // [0, 1] <inline void="true">two</inline>,
      // [0, 2] <single>three</single>]
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>
      one<inline>two</inline>three
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull());
      print(output.toList());

      // [
      // [] <main><extension>three\\\\n    </extension></main>,
      // [0] <extension>three\\\\n    </extension>,
      // [0, 0] <single>      one</single>,
      // [0, 1] <inline>two</inline>,
      // [0, 1, 0] <single>two</single>,
      // [0, 2] <single>three\\\\n    </single>]
    });

  });
}