import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.children', () {
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
      final output = nodeObject.childrenI(Path.of([0]));
      for (final entry in output) {
        print(entry);
      }

      /// [0, 0] <single key="a"/>
      /// [0, 1] <single key="b"/>
    });
    test('reverse', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
      <single key="b" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.childrenI(Path.of([0]), reverse: true);
      for (final entry in output) {
        print(entry);
      }

      /// [0, 1] <single key="b"/>
      /// [0, 0] <single key="a"/>
    });
  });
}
