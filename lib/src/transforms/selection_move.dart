import 'package:slate/slate.dart';

/// 移动选区位置
void selectionMove(
  Document document, {
  int distance = 1,
  Unit? unit = Unit.character,
  bool? reverse = false,
  Edge? edge,
}) {
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

  final anchor = selection.anchor;
  final focus = selection.focus;
  final props = Range.ofNull();

// 设置新的锚点
  if (edge == null || edge == Edge.anchor) {
    final point = reverse == true
        ? LocationPoint.before(document, anchor, distance: distance, unit: unit)
        : LocationPoint.after(document, anchor, distance: distance, unit: unit);

    if (point != null) {
      props.anchor = point;
    }
  }

// 设置新的焦点
  if (edge == null || edge == Edge.focus) {
    final point = reverse == true
        ? LocationPoint.before(document, focus, distance: distance, unit: unit)
        : LocationPoint.after(document, focus, distance: distance, unit: unit);

    if (point != null) {
      props.focus = point;
    }
  }

  SelectionTransforms.setSelection(document, props);
}
