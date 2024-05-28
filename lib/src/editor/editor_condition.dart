import 'package:slate/slate.dart';

class EditorCondition {
  static bool isType(Document document, Node element, String type){
    return element.type == type;
  }

  /// 检查节点是否有块子节点。
  static bool hasBlocks(Document document, Node element) {
    return element.children.any((n) => EditorCondition.isBlock(document, n));
  }

  /// 检查节点是否有内联子节点和文本子节点。
  static bool hasInlines(Document document, Node element) {
    return element.children.any(
      (n) => KText.isText(n) || EditorCondition.isInline(document, n),
    );
  }

  /// 检查节点是否有文本子节点。
  static bool hasTexts(Document document, Node element) {
    return element.children.every(KText.isText);
  }

  /// 检查一个值是否为block ' Element '对象。
  static bool isBlock(Document document, Node value) {
    return KElement.isElement(value) && !KElement.isInline(value);
  }

  /// 检查一个值是否为“Editor”对象。
  static bool isEditor(dynamic value) {
    final cachedIsEditor = SlateCache.isEditorCache.get(value);
    if (cachedIsEditor == true) {
      return true;
    }

    final isEditor = value is Document;
    SlateCache.isEditorCache[value] = isEditor;
    return isEditor;
  }

  /// 检查一个点是否是一个位置的终点。
  static bool isEnd(Document document, Point point, Location at) {
    final end = LocationPoint.end(document, at);
    return point.equals(end);
  }

  /// 检查一个点是否是一个位置的边缘。
  static bool isEdge(Document document, Point point, Location at) {
    return EditorCondition.isStart(document, point, at) ||
        EditorCondition.isEnd(document, point, at);
  }

  /// 检查一个元素是否为空，包括空节点。
  static bool isEmpty(Document document, Node element) {
    final children = element.children;
    final first = children.first;
    return children.isEmpty ||
        (children.length == 1 &&
            KText.isText(first) &&
            first.text == '' &&
            !KElement.isVoid(element));
  }

  /// 检查一个值是否为内联' Element '对象。
  static bool isInline(Document document, Node value) {
    return KElement.isElement(value) && KElement.isInline(value);
  }

  /// 检查一个点是否是一个位置的起始点。
  static bool isStart(Document document, Point point, Location at) {
    if (point.offset != 0) {
      return false;
    }

    final start = LocationPoint.start(document, at);
    return point.equals(start);
  }

  /// 检查一个值是否为void ' Element '对象。
  static bool isVoid(Document document, dynamic value) {
    return KElement.isElement(value as Node) && KElement.isVoid(value);
  }
}
