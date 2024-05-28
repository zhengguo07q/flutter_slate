import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';


void main() {
  group('main.nodes', ()
  {
    test('mode-all, extension', () {
      final input = '''
  <main>
    <extension a="true">
      <extension a="true">one</extension>
    </extension>
    <extension a="true">
      <extension a="true">two</extension>
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'));
      print(output.toList());

      // [
      // [0] <extension a="true"><extension a="true">one</extension></extension>,
      // [0, 0] <extension a="true">one</extension>,
      // [1] <extension a="true"><extension a="true">two</extension></extension>,
      // [1, 0] <extension a="true">two</extension>]
    });

    test('mode-highest, extension', () {
      final input = '''
  <main>
    <extension a="true">
      <extension a="true">one</extension>
    </extension>
    <extension a="true">
      <extension a="true">two</extension>
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
          mode: Mode.highest);
      print(output.toList());

      // [
      // [0] <extension a="true"><extension a="true">one</extension></extension>,
      // [1] <extension a="true"><extension a="true">two</extension></extension>]
    });

    test('mode-lowest, extension', () {
      final input = '''
  <main>
    <extension a="true">
      <extension a="true">one</extension>
    </extension>
    <extension a="true">
      <extension a="true">two</extension>
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
          mode: Mode.lowest);
      print(output.toList());

      // [
      // [0, 0] <extension a="true">one</extension>,
      // [1, 0] <extension a="true">two</extension>]
    });
  });
}