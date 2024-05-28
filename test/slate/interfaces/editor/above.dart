import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('main.above', () {
    test('extension-highest', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.above(
        nodeObject,
        at: Path.of([0, 0, 0]),
        match: ({Node? node, Path? path}) => EditorCondition.isBlock(nodeObject, node!),
        mode: Mode.highest,
      );
      print(output);

      /// [0] <extension><extension>one</extension></extension>
    });

    test('extension-lowest', () {
      final input = '''
  <main>
    <extension>
      <extension>one</extension>
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.above(
        nodeObject,
        at: Path.of([0, 0, 0]),
        match: ({Node? node, Path? path}) => EditorCondition.isBlock(nodeObject, node!),
      );
      print(output);

      /// [0, 0] <extension>one</extension>
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>
      one<inline>two</inline>three
    </extension>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.above(
        nodeObject,
        at: Path.of([0, 1, 0]),
        match: ({Node? node, Path? path}) => EditorCondition.isInline(nodeObject, node!),
      );
      print(output);

      /// [0, 1] <inline>two</inline>
    });
  });
}
