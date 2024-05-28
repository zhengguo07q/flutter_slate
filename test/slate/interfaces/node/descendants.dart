import 'package:flutter_test/flutter_test.dart';
import 'package:slate/src/location/path.dart';
import 'package:slate/src/utils/convert_xml2node.dart';

void main() {
  group('node.descendants', () {
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
      final output = nodeObject.descendants();

      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/></element>
      /// [0, 0] <single key="a"/>
      /// [0, 1] <single key="b"/>
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
      final output = nodeObject.descendants(from: Path.of([0, 1]));

      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/></element>
      /// [0, 1] <single key="b"/>
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
      final output = nodeObject.descendants(from: Path.of([0, 1]), to: Path.of([0, 2]));

      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/><single key="c"/><single key="d"/></element>
      /// [0, 1] <single key="b"/>
      /// [0, 2] <single key="c"/>
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
      final output = nodeObject.descendants(reverse:true);

      for (final entry in output) {
        print(entry);
      }

      /// [0] <element><single key="a"/><single key="b"/></element>
      /// [0, 1] <single key="b"/>
      /// [0, 0] <single key="a"/>
    });
  });
}
