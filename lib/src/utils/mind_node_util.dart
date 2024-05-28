import 'package:slate/slate.dart';

class TopNodeUtil {
  /// 默认插入位置为文档尾部
  static Node getSelectedTopNode(Document document) {
    final path = getSelectedTopPath(document);
    return document.get(path);
  }

  /// 得到选择的节点的路径
  static Path getSelectedTopPath(Document document) {
    final selectPath = document.selection!.focus.path;
    return selectPath.copyWith(list: selectPath.sublist(0, 1));
  }

  /// 判断当前选择的节点是不是在第一个子节点上
  static bool isSelectedFirstNode(Document document) {
    final path = getSelectedTopPath(document);
    if (path.first == 0) {
      return true;
    }
    return false;
  }

  /// 获得待插入的兄弟
  static int getSelectedIndexInParent(Document document) {
    final selectedNode = getSelectedTopNode(document);
    final parentId = selectedNode.kParentId;
    final parentNode = SlateCache.getCacheNode(parentId)!;
    var index = 0;
    // 是否存在孩子， 存在正常检查，不存在的话， 则index会未0
    final childrenIds = parentNode.kChildrenIds??[];
    final selectedNodeId = selectedNode.kId;
    for (var childrenId in childrenIds) {
      if (childrenId == selectedNodeId) {
        break;
      }
      index++;
    }
    return index;
  }

  /// 得到给定节点路径
  static Path getPath(Document document, Node node){
    var index = 0;
    for (var childNode in document.children) {
      if (childNode == node) {
        break;
      }
      index++;
    }
    return Path.of([index]);
  }
}
