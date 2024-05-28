import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.get', () {
    test('root', () {
      final input = '''
  <main>
    <element>
      <single />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.get(Path.ofNull());
      print(output);

      /// <main><element><single/></element></main>
    });

    test('success', () {
      final input = '''
  <main>
    <element>
      <single />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.get(Path.of([0]));
      print(output);

      /// <element><single/></element>
    });
  });
}
