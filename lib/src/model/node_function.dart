import 'package:dartx/dartx.dart' as dartx;

import 'package:slate/slate.dart';

typedef NodeMatch = bool Function({Node? node, Path? path});

class PathEntry {
  PathEntry(this.node, this.path);

  Node node;
  Path path;

  @override
  String toString() {
    return '\n$path ${ConvertXml2Node.toXmlElement(node).toXmlString()}';
  }
}

/// 节点代表所有自定义的元素，通过配置读取的或者其他方式定义的元素
///
/// 通过解析JSON数据，构造成了一颗NODE对象树
/// 因为节点可能代表几种对象，比如说普通的带有子节点的[KElement], 不带有子节点的[KText]，根节点[Editor]
/// 节点这里的主要功能有：
class Node extends NodeLocation {
  Node({
    String? type,
    String? text,
    List<Node>? children,
    Map<String, Attribute>? attributes,
  }) : super(
            type: type, text: text, children: children, attributes: attributes);

  /// 从json对象转换为[Node]
  factory Node.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final text = json['single'] as String?;

    Map<String, Attribute> attributes = {};
    final attributeJsonMap = json['attributes'] as Map<String, String>?;
    if (attributeJsonMap != null) {
      attributes = attributeJsonMap.map<String, Attribute>((key, value) {
        dynamic convertVal = AttributeUtil.convertStringToT(key, value);
        final attrValue = Attribute.fromKeyValue(key, convertVal)!;
        return MapEntry<String, Attribute>(key, attrValue);
      });
    }

    final children = <Node>[];
    final childrenJsonList = json['children'] as List<Map<String, dynamic>>?;
    if (childrenJsonList != null) {
      for (final child in childrenJsonList) {
        children.add(Node.fromJson(child));
      }
    }
    return Node(
        type: type, text: text, attributes: attributes, children: children);
  }

  /// 把对象转换成为JSON对象
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (type != null) json['type'] = type;
    if (text != null) json['part'] = text;
    json['attributes'] = attributes.map<String, String>(
        (String key, Attribute value) => MapEntry<String, String>(key, AttributeUtil.convertTToString(key, value)));
    ;
    if (children.isNotEmpty) {
      json['children'] = children.map((child) => child.toJson()).toList();
    }
    return json;
  }



  /// 获取特定路径位置的节点，并断言这个节点为非叶子节点
  Node ancestor(Path path) {
    final node = get(path);
    assert(!KText.isText(node),
        'Cannot get the ancestor node at path [$path] because it refers to a single node instead: $node');
    return node;
  }

  /// 返回一个特定路径上所有非叶子节点的生成器。
  ///
  /// 默认的顺序是自底向上的，在树中从最低到最高的祖先，但你可以传递' reverse: true '选项来进行自顶向下。
  Iterable<PathEntry> ancestors(Path path, {bool? reverse}) sync* {
    for (final p in path.ancestors(reverse: reverse ?? false)) {
      final n = ancestor(p);
      final entry = PathEntry(n, p);
      yield entry;
    }
  }

  /// 获取位于特定索引处的节点的子节点。
  Node child(int index) {
    assert(!KText.isText(this), 'Cannot get the child of a single node: $this');
    assert(index < children.length,
        'Cannot get child at index `$index` in node: $this');

    final c = children[index];
    return c;
  }

  /// 遍历位于特定路径上的节点的子节点。
  Iterable<PathEntry> childrenI(Path path, {bool reverse = false}) sync* {
    final ancestor = this.ancestor(path);
    final children = ancestor.children;
    var index = reverse ? children.length - 1 : 0;

    while (reverse ? index >= 0 : index < children.length) {
      final child = ancestor.child(index);
      final childPath = Path([...path, index]);
      yield PathEntry(child, childPath);
      index = reverse ? index - 1 : index + 1;
    }
  }

  /// 获取两个路径的共同祖先节点的入口。
  PathEntry common(Path path, Path another) {
    final p = path.common(another);
    final n = get(p);
    return PathEntry(n, p);
  }

  /// 获取特定路径上的节点后代
  Node descendant(Path path) {
    final node = get(path);
    assert(EditorCondition.isEditor(node) == false,
        'Cannot get the descendant node at path [$path] because it refers to the root main node instead: $node');
    return node;
  }

  /// 迭代所有的区间的子节点
  Iterable<PathEntry> descendants({
    Path? from,
    Path? to,
    bool reverse = false,
    NodeMatch? pass,
  }) sync* {
    for (final nodeEntry
        in nodes(from: from, to: to, reverse: reverse, pass: pass)) {
      if (nodeEntry.path.isNotEmpty) {
        yield nodeEntry;
      }
    }
  }

  /// 返回根节点内所有元素节点的生成器。
  ///
  /// 每次迭代都会返回一个[PathEntry]元组，由[Node] 和 [Path]组成。
  /// 如果根节点是一个元素，那么它也将包含在迭代中。
  Iterable<PathEntry> elements(
      {Path? from, Path? to, bool reverse = false, NodeMatch? pass}) sync* {
    for (final nodeEntry
        in nodes(from: from, to: to, reverse: reverse, pass: pass)) {
      if (KElement.isElement(nodeEntry.node)) {
        yield nodeEntry;
      }
    }
  }

  /// 从节点中提取属性
  Map<String, Attribute> extractProps() {
    return attributes;
  }

  /// 从路径中获取根节点中的第一个节点项(最左边的最深的)。
  ///
  /// 在做点的位置操作的时候, 需要找到所操作的位置的最里面的节点, 一般带文字的节点
  PathEntry first(Path path) {
    // 拷贝整个数组
    final p = Path.of(path);
    // 得到当前这个节点
    var n = get(p);

    // 迭代进入最左边第一个， 并取这个节点的第一个存在文本的元素，如果不存在就一直迭代，直到找到没用子节点的元素
    while (true) {
      if (KText.isText(n) || n.children.isEmpty) {
        break;
      } else {
        n = n.children[0];
        p.add(0); //追加0位置
      }
    }

    return PathEntry(n, p);
  }

  /// 获取由根节点内的范围表示的切片片段。
  List<Node> fragment(Range range) {
    assert(KText.isText(this) == false,
        'Cannot get a fragment starting from a root single node: $this');

    final rang = range.edges();
    final start = rang.start;
    final end = rang.end;
    final nodeEntries = nodes(
        reverse: true,
        pass: ({Node? node, Path? path}) {
          return !range.includes(path!);
        });

    for (final entry in nodeEntries) {
      final path = entry.path;
      if (!range.includes(path)) {
        final parent = this.parent(path);
        final index = path[path.length - 1];
        parent.children.slice(index, 1);
      }

      if (path.equals(end.path)) {
        final leaf = this.leaf(path);
        leaf.text = leaf.text!.slice(0, end.offset);
      }

      if (path.equals(start.path)) {
        final leaf = this.leaf(path);
        leaf.text = leaf.text!.slice(start.offset);
      }
    }

    if (EditorCondition.isEditor(this)) {
      (this as Document).selection = null;
    }

    return this.children;
  }

  /// 获取指定路径引用的后代节点。如果路径是空数组，则它引用根节点本身。
  Node get(Path path) {
    var node = this;

    for (var i = 0; i < path.length; i++) {
      final p = path[i];

      assert(!KText.isText(node) && node.children.length >= p,
          'Cannot find a descendant at path [$path] in node: $node');
      node = node.children[p];
    }

    return node;
  }

  /// 检查在特定路径上存在子节点。
  static bool has(Node root, Path path) {
    var node = root;

    for (var i = 0; i < path.length; i++) {
      final p = path[i];

      if (KText.isText(node) || p >= node.children.length) {
        return false;
      }

      node = node.children[p];
    }

    return true;
  }

  /// 检查一个值是否实现了' Node '接口。
  static bool isNode(value) {
    return value is Node;
  }

  /// 检查一个值是否是“Node”对象的列表。
  static bool isNodeList(List<Node> value) {
    if (value is! List<Node>) {
      return false;
    }
    final cachedResult = SlateCache.isNodeListCache.get(value);
    if (cachedResult != null) {
      return cachedResult;
    }
    final isNodeList = value.every(Node.isNode);
    SlateCache.isNodeListCache[value] = isNodeList;
    return isNodeList;
  }

  /// 从路径获取根节点中的最后一个节点条目。
  ///
  /// 在做点的位置操作的时候, 需要找到所操作的位置的最里面的节点, 一般带文字的节点
  PathEntry last(Path path) {
    //拷贝整个路径数组
    final p = Path.of(path);
    //得到这个路径最后一个节点
    var n = get(p);

    // 循环得到这个当前路径的最后一个节点的最后一个子节点，直到最后一个为文本或者孩子为0
    while (true) {
      if (KText.isText(n) || n.children.isEmpty) {
        break;
      } else {
        final i = n.children.length - 1;
        n = n.children[i];
        // 追加保存最后一个路径
        p.add(i);
      }
    }

    return PathEntry(n, p);
  }

  /// 获取特定路径上的节点，确保它是叶文本节点。
  Node leaf(Path path) {
    final node = get(path);
    assert(KText.isText(node),
        'Cannot get the leaf node at path [$path] because it refers to a non-leaf node: $node');

    return node;
  }

  /// 从特定的路径,返回一个生成器在树的一个分支，
  ///
  /// 默认情况下，顺序是自顶向下的，在树中从最低到最高的节点，但你可以通过' reverse: true '选项自下而上。
  Iterable<PathEntry> levels(Path path, {bool? reverse}) sync* {
    for (final p in path.levels(reverse: reverse ?? false)) {
      final n = get(p);
      yield PathEntry(n, p);
    }
  }

  /// 检查一个节点是否与一组道具匹配。
  bool matches(Map<String, String> props) {
    return (KElement.isElement(this) &&
            KElement.isElementProps(props) &&
            KElement.matches(this, props)) ||
        (KText.isText(this) &&
            KText.isTextProps(props) &&
            KText.matches(this, props));
  }

  /// 返回一个根节点的所有节点条目的生成器。
  ///
  /// 每个条目都以[PathEntry]元组的形式返回，其中的路径指的是节点在根节点中的位置。
  Iterable<PathEntry> nodes(
      {Path? from, Path? to, bool reverse = false, NodeMatch? pass}) sync* {
    from = from ?? Path([]); // 开始节点，默认为整个节点组
    final visited = <Node>[]; // 访问过的节点
    var p = Path.ofNull(); // 开始节点
    var n = this; // 起始的根节点
    var root = this;

    // 不断的循环，直到路径超出范围跳出
    while (true) {
      if (to != null && (reverse ? p.isBefore(to) : p.isAfter(to))) {
        break;
      }
      // 当前节点没有被返回过，则返回
      if (!visited.contains(n)) {
        yield PathEntry(n, p.copy());
      }

      // 如果允许我们往下走，而我们还没往下走，那就走。
      // 没有被包含，且属于[Element]，且没有被通过，则添加到已经访问列表里
      if (!visited.contains(n) &&
          !KText.isText(n) &&
          n.children.isNotEmpty &&
          (pass == null || pass(node: n, path: p) == false)) {
        visited.add(n);
        var nextIndex = reverse ? n.children.length - 1 : 0;
        // 取祖先之后当前from的第一个节点
        if (p.isAncestor(from)) {
          nextIndex = from[p.length];
        }

        p = p..add(nextIndex);
        n = root.get(p);
        continue;
      }

      // 在根这里，跳出
      if (p.isEmpty) {
        break;
      }

      // 如果我们要继续下一个兄弟节点处理……
      if (!reverse) {
        final newPath = p.next();

        if (Node.has(root, newPath)) {
          p = newPath;
          n = root.get(p);
          continue;
        }
      }

      // 如果我们往回走……
      if (reverse && p[p.length - 1] != 0) {
        final newPath = p.previous();
        p = newPath;
        n = root.get(p);
        continue;
      }

      // 否则会上升处理……
      p = p.parent();
      n = root.get(p);
      visited.add(n);
    }
  }

  /// 获取位于特定路径上的节点的父节点。
  Node parent(Path path) {
    final parentPath = path.parent();
    final p = get(parentPath);

    assert(!KText.isText(p),
        'Cannot get the parent of path [$path] because it does not exist in the root.');

    return p;
  }

  /// 获取节点内容的连接文本字符串。
  ///
  /// 注意，这不会包括块节点之间的空格或换行符。它不是面向用户的字符串，而是用于为节点执行与偏移量相关的计算的字符串。
  String string() {
    if (KText.isText(this)) {
      return this.text!;
    } else {
      return this.children.map((node) => node.string()).join();
    }
  }

  /// 返回根节点中所有叶文本节点的生成器。
  Iterable<PathEntry> texts(
      {Path? from, Path? to, bool reverse = false, NodeMatch? pass}) sync* {
    for (final nodeEntry
        in this.nodes(from: from, to: to, reverse: reverse, pass: pass)) {
      if (KText.isText(nodeEntry.node)) {
        yield nodeEntry;
      }
    }
  }

  /// 获取给定节点
  Point textPosition(int textOffset) {
    var markOffset = textOffset;
    final nodeEntryIter = this.texts();
    var eachEntry;
    int textLen = 0;
    for (eachEntry in nodeEntryIter) {
      assert(KText.isText(eachEntry.node));

      textLen = eachEntry.node.text!.length;
      if (markOffset < textLen) return Point.of(eachEntry.path, markOffset);
      markOffset = markOffset - textLen;
    }
    return Point.of(eachEntry.path, textLen);
  }

}
