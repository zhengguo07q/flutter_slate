import 'package:slate/slate.dart';

void selectionSetPoint(Document document, Map<String, String> attributes,
    {Edge edge = Edge.start}) {
  final selection = document.selection;

  if (selection == null) {
    return;
  }

  if (edge == Edge.start) {
    edge = selection.isBackward() ? Edge.focus : Edge.anchor;
  }

  if (edge == Edge.end) {
    edge = selection.isBackward() ? Edge.anchor : Edge.focus;
  }
  Range range;
  if (edge == Edge.anchor) {
    range = Range.ofPoint(selection.anchor, selection.anchor);
  } else {
    range = Range.ofPoint(selection.focus, selection.focus);
  }
  range.attributes = attributes;

  SelectionTransforms.setSelection(document, range);
}
