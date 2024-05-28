import 'package:flutter_test/flutter_test.dart';
import 'package:slate/slate.dart';

void main() {
  group('node.nodes', () {
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
      final output = nodeObject.nodes();
      print(output);

      // (
      // [] <main><element><single key="a"/><single key="b"/></element></main>,
      // [0] <element><single key="a"/><single key="b"/></element>,
      // [0, 0] <single key="a"/>,
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
      final output = nodeObject.nodes();
      print(output);

      // (
      // [] <main><element><single key="a"/></element><element><single key="b"/></element></main>,
      // [0] <element><single key="a"/></element>,
      // [0, 0] <single key="a"/>,
      // [1, 0] <element><single key="b"/></element>,
      // [1, 0] <single key="b"/>)
    });

    test('packages.nested-elements', () {
      final input = '''
  <main>
    <element>
      <element>
        <single key="a" />
      </element>
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.nodes();
      print(output);

      // (
      // [] <main><element><element><single key="a"/></element></element></main>,
      // [0] <element><element><single key="a"/></element></element>,
      // [0, 0] <element><single key="a"/></element>,
      // [0, 0, 0] <single key="a"/>)
    });

    test('pass', () {
      final input = '''
  <main>
    <element>
      <element>
        <single key="a" />
      </element>
    </element>
  </main>
''';
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      final output = nodeObject.nodes(pass: ({Node? node, Path? path}) => path!.length > 1);
      print(output);

      // (
      // [] <main><element><element><single key="a"/></element></element></main>,
      // [0] <element><element><single key="a"/></element></element>,
      // [0, 0] <element><single key="a"/></element>)
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
      final output =
      nodeObject.nodes(from: Path.of([0, 1]), to: Path.of([0, 2]));
      print(output);

      // (
      // [] <main><element><single key="a"/><single key="b"/><single key="c"/><single key="d"/></element></main>,
      // [0] <element><single key="a"/><single key="b"/><single key="c"/><single key="d"/></element>,
      // [0, 1] <single key="b"/>,
      // [0, 2] <single key="c"/>)
    });
  });
}
