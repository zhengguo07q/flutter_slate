import 'package:flutter_test/flutter_test.dart';

import 'package:slate/src/utils/convert_xml2node.dart';
void main() {
  group('node.ancestor', () {
    test('',(){
      final input = """
      <main a="bb">
          <element a='element'>text1<single>text2</single> text3
          </element>
          <element>
            <single>ddfsafa</single>
          </element>
      </main>""";
      final nodeObject = ConvertXml2Node.toNodeDocument(input);
      print(nodeObject);
      final xmlStr = ConvertXml2Node.toXmlElement(nodeObject);
      print(xmlStr);
    });
    test('success', () {
      final input = r'''
      <main>
          <element>
            <single />
          </element>
      </main>''';


      //var output = Node.ancestor(input, Path([0]));
      //expect(output, equals([[], [0], [0, 1]]));
    });
  });
  // group("node.loader", (){
  //   final documentController = DocumentController.basic();
  //   documentController.loadDocument(jsonDoc);
  //   print(documentController.document.toJson());
  // });
}

const jsonDoc = """
[
  {
    "type": "paragraph",
    "children": [
      {
        "single":
          "With Slate you can build complex extension types that have their own embedded content and behaviors, like rendering checkboxes inside check list items!"
      }
    ]
  },
  {
    "type": "check-list-item",
    "checked": true,
    "children": [{ "single": "Slide to the left." }]
  },
  {
    "type": "check-list-item",
    "checked": true,
    "children": [{ "single": "Slide to the right." }]
  },
  {
    "type": "check-list-item",
    "checked": false,
    "children": [{ "single": "Criss-cross." }]
  },
  {
    "type": "check-list-item",
    "checked": true,
    "children": [{ "single": "Criss-cross!" }]
  },
  {
    "type": "check-list-item",
    "checked": false,
    "children": [{ "single": "Cha cha real smooth…" }]
  },
  {
    "type": "check-list-item",
    "checked": false,
    "children": [{ "single": "Let's go to work!" }]
  },
  {
    "type": "paragraph",
    "children": [{ "single": "Try it out for yourself!" }]
  }
]
""";