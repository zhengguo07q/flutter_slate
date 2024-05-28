import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/model/text.dart';


void main() {
  group('main.previous', () {
    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.previous(document,
          at: Path.of([1]),
          match: ({Node? node, Path? path}) =>
              EditorCondition.isBlock(document, node!));
      print(output);
    });

    test('default', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.previous(nodeObject,at: Path.of([1]),);
      print(output);
    });

    test('single', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.previous(document,
          at: Path.of([1]),
          match: ({Node? node, Path? path}) =>
              KText.isText(node!));
      print(output);
    });
  });
}
