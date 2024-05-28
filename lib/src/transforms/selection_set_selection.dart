import 'package:slate/slate.dart';

/// 设置选择除开需要设置锚点和焦点外，还存在设置属性的问题
///
/// 替换添加删除属性
void selectionSetSelection(Document document, Range newSelection) {
  final selection = document.selection;
  if (selection == null) {
    return;
  }

  final oldRange = Range.ofNull();
  final newRange = Range.ofNull();

  oldRange.attributes = <String, String>{};
  newRange.attributes = <String, String>{};

  var needUpdate = false;

  if (selection.anchor != newSelection.anchor) {
    oldRange.anchor = selection.anchor;
    newRange.anchor = newSelection.anchor;
    needUpdate = true;
  }
  if (selection.focus != newSelection.focus) {
    oldRange.focus = selection.focus;
    newRange.focus = newSelection.focus;
    needUpdate = true;
  }

  final attributes = selection.attributes;
  final newAttributes = newSelection.attributes;
  if (newAttributes != null) {
    for (final key in newAttributes.keys) {
      final containKey = attributes != null && attributes.containsKey(key);
      if (containKey == false) {
        newRange.attributes![key] = newAttributes[key]!;
        needUpdate = true;
      } else if (containKey == true && attributes![key] != newAttributes[key]) {
        oldRange.attributes![key] = attributes[key]!;
        newRange.attributes![key] = newAttributes[key]!;
        needUpdate = true;
      }
    }
  }

  if (needUpdate == true) {
    document.apply(
        SetSelectionOperation(properties: oldRange, newProperties: newRange));
  }
}
