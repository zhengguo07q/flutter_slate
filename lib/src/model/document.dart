import 'package:slate/slate.dart';
import 'package:common/common.dart';

import '../support/cursor.dart';

typedef ChangeCallback = void Function({bool init});

class DocumentRoot extends Document
    with CrdtSupport, CursorSupport, HistorySupport, TestSupport {
  DocumentRoot();

  factory DocumentRoot.fromJson(List<dynamic> json) {
    final list = json
        .map((dynamic entry) => Node.fromJson(entry as Map<String, dynamic>))
        .toList();
    final document = DocumentRoot()..replaceChildren(list);
    return document;
  }

  factory DocumentRoot.fromXml(String xmlString) {
    final xmlDocument = ConvertXml2Node.toNodeDocument(xmlString);
    final document = DocumentRoot()..replaceChildren(xmlDocument.children);
    return document;
  }

  /// 替换数据
  ///
  /// 替换完后会调用初始化逻辑和驱动逻辑
  replaceChildren(List<Node> children) {
    this
      ..children = children
      ..initialize()
      ..onChange(init: true);
  }
}

class Document extends Node {
  List<Operation>? debugOperationList;
  ChangeCallback? callback;
  Range? selection;
  List<Operation> operations = [];

  /// 这个属性为优化查找选择
  Map<String, Attribute>? marks;
  bool isInit = false;

  /// 保存每帧被处理的脏的路径，可以根据这个用来做比如保存等
  List<DirtyNode> frameDirtyNodes = [];

  /// 初始化逻辑
  ///
  /// 在第一次的时候，要把所有的节点全部标记为脏, 目的是为了更新长度和缓存
  /// 但是第一次初始化是不需要保存的， 所以保存逻辑那里需要做初始化为
  void initialize() {
    assert(() {
      debugOperationList = [];
      return true;
    }());
    this.frameDirtyNodes.clear();
    this.children.forEach((element) {
      final dirtyNode = DirtyNode(element, DirtyType.insert);
      frameDirtyNodes.add(dirtyNode);
    });
    isInit = true;
  }

  setChildren(List<Node> children) {
    this.children = children;
    initialize();
  }

  /// 数据被改变后需要被调用
  ///
  /// [init] 第一次初始化的时候有些改变逻辑是不需要的
  void onChange({bool init = false}) {
    handlerGlobal();
    handlerDirtyNode();
    if (callback != null) {
      callback!.call(init: init);
    }
  }

  /// 更新缓存引用和思维导图节点之间的关系
  ///
  /// 这个是顶层节点，数据量会比较小
  void handlerGlobal() {
    updateCacheNode(); // 建立一个ID到思维导图节点关系的缓存
    updateTreeRelation(); // 更新思维导图节点的关系树
  }

  /// 只有节点变脏后才会出处理节点里面的内部逻辑
  /// 脏节点
  void handlerDirtyNode() {
    frameDirtyNodes.forEach((dirtyNode) {
      dirtyNode.node.updateTextNode();
    });
  }

  /// 缓存节点关系信息
  void updateCacheNode() {
    SlateCache.clearCacheNode();
    for (final child in this.children) {
      // 只有存在属性ID，它的孩子才有保存的意义
      if (child.containsAttributeKey(AttributeRegister.id.key)) {
        SlateCache.addCacheNode(child.kId, child);
      }
    }
  }

  /// 在这里建立树的关系，主要是为了后面得到树的深度
  ///
  /// 这个必须要在外面，而且大多基本上每次更新都需要处理， 比如说设置属性等
  void updateTreeRelation() {
    //AppLogger.docLog.i('updateTreeRelation start');
    Function(Node node, int depth)? buildTree;
    buildTree = (Node node, int depth) {
      //AppLogger.slateLog.d('setting depth ${node.kId} $depth');
      node.nodeCache.depth = depth;
      depth++;

      final childrenIds = node.kChildrenIds;
      if (childrenIds == null || childrenIds.isEmpty) {
        return;
      }

      for (final id in node.kChildrenIds!) {
        final item = SlateCache.getCacheNode(id);
        //TODO 可能存在错误，childrenIds里面有ID， 但是不存在对应的节点，当前暂时跳出不处理 需要fix
        if (item == null) {
          AppLogger.docLog
              .e('updateTreeRelation error item = null  id: $id , $depth');
          continue;
        }
        // AppLogger.docLog.i(
        //   'updateTreeRelation ${'\t' * (depth - 1)}▸ $id, depth:$depth, path:${item.getPath()}, type:${item.type}',
        // );
        buildTree!(item, depth);
      }
    };
    if (children.isNotEmpty) {
      buildTree(children.first, 1);
    }
  }

  /// 执行操作
  ///
  /// 最终所有的操作都会走这里
  void apply(Operation op) {
    assert(() {
      debugOperationList!.add(op);
      return true;
    }());
    // 这个操作转换之前会设置一些可能需要转换的路径引用，在这个具体的操作执行之前，要进行这些路径的转换
    // 避免这些路径因为操作后，出现路径指向不准确的问题
    for (final ref in EditorRef.pathRefs(this)) {
      ref.transform(op);
    }

    for (final ref in EditorRef.pointRefs(this)) {
      ref.transform(op);
    }

    for (final ref in EditorRef.rangeRefs(this)) {
      ref.transform(op);
    }

    // 这里是一个路径优化，可能会存在相同的脏路径
    final set = <String>{};
    final dirtyPaths = <Path>[];

    void add(Path? path) {
      if (path != null) {
        final key = path.join(',');

        if (!set.contains(key)) {
          set.add(key);
          dirtyPaths.add(path);
        }
      }
    }

    final oldDirtyPaths = SlateCache.dirtyPaths.get(this) ?? [];
    // 所有会被影响到的新的路径
    final newDirtyPaths = op.getDirtyPaths();

    for (final path in oldDirtyPaths) {
      final newPath = op.transformPath(path);
      add(newPath);
    }

    for (final path in newDirtyPaths) {
      add(path);
    }

    SlateCache.dirtyPaths[this] = dirtyPaths;

    selection = op.apply(this, selection);

    frameDirtyNodes.addAll(op.getDirtyNodes(this));
    operations.add(op);

    EditorNormalizing.normalize(this);

    // 如果选择发生变化，清除应用于光标的任何格式。
    if (op is SetSelectionOperation) {
      marks = null;
    }

    // 刷新， 这里是需要延迟调用的
    final flushing = SlateCache.flushing.get(this);
    if (flushing == null || flushing == false) {
      SlateCache.flushing[this] = true;
      Future.microtask(() {
        SlateCache.flushing[this] = false;

        onChange();
        operations = [];
      });
    }
  }

  /// 打印document
  printDocument() {
    StringBuffer stringBuffer = StringBuffer();
    children.forEach((node) {
      stringBuffer.writeln(node.toString());
    });
    AppLogger.slateLog.i(stringBuffer.toString());
  }
}
