import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.levels', () {
    test('success', () {
      final input = '''
  <main>
    <element>
      <single />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.levels(Path.of([0, 0]));
      print(output);

      /// (
      /// [] <main><element><single/></element></main>,
      /// [0] <element><single/></element>,
      /// [0, 0] <single/>)
    });

    test('reverse', () {
      final input = '''
  <main>
    <element>
      <single />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.levels(Path.of([0, 0]), reverse: true);
      print(output);

      /// (
      /// [0, 0] <single/>,
      /// [0] <element><single/></element>,
      /// [] <main><element><single/></element></main>)
    });
  });
}
