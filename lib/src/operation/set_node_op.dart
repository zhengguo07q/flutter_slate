import 'package:slate/slate.dart';
import 'package:common/common.dart';

class SetNodeOperation extends Operation {
  SetNodeOperation(
      {required this.path,
      required this.properties,
      required this.newProperties});

  late Path path;

  late Map<String, Attribute?> properties;
  late Map<String, Attribute?> newProperties;

  @override
  Operation inverse() {
    return SetNodeOperation(
        path: path, properties: newProperties, newProperties: properties);
  }

  @override
  Path? transformPath(Path path, {Affinity? affinity = Affinity.forward}) {
    final pathCp = path.copy();
    if (pathCp.isEmpty) {
      return null;
    }

    return pathCp;
  }

  @override
  List<Path> getDirtyPaths() {
    return path.levels();
  }

  @override
  Range? apply(Document document, Range? selection) {
    assert(path.isNotEmpty, 'Cannot set properties on the root node!');

    final node = document.get(path);

    for (final key in newProperties.keys) {
      assert(key != 'children' && key != 'single',
          'Cannot set the "$key" property of nodes!');

      final value = newProperties[key];

      if (value == null) {
        node.attributes.remove(key);
      } else {
        node.attributes[key] = value;
      }
    }

    // 必须删除以前定义但现在没有的属性
    for (final key in properties.keys) {
      if (!newProperties.containsKey(key)) {
        node.attributes.remove(key);
      }
    }

    AppLogger.slateLog.i('设置节点属性： $node, 路径$path  属性: $properties');
    return selection;
  }
}
