import 'package:slate/slate.dart';

/// 选择特定的位置
void selectionSelect(Document document, Location target) {
  final selection = document.selection;
  target = LocationRange.range(document, target);

  if (selection != null) {
    SelectionTransforms.setSelection(document, target as Range);
    return;
  }

  assert(target is Range,
      'When setting the selection and the current selection is `null` you must provide at least an `anchor` and `focus`, but you passed:$target');

  document.apply(SetSelectionOperation(
    properties: selection,
    newProperties: target as Range,
  ));
}
