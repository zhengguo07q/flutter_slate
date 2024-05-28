import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.elements', () {
    test('all', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
      <single key="b" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.elements();
      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/></element>
    });

    test('path', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
      <single key="b" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.elements(reverse: true);
      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/></element>
    });
  });
}
