import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';


void main() {
  group('main.nodes', () {
    test('match-function, extension', () {
      final input = '''
  <main>
    <extension>one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!));
      print(output.toList());

      /// [0] <extension>one</extension>
    });

    test('match-function, main', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
    <extension>three</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => true, mode: Mode.highest);
      print(output.toList());

      /// [] <main><extension>one</extension><extension>two</extension><extension>three</extension></main>]
    });

    test('match-function, inline', () {
      final input = '''
  <main>
    <extension>
      one<inline>two</inline>three
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => EditorCondition.isInline(document, node!));
      print(output.toList());

      /// [0, 1] <inline>two</inline>]
    });
  });
}
