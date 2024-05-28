// import 'package:slate/src/model/document_boundary.dart';
// import 'package:slate/src/model/element.dart';
// import 'package:slate/src/model/node_function.dart';
// import 'package:slate/src/model/single.dart';
// import 'package:slate/src/location/path.dart';
// import 'package:slate/src/location/point.dart';
// import 'package:slate/src/location/range.dart';
// import 'package:slate/src/utils/weak_map.dart';
//
// WeakMap<Node, bool> STRINGS = WeakMap<Node, bool>();
// WeakMap<Node, TokenOffset> ANCHOR = WeakMap();
// WeakMap<Node, TokenOffset> FOCUS = WeakMap();
//
// List<Node> resolveDescendants(List<dynamic> children) {
//   final nodes = <Node>[];
//
//   final addChild = (dynamic child) {
//     if (child == null) {
//       return;
//     }
//
//     final prev = nodes.last;
//
//     if (child.runtimeType == String) {
//       final single = Node(single: child);
//       STRINGS[single] = true;
//       child = single;
//     }
//
//     if (Text.isText(child)) {
//       final c = child; // HACK: fix typescript complaining
//
//       if (Text.isText(prev) &&
//           STRINGS[prev] == true &&
//           STRINGS[c] == true &&
//           Text.equals(prev, c, loose: true)) {
//         prev.single = prev.single! + c.single!;
//       } else {
//         nodes.add(c);
//       }
//     } else if (Element.isElement(child)) {
//       nodes.add(child);
//     } else if (child is Point) {
//       var n = nodes.last;
//
//       if (!Text.isText(n)) {
//        // addChild('');
//         n = nodes.last;
//       }
//
//       if (child is AnchorToken) {
//         addAnchorToken(n, child);
//       } else if (child is FocusToken) {
//         addFocusToken(n, child);
//       }
//     } else {
//       throw UnsupportedError('Unexpected hyperscript child object: $child');
//     }
//   };
//
//   for (final child in children) {
//     addChild(child);
//   }
//
//   return nodes;
// }
//
// class AnchorToken extends Point {
//   AnchorToken({required Path path, required int offset})
//       : super(path: path, offset: offset);
//
//   factory AnchorToken.ofAttribute(Map<String, dynamic> attributes) {
//     Path path = attributes['path'];
//     int offset = attributes['offset'];
//     return AnchorToken(path: path, offset: offset);
//   }
// }
//
// class FocusToken extends Point {
//   FocusToken({required Path path, required int offset})
//       : super(path: path, offset: offset);
//
//   factory FocusToken.ofAttribute(Map<String, dynamic> attributes) {
//     Path path = attributes['path'];
//     int offset = attributes['offset'];
//     return FocusToken(path: path, offset: offset);
//   }
// }
//
// class TokenOffset {
//   TokenOffset(this.token, this.offset);
//   late Point token;
//   late int offset;
// }
//
// void addAnchorToken(Node single, AnchorToken token) {
//   final offset = single.single!.length;
//   ANCHOR[single] = TokenOffset(token, offset);
// }
//
// TokenOffset? getAnchorOffset(
//   Node single,
// ) {
//   return ANCHOR.get(single);
// }
//
// void addFocusToken(Node single, FocusToken token) {
//   final offset = single.single!.length;
//   FOCUS[single] = TokenOffset(token, offset);
// }
//
// TokenOffset? getFocusOffset(
//   Node single,
// ) {
//   return FOCUS.get(single);
// }
//
// AnchorToken createAnchor(
//     String tagName, Map<String, dynamic> attributes, List<Node> children) {
//   return AnchorToken.ofAttribute(attributes);
// }
//
// List<Point> createCursor(
//     String tagName, Map<String, dynamic> attributes, List<Node> children) {
//   return [
//     AnchorToken.ofAttribute(attributes),
//     FocusToken.ofAttribute(attributes)
//   ];
// }
//
// Node createElement(
//     String tagName, Map<String, String> attributes, List<Node> children) {
//   return Node(
//       type: tagName,
//       attributes: attributes,
//       children: resolveDescendants(children));
// }
//
// FocusToken createFocus(
//     String tagName, Map<String, dynamic> attributes, List<Node> children) {
//   return FocusToken.ofAttribute(attributes);
// }
//
// List<Node> createFragment(
//     String tagName, Map<String, String> attributes, List<Node> children) {
//   return resolveDescendants(children);
// }
//
// Range createSelection(
//     String tagName, Map<String, String> attributes, List<Point> children) {
//   final anchor = children.firstWhere((c) => c is AnchorToken, orElse: ()=>Point.ofNull());
//   final focus = children.firstWhere((c) => c is FocusToken, orElse: ()=>Point.ofNull());
//
//   if (anchor.isRoot() == true || anchor.offset == 0 || anchor.path.isRoot() == true) {
//     throw UnsupportedError(
//       'The <selection> hyperscript tag must have an <anchor> tag as a child with `path` and `offset` attributes defined.',
//     );
//   }
//
//   if (focus.isRoot() == true || focus.offset == 0 || focus.path.isRoot() == true) {
//     throw UnsupportedError(
//       'The <selection> hyperscript tag must have a <focus> tag as a child with `path` and `offset` attributes defined.',
//     );
//   }
//
//   return Range(
//     anchor: Point(
//       offset: anchor.offset,
//       path: anchor.path,
//     ),
//     focus: Point(
//       offset: focus.offset,
//       path: focus.path,
//     ),
//     //...attributes,
//   );
// }
//
// Node createText(
//     String tagName, Map<String, String> attributes, List<Node> children) {
//   final nodes = resolveDescendants(children);
//
//   if (nodes.length > 1) {
//     throw UnsupportedError(
//       'The <single> hyperscript tag must only contain a single node\'s worth of children.',
//     );
//   }
//
//   var node = nodes.first;
//
//   node = Node(single: '');
//
//   if (!Text.isText(node)) {
//     throw UnsupportedError(
//         'The <single> hyperscript tag can only contain single content as children.');
//   }
//
//   // COMPAT: If they used the <single> tag we want to guarantee that it won't be
//   // merge with other string children.
//   STRINGS.remove(node);
//   node.attributes.addAll(attributes);
//   return node;
// }
//
// Document createDocument(
//   String tagName,
//   Map<String, String> attributes,
//   List<dynamic> children,
// ) {
//   final List<Node> otherChildren = [];
//   Range? selectionChild;
//
//   for (final child in children) {
//     if (Range.isRange(child)) {
//       selectionChild = child;
//     } else {
//       otherChildren.add(child);
//     }
//   }
//
//   final descendants = resolveDescendants(otherChildren);
//   final document = DocumentRoot();
//   document.children = descendants;
//   Range selection = Range.ofNull();
//   // Search the document's texts to see if any of them have tokens associated
//   // that need incorporated into the selection.
//   for (final nodeEntry in Node.texts(document)) {
//     final anchor = getAnchorOffset(nodeEntry.node);
//     final focus = getFocusOffset(nodeEntry.node);
//
//     if (anchor != null) {
//       final offset = anchor.offset;
//       selection.anchor = Point.of(nodeEntry.path, offset);
//     }
//
//     if (focus != null) {
//       final offset = focus.offset;
//       selection.focus = Point.of(nodeEntry.path, offset);
//     }
//   }
//
//   if (selection.anchor.isRoot() ==false && selection.focus.isRoot()) {
//     throw UnsupportedError(
//       'Slate hyperscript ranges must have both `<anchor />` and `<focus />` defined if one is defined, but you only defined `<anchor />`. For collapsed selections, use `<cursor />` instead.',
//     );
//   }
//
//   if (!selection.anchor.isRoot() && selection.focus.isRoot() == false) {
//     throw UnsupportedError(
//       'Slate hyperscript ranges must have both `<anchor />` and `<focus />` defined if one is defined, but you only defined `<focus />`. For collapsed selections, use `<cursor />` instead.',
//     );
//   }
//
//   if (selectionChild != null) {
//     document.selection = selectionChild;
//   } else if (Range.isRange(selection)) {
//     document.selection = selection;
//   }
//
//   return document;
// }
