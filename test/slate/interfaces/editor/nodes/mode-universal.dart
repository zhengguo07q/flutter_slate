import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('main.nodes', () {
    test('mode-universal, all-packages.nested', () {
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
          match: ({Node? node, Path? path}) =>
              node!.attributes.containsKey('a'),
          mode: Mode.lowest,
          universal: true);
      print(output.toList());

      // [
      // [0, 0] <extension a="true">one</extension>,
      // [1, 0] <extension a="true">two</extension>]
    });

    test('mode-universal, all', () {
      final input = '''
  <main>
    <extension a="true">one</extension>
    <extension a="true">two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) =>
              node!.attributes.containsKey('a'),
          mode: Mode.lowest,
          universal: true);
      print(output.toList());

      // [
      // [0] <extension a="true">one</extension>,
      // [1] <extension a="true">two</extension>]
    });

    test('mode-universal, branch-packages.nested', () {
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
      final output = LocationPathEntry.nodes(
        document,
        at: Path.ofNull(),
        match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
        mode: Mode.lowest,
        universal: true,
      );
      print(output.toList());

      // [
      // [0, 0] <extension a="true">one</extension>,
      // [1, 0] <extension a="true">two</extension>]
    });


    test('mode-universal, none-packages.nested', () {
      final input = '''
  <main>
    <extension a="true">
      <extension b="true">one</extension>
    </extension>
    <extension b="true">
      <extension a="true">two</extension>
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(
        document,
        at: Path.ofNull(),
        match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
        mode: Mode.lowest,
        universal: true,
      );
      print(output.toList());

      // [
      // [0] <extension a="true"><extension b="true">one</extension></extension>,
      // [1, 0] <extension a="true">two</extension>]
    });


    test('mode-universal, none', () {
      final input = '''
  <main>
    <extension a="true">one</extension>
    <extension a="true">two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(
        document,
        at: Path.ofNull(),
        match: ({Node? node, Path? path}) => node!.attributes.containsKey('b'),
        mode: Mode.lowest,
        universal: true,
      );
      print(output.toList());

      // []
    });


    test('mode-universal, some-packages.nested', () {
      final input = '''
  <main>
    <extension a="true">
      <extension a="true">one</extension>
    </extension>
    <extension b="true">
      <extension b="true">two</extension>
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(
        document,
        at: Path.ofNull(),
        match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
        mode: Mode.lowest,
        universal: true,
      );
      print(output.toList());

      // []
    });


    test('mode-universal, some', () {
      final input = '''
  <main>
    <extension a="true">one</extension>
    <extension b="true">two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(
        document,
        at: Path.ofNull(),
        match: ({Node? node, Path? path}) => node!.attributes.containsKey('a'),
        mode: Mode.lowest,
        universal: true,
      );
      print(output.toList());

      // []
    });
  });
}
