import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.leaf', () {
    test('success', () {
      final input = '''
  <main>
    <element>
      <single />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.leaf(Path.of([0, 0]));
      print(output);

      /// <single/>
    });
  });
}
