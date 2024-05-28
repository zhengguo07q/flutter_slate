import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('NodeTransforms.insertNodes', () {
    test('extension', () {
      final input = '''
  <main>
    <extension>
      <cursor />
    </extension>
    <extension>not empty</extension>
  </main>
''';
      final output = '''
  <main>
    <extension>
      <single />
    </extension>
    <extension>
      <cursor />
    </extension>
    <extension>not empty</extension>
  </main>
  ''';
      final insert = '''<extension>
      <single />
    </extension>
''';
      final document = ConvertXml2Node.toNodeDocument(input);
      final insertContent = ConvertXml2Node.toNodeDocument(insert);
      NodeTransforms.insertNodes(document, [insertContent]);
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      expect(document, outputDocument);
    });
  });
}
