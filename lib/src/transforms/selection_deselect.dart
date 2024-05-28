import 'package:slate/slate.dart';

/// 把选择滞空，不设置任何的选择位置
void selectionDeselect(Document document) {
  final selection = document.selection;

  if (selection == null) {
    return;
  }
  document.apply(SetSelectionOperation(
    properties: selection,
  ));
}
