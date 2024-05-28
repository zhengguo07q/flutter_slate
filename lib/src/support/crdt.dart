import 'dart:async';

import 'package:slate/slate.dart';
import 'package:common/common.dart';
import 'package:crdt/crdt.dart';

/// YJS支持
mixin CrdtSupport on Document {
  bool isInitYjs = false;

  late bool synchronizeValue = true;
  late TypeArray<SyncNode> _sharedType;
  late String _origin;

  /// Node => SyncElement
  TypeArray<SyncNode> get sharedType => _sharedType;

  String get origin => _origin;

  /// 初始化YJS系统
  ///
  /// [sharedType] 需要共享的文档
  /// [origin] 作者
  void initYjs(TypeArray<SyncNode> sharedType, String origin) {
    _sharedType = sharedType;
    _origin = origin;
    YjsDocumentCache.sharedTypes[this] = sharedType; // 缓存
    YjsDocumentCache.localOperations[this] = <Operation>{}; // 空的本地操作集
    if (synchronizeValue) {
      Future.delayed(Duration(), () {
        Crdt.synchronizeValue(this);
      });
    }

    // 观察yjs里面的数据，并把数据传输到文档里
    sharedType.observeDeep((events, f) => applyRemoteYjsEvents(this, events));
    isInitYjs = true;
  }

  @override
  void apply(Operation op) {
    if (isInitYjs) {
      trackLocalOperations(this, op);
    }

    super.apply(op);
  }

  @override
  void onChange({bool init = false}) {
    if (isInitYjs) {
      applyLocalOperations(this);
    }
    super.onChange();
  }
}

class Crdt {
  /// 将编辑器值设置为与编辑器绑定的共享类型的内容
  static void synchronizeValue(CrdtSupport document) {
    EditorNormalizing.withoutNormalizing(document, () {
      document.setChildren(ObjectConvert.toSlateDoc(document.sharedType));
      document.onChange();
    });
  }

  /// 返回编辑器当前是否正在应用远程更改。
  static TypeArray<SyncNode> sharedType(Document document) {
    final sharedType = YjsDocumentCache.sharedTypes.get(document);
    assert(sharedType != null, 'YjsEditor without attached shared type');
    return sharedType!;
  }

  /// 返回编辑器当前是否正在应用远程更改。
  static bool isRemote(Document document) {
    return YjsDocumentCache.isRemote[document] ?? false;
  }

  /// 将操作作为远程操作执行。
  static void asRemote(Document document, Function fn) {
    final wasRemote = Crdt.isRemote(document);
    YjsDocumentCache.isRemote.add(key: document, value: true);
    fn();
    if (!wasRemote) {
      YjsDocumentCache.isRemote.remove(document);
    }
  }
}

void trackLocalOperations(Document document, Operation operation) {
  if (!Crdt.isRemote(document)) {
    final operationList = localOperations(document)!;
    AppLogger.slateLog.d('add operation, total: ${operationList.length}, current: ${operation.toString()}');
    operationList.add(operation);
  }
}

/// 本地操作的缓存
Set<Operation>? localOperations(Document document) {
  return YjsDocumentCache.localOperations.get(document);
}

/// 把本地的操作应用到yjs里面
void applyLocalOperations(CrdtSupport document) {
  final editorLocalOperations = localOperations(document)!;
  if (editorLocalOperations.isEmpty) return;
  ApplyToCrdt.applySlateOps(Crdt.sharedType(document),
      editorLocalOperations.toList(), document.origin);

  editorLocalOperations.clear();
}

/// 将Yjs事件应用到slate
///
/// [document] 需要修改的文档
/// [events] 被处理的数据
void applyRemoteYjsEvents(CrdtSupport document, List<Event> events) {
  EditorNormalizing.withoutNormalizing(document, () {
    Crdt.asRemote(document, () {
      // 过滤掉来源为自己的事件
      ApplyToSlate.applyYjsEvents(
          document,
          events
              .where((event) => event.transaction.origin != document.origin)
              .toList());
    });
  });
}
