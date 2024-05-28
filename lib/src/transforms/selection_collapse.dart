import 'package:slate/slate.dart';

/// 闭合选取到特定位置
///
/// [Edge]的四个位置
void selectionCollapse(Document document, {Edge edge = Edge.anchor}) {
  final selection = document.selection;

  if (selection == null) {
    return;
  }
  if (edge == Edge.anchor) {
    SelectionTransforms.select(document, selection.anchor);
  } else if (edge == Edge.focus) {
    SelectionTransforms.select(document, selection.focus);
  } else if (edge == Edge.start) {
    final edge = selection.edges();
    SelectionTransforms.select(document, edge.start);
  } else if (edge == Edge.end) {
    final edge = selection.edges();
    SelectionTransforms.select(document, edge.end);
  }
}
