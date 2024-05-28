import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.ancestor', () {
    test('success', () {
      final input = '''
    <main>
      <element>
        <single />
      </element>
    </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);

      final output = nodeObject.ancestor(Path.of([0]));

      final outputXml = ConvertXml2Node.toXmlElement(output).toXmlString(pretty: true);
      final actual = ConvertXml2Node.parse(input).rootElement.children[0].toXmlString(pretty: true);
      expect(outputXml, equals(actual));
    });
  });
}
