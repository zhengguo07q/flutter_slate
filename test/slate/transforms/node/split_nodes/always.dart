import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('NodeTransforms.splitNodes', () {
    test('after-inline-void', () {
      final input = '''
  <main>
    <extension>
      one
      <inline void="true">
        <single />
      </inline>
      <cursor />
      two
    </extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      one
      <inline void="true">
        <single />
      </inline>
      <single />
    </extension>
    <extension>
      <cursor />
      two
    </extension>
  </main>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      NodeTransforms.splitNodes(document,
          match: ({Node? node, Path? path}) => EditorCondition.isBlock(document, node!),
          always: true);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });
  });
}
