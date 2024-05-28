import 'package:slate/slate.dart';
import 'package:common/common.dart';

class SetSelectionOperation extends Operation {
  SetSelectionOperation({
    this.properties,
    this.newProperties,
  });
  late Range? properties;
  late Range? newProperties;

  late Range? oldSelection;
  late Range? newSelection;

  /// 反转设置选择操作
  @override
  Operation inverse() {
    if (properties == null) {
      return SetSelectionOperation(
        properties: newProperties,
      );
    } else if (newProperties == null) {
      return SetSelectionOperation(
        newProperties: properties,
      );
    } else {
      return SetSelectionOperation(
          properties: newProperties, newProperties: properties);
    }
  }

  /// 选择不需要转换
  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    return pathCp;
  }

  /// 选择节点不会造成影响
  @override
  List<Path> getDirtyPaths() {
    return [];
  }

  @override
  List<DirtyNode> getDirtyNodes(Document document) {
    final dirtyNodes = <DirtyNode>[];
    final oldPath = oldSelection?.common();
    if(oldPath != null && oldPath.length >= 1){
      final oldTopNode = document.get(oldPath.top());
      dirtyNodes.add(DirtyNode(oldTopNode, DirtyType.select));
    }

    // 避免设置相同的选择节点
    final newPath = newSelection?.common();
    if(newPath != null && newPath.length >= 1){
      if(oldPath != null && !oldPath.equals(newPath)){
        final newTopNode = document.get(newPath.top());
        dirtyNodes.add(DirtyNode(newTopNode, DirtyType.select));
      }
    }
    return dirtyNodes;
  }

  /// 把新的属性全部设置到选区对象里
  @override
  Range? apply(Document document, Range? selection) {
    oldSelection = selection;
    // 选择区域变为null, 直接滞空
    if (newProperties == null) {
      selection = newProperties;
    } else {
      if (selection == null) {
        assert(newProperties is Range,
            'Cannot apply an incomplete set_selection operation properties $newProperties, when there is no current selection.');
        selection = newProperties;
      } else {
        // 原来有选区，一个个设置
        if (newProperties!.anchor.isNull() == false) {
          selection.anchor = newProperties!.anchor;
        }
        if (newProperties!.focus.isNull() == false) {
          selection.focus = newProperties!.focus;
        }

        final newAttributes = newProperties!.attributes!;
        selection.attributes ??= <String, String>{};
        final selectionAttributes = selection.attributes!;

        for (final key in newAttributes.keys) {
          final value = newAttributes[key];

          if (value == null && selectionAttributes.containsKey(key)) {
            // 删除掉滞空的数据
            selectionAttributes.remove(key);
          } else {
            // 添加新的数据
            selectionAttributes[key] = value!;
          }
        }
      }
    }
    AppLogger.slateLog.i('设置选择操作：  新$newProperties  原: $properties');
    newSelection = selection;
    return selection;
  }

  @override
  Path? get path => null;
}
