import 'package:flutter/widgets.dart';
import 'package:slate/src/utils/weak_map.dart';
import 'package:crdt/crdt.dart';
import 'package:common/common.dart';
import 'package:protocol/protocol.dart';

import '../slate.dart';
import 'location/path_ref.dart';
import 'location/point_ref.dart';
import 'location/range_ref.dart';

class SlateCache {
  static WeakMap<Document, List<Path>> dirtyPaths =
      WeakMap<Document, List<Path>>();
  static WeakMap<Document, bool> flushing = WeakMap<Document, bool>();
  static WeakMap<Document, bool> normalizing = WeakMap<Document, bool>();
  static WeakMap<Document, Set<PathRef>> pathRefs =
      WeakMap<Document, Set<PathRef>>();
  static WeakMap<Document, Set<PointRef>> pointRefs =
      WeakMap<Document, Set<PointRef>>();
  static WeakMap<Document, Set<RangeRef>> rangeRefs =
      WeakMap<Document, Set<RangeRef>>();

  static WeakMap<dynamic, bool> isNodeListCache = WeakMap<dynamic, bool>();
  static WeakMap<dynamic, bool> isEditorCache = WeakMap<dynamic, bool>();

  /// 暂时没有缓存在这里
  static WeakMap<Node, int> nodeToIndex = WeakMap();
  static WeakMap<Node, Node> nodeToParent = WeakMap();

  /// 这个不是弱引用，不会被回收
  static Map<String, Node> _idToNode = {};
  static void addCacheNode(String key, Node value){
    _idToNode[key] = value;
  }
  static void removeCacheNode(String key){
    _idToNode.remove(key);
  }
  static Node? getCacheNode(String key){
    return _idToNode.get(key);
  }
  static void clearCacheNode(){
    _idToNode.clear();
  }
  static WeakMap<String, Node> itemToNode = WeakMap();
}

class HistoryCache {
  static WeakMap<Document, HistorySupport> history =
      WeakMap<Document, HistorySupport>();
  static WeakMap<Document, bool?> saving = WeakMap<Document, bool?>();
  static WeakMap<Document, bool> merging = WeakMap<Document, bool>();
}

class YjsDocumentCache {
  static WeakMap<Document, bool> isRemote = WeakMap<Document, bool>();
  static WeakMap<Document, Set<Operation>> localOperations =
      WeakMap<Document, Set<Operation>>();
  static WeakMap<Document, TypeArray<SyncNode>> sharedTypes =
      WeakMap<Document, TypeArray<SyncNode>>();
}

class CursorCache{
  static WeakMap<Document, Awareness> awareness = WeakMap<Document, Awareness>();
}

class ComponentCache{
  static WeakMap<Node, Size> lastSize = WeakMap<Node, Size>();
}