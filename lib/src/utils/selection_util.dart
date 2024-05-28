import 'package:flutter/painting.dart';
import 'package:slate/slate.dart';
import 'package:common/common.dart';

class SelectionUtil {
  static bool selectNode(Document document, Node node) {
    final nodePath = node.getPath();
    if (document.selection != null) {
      return document.selection!.includes(nodePath);
    }
    return false;
  }

  /// 文档选区转化为基于节点的范围
  ///
  /// 在FLUTTER的文本里面，存在多个节点使用一个[RichText]的情况。
  /// 在这种状况下，我们很难直接获取到具体到文本里面的定位。获取到的也只是不准确的定位。
  /// 但是它不会存在的情况是什么呢？就是因为它是一个渲染组件进行的渲染，不会存在这个文本内容里面的数据相互影响的情况。所以这个是不用处理的
  ///
  /// 但是对我们来说，我们需要明确到具体的详细的节点，所以无论如何，我们都需要一些办法来定位到文本的最深处的节点，哪怕这个节点情况不是那么准确。
  /// 对跨越节点，非文本的情况，我们更是要计算出来具体的定位，因为这个时候不存在一个渲染组件帮助解决定位不准确的问题
  ///
  /// 具体的方案就是：
  ///   传递过来点击的计算节点，
  static Range transformLocalTextSelection(
      Node node, TextSelection textSelection, Point cursorPoint) {
    // 光标位置所在的节点，可能指向text节点，如果是多Line则是普通block节点
    final cursorNode = node.get(cursorPoint.path);
    // 光标在当前本地文档中的偏移
    final cursorDocumentOffset =
        cursorNode.blockOffset + cursorPoint.offset;
    final selectionPoint =
        NodeLocation.offsetLocation(node, textSelection.baseOffset);

    final cursorPath = cursorPoint.path;

    // 如果是闭合选区
    if (textSelection.isCollapsed) {
      // 光标是否为查询选区祖先
      if (cursorPath.isAncestor(selectionPoint.path)) {
        //定位是在节点内部，可以使用字符串位置找到具体的定位
        AppLogger.slateLog.i(
            '$cursorDocumentOffset, ${textSelection.baseOffset}| currentNode $cursorPath, ${cursorPoint.offset}   textSelection ${selectionPoint.path}, ${selectionPoint.offset} 使用textSelection');

        return Range(anchor: selectionPoint, focus: selectionPoint);
      } else {
        // 定位是在节点的边界，这个时候传递过来的定位准确度要高于查找定位
        final point;
        if (cursorPoint.offset == 0) {
          final nodeEntry = node.first(cursorPoint.path);
          point = Point(path: nodeEntry.path, offset: cursorPoint.offset);
        } else {
          point = Point(path: cursorPoint.path, offset: cursorPoint.offset);
        }
        AppLogger.slateLog.i(
            '$cursorDocumentOffset, ${textSelection.baseOffset}| currentNode $cursorPath, ${cursorPoint.offset}   textSelection ${selectionPoint.path}, ${selectionPoint.offset} 使用click');

        return Range(anchor: point, focus: point);
      }
    } else {
      final extentPoint =
          NodeLocation.offsetLocation(node, textSelection.extentOffset);
      return Range(anchor: selectionPoint, focus: extentPoint);
    }
  }

  /// 文档选区转化为基于节点的范围
  static TextSelection transformLocalRangeSelection(
      Node childNode, Range childSelection) {
    final anchorNode = childNode.get(childSelection.anchor.path);
    final baseOffset = anchorNode.blockOffset + anchorNode.offset + childSelection.anchor.offset;

    final focusNode = childNode.get(childSelection.focus.path);
    final extentOffset = focusNode.blockOffset + focusNode.offset + childSelection.focus.offset;
    return TextSelection(baseOffset: baseOffset, extentOffset: extentOffset);
  }

  /// 把本地相对于特定节点的范围转换成全局的范围
  static Range localToGlobal(Path parentPath, Range localRange) {
    final anchorPath = parentPath.followedBy(localRange.anchor.path);
    final focusPath = parentPath.followedBy(localRange.focus.path);
    return Range.of(
      anchorPath: anchorPath,
      anchorOffset: localRange.anchor.offset,
      focusPath: focusPath,
      focusOffset: localRange.focus.offset,
    );
  }

  /// 把全局的范围转换成本地相对于特定路径的范围
  static Range globalToLocal(Path parentPath, Range globalRange) {
    final anchorPath = globalRange.anchor.path.relative(parentPath);
    final focusPath = globalRange.focus.path.relative(parentPath);
    return Range.of(
      anchorPath: anchorPath,
      anchorOffset: globalRange.anchor.offset,
      focusPath: focusPath,
      focusOffset: globalRange.focus.offset,
    );
  }
}
