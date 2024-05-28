import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('node.texts', () {
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
      final output = nodeObject.texts();
      print(output);

      //(
      // [0, 0] <single key="a"/>,
      // [0, 1] <single key="b"/>)
    });

    test('from', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
      <single key="b" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.texts(from: Path.of([0, 1]));
      print(output);

      //(
      // [0, 1] <single key="b"/>)
    });

    test('multiple-elements', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
    </element>
    <element>
      <single key="b" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.texts();
      print(output);

      //(
      // [0, 0] <single key="a"/>,
      // [1, 0] <single key="b"/>)
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
      final output = nodeObject.texts(reverse: true);
      print(output);

      //(
      // [0, 1] <single key="b"/>,
      // [0, 0] <single key="a"/>)
    });

    test('to', () {
      final input = '''
  <main>
    <element>
      <single key="a" />
      <single key="b" />
      <single key="c" />
      <single key="d" />
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.texts(from: Path.of([0, 1]), to: Path.of([0, 2]));
      print(output);

      //(
      // [0, 1] <single key="b"/>,
      // [0, 2] <single key="c"/>)
    });
  });
}
