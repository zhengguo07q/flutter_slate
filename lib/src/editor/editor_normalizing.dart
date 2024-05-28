import 'package:slate/slate.dart';

class EditorNormalizing {
  /// 检查编辑器是否可执行规范化逻辑。
  ///
  /// 用来避免重入规范化函数
  /// 第一次设置的时候他处于null状态。这个时候他返回的允许。
  static bool isNormalizing(Document document) {
    final isNormalizing = SlateCache.normalizing.get(document);
    return isNormalizing ?? true;
  }

  /// 手动设置，如果编辑器当前应该是正常化。
  ///
  /// 注意:不正确地使用这个会使编辑器处于无效状态。
  static void setNormalizing(Document document, bool isNormalizing) {
    SlateCache.normalizing[document] = isNormalizing;
  }

  /// 调用一个函数，调用过程中不规范化。
  static void withoutNormalizing(Document document, Function fn) {
    final value = isNormalizing(document);
    setNormalizing(document, false);
    // fn();
    try {
      fn();
    } catch (e, s) {
      print('exception details:\n $e');
      print('stack trace:\n $s');
    } finally {
      setNormalizing(document, value);
    }
    normalize(document);
  }

  /// 在编辑器中规范化脏对象, 确保处理过后的文档最终是正常状态。
  ///
  /// 比如因为删除文本而把整个文本节点给删掉了，这时候需要插入一个空字符串文本
  static void normalize(Document document, {bool? force = false}) {
    // 得到当前所有脏掉的路径
    List<Path> getDirtyPaths(Document document) {
      return SlateCache.dirtyPaths.get(document) ?? [];
    }

    // 如果回退过程中，也就是在进行复合操作过程中，这个时候还没操作完，不需要进行规范化
    if (!isNormalizing(document)) {
      return;
    }

    assert((){
      document.debugOperationList!.clear();
      return true;
    }());

    // 强制对整个文档进行标记脏对象，预备处理整个文档
    if (force == true) {
      final allPaths =
          List<Path>.from(document.nodes().map<Set<Path>>((e) => {e.path}));
      SlateCache.dirtyPaths[document] = allPaths;
    }

    if (getDirtyPaths(document).isEmpty) {
      return;
    }

    withoutNormalizing(document, () {
      /*
      修复没有子元素的脏元素。
      main.normalizeNode()确实修复了这个问题，但一些规范化修复也需要它工作。
      运行初始通行证可以避免catch-22竞争条件。
      */

      final dirtyPaths = getDirtyPaths(document);
      for (final dirtyPath in dirtyPaths) {
        // 脏路径节点还存在
        if (Node.has(document, dirtyPath)) {
          // 获得这个脏路径的节点
          final dirtyNodeEntry = LocationPathEntry.node(document, dirtyPath);

          // 为没有子元素的元素添加文本子元素。
          // 对任何路径都是安全的，根据定义，它不会导致其他路径改变。
          // 节点是元素并且子节点为空,则需要给它添加一个空的文本节点
          if (KElement.isElement(dirtyNodeEntry.node) &&
              dirtyNodeEntry.node.children.isEmpty) {
            final child = Node(type: 'single', text: '');
            NodeTransforms.insertNodes(
              document,
              [child],
              atl: dirtyPath..add(0),
              voids: true,
            );
          }
        }
      }

      final max = getDirtyPaths(document).length * 42; // HACK: better way?
      var m = 0;

      // 依次对脏路径位置的所有子节点进行节点规范化
      while (getDirtyPaths(document).isNotEmpty) {
        assert(m <= max,
            'Could not completely normalize the main after $max iterations! This is usually due to incorrect normalization logic that leaves a node in an invalid state.');
        final dirtyPaths = getDirtyPaths(document);
        final dirtyPath = dirtyPaths.removeLast();
        // 如果节点在树中不存在，则不需要对其进行规范化。
        if (Node.has(document, dirtyPath)) {
          final entry = LocationPathEntry.node(document, dirtyPath);
          document.normalizeNode(entry);
        }
        m++;
      }
    });
  }
}

extension DocumentNormalizing on Document {
  /// 节点规范化
  void normalizeNode(PathEntry entry) {
    final node = entry.node;
    final path = entry.path;
    // 文本节点不需要处理，返回。
    if (KText.isText(node)) {
      return;
    }

    // 确保块节点和内联节点至少有一个文本子节点。
    // [Editor.normalize]规范化的时候已经处理过一次。这里确保。
    if (KElement.isElement(node) && node.children.isEmpty) {
      final child = Node(text: '');
      NodeTransforms.insertNodes(this, [child],
          atl: Path.of(path.followedBy([0])), voids: true);
      return;
    }

    // 确定节点应该具有块子节点还是内联子节点。
    final shouldHaveInlines = EditorCondition.isEditor(node)
        ? false
        : KElement.isElement(node) &&
            (KElement.isInline(node) || //行内节点
                node.children.isEmpty || //不存在子节点
                KText.isText(node.children[0]) || //子节点是文本节点
                KElement.isInline(node.children[0])); //子节点是行内节点

    // 因为我们将在迭代过程中应用操作，所以要跟踪包含所有添加/删除节点的索引。
    var n = 0;

    for (var i = 0; i < node.children.length; i++, n++) {
      final currentNode = this.get(path);
      // 子文本节点不用处理
      if (KText.isText(currentNode)) continue;
      final child = node.children[i]; // 0
      final prevPos = n - 1; //0
      final prev = 0 <= prevPos && prevPos < currentNode.children.length
          ? currentNode.children[prevPos]
          : null;
      final isLast = i == node.children.length - 1;
      final isInlineOrText =
          KText.isText(child) || (KElement.isElement(child) && KElement.isInline(child));

      // 只允许块节点在顶层子块和只包含块节点的父块中。
      // 类似地，只允许其他内联节点中的内联节点或只包含内联和文本的父块中的内联节点。
      if (isInlineOrText != shouldHaveInlines) {
        NodeTransforms.removeNodes(this,
            atl: Path.of(path.followedBy([n])), voids: true);
        n--;
      } else if (KElement.isElement(child)) {
        // 确保内联节点包围文本节点。
        if (KElement.isInline(child)) {
          if (prev == null || !KText.isText(prev)) {
            final newChild = Node(text: '');
            NodeTransforms.insertNodes(
              this,
              [newChild],
              atl: Path.of(path.followedBy([n])),
              voids: true,
            );
            n++;
          } else if (isLast) {
            final newChild = Node(text: '');
            NodeTransforms.insertNodes(
              this,
              [newChild],
              atl: Path.of(path.followedBy([n + 1])),
              voids: true,
            );
            n++;
          }
        }
      } else {
        // 合并调整为空的或被匹配的文本节点。
        if (prev != null && KText.isText(prev)) {
          if (KText.equals(child, prev, loose: true)) {
            NodeTransforms.mergeNodes(this,
                atl: Path.of(path.followedBy([n])), voids: true);
            n--;
          } else if (prev.text == '') {
            NodeTransforms.removeNodes(
              this,
              atl: Path.of(path.followedBy([n - 1])),
              voids: true,
            );
            n--;
          } else if (isLast && child.text == '') {
            NodeTransforms.removeNodes(
              this,
              atl: Path.of(path.followedBy([n])),
              voids: true,
            );
            n--;
          }
        }
      }
    }
  }
}
