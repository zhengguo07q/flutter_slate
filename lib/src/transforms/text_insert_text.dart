import 'package:slate/slate.dart';

/// 在编辑器中插入文本字符串。
void textInsertText(
  Document document,
  String text, {
  Location? atl,
  bool voids = false,
}) {
  EditorNormalizing.withoutNormalizing(document, () {
    var at = atl ?? document.selection;
    if (at == null) {
      return;
    }

    if (at is Path) {
      at = LocationRange.range(document, at);
    }

    if (at is Range) {
      if (at.isCollapsed()) {
        at = at.anchor;
      } else {
        final end = at.end();

        if (voids == false && LocationPathEntry.voids(document, at: end) != null) {
          return;
        }

        final pointRef = EditorRef.makePointRef(document, end);
        TextTransforms.delete(document, atl: at, voids: voids);
        at = pointRef.unRef();
        at as Point;
        SelectionTransforms.setSelection(
            document, Range(anchor: at, focus: at));
      }
    }

    if (voids == false && LocationPathEntry.voids(document, at: at) != null) {
      return;
    }

    at as Point;
    final path = at.path;
    final offset = at.offset;
    if (text.isNotEmpty) {
      document
          .apply(InsertTextOperation(path: path, offset: offset, text: text));
    }
  });
}
