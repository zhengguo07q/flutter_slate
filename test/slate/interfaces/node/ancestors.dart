import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.ancestors', () {
    test('reverse', () {
      final input = '''
    <main>
      <element>
        <single />
      </element>
    </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);

      final output = nodeObject.ancestors(Path.of([0, 0]), reverse: true);
      for(final entry in output){
        print(entry);
      }
      /// [0] <element><single/></element>
      /// [] <main><element><single/></element></main>
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

      final output = nodeObject.ancestors(Path.of([0, 0]));
      for(final entry in output){
        print(entry);
      }
      /// [] <main><element><single/></element></main>
      /// [0] <element><single/></element>
    });
  });
}
