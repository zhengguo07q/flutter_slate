import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('node.string', () {
    test('across-elements', () {
      final input = '''
  <main>
    <element>
      <single>one</single>
      <single>two</single>
    </element>
    <element>
      <single>three</single>
      <single>four</single>
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.string();
      print(output);

      /// onetwothreefour
    });

    test('elements', () {
      final input = '''
  <element>
    <single>one</single>
    <single>two</single>
  </element>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.string();
      print(output);

      /// onetwo
    });
  });
}
