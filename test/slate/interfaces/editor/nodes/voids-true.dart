import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/model/text.dart';

void main() {
  group('main.nodes', ()
  {
    test('extension', () {
      final input = '''
  <main>
    <extension void="true">one</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => KText.isText(node!),
          voids: true);
      print(output.toList());

      // [
      // [0, 0] <single>one</single>]
    });

    test('inline', () {
      final input = '''
  <main>
    <extension>one<inline void="true">two</inline>three</extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final output = LocationPathEntry.nodes(document,
          at: Path.ofNull(),
          match: ({Node? node, Path? path}) => KText.isText(node!),
          voids: true);
      print(output.toList());

      // [
      // [0, 0] <single>one</single>,
      // [0, 1, 0] <single>two</single>,
      // [0, 2] <single>three</single>]
    });

  });
}