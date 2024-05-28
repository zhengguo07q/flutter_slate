import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';
import 'package:slate/src/utils/convert_xml2node.dart';
import 'package:slate/src/location/path.dart';

void main() {
  group('NodeTransforms.insertNodes', () {
    test('extension', () {
      final input = '''
  <main>
    <extension>one</extension>
    <extension>two</extension>
  </main>
''';
      final output = '''
  <main>
    <extension>two</extension>
  </main>
  ''';

      final document = ConvertXml2Node.toNodeDocument(input);
      NodeTransforms.removeNodes(document, atl: Path.of([0]));
      final outputDocument = ConvertXml2Node.toNodeDocument(output);
      print(document);
      expect(document, outputDocument);
    });
  });
}
