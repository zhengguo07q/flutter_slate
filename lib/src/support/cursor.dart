import 'dart:collection';

import 'package:slate/slate.dart';
import 'package:crdt/crdt.dart';
import 'package:protocol/protocol.dart';

/// 光标定时广播
mixin CursorSupport on Document {
  bool _isInit = false;

  late Cursor cursor;
  late Awareness awareness;

  void initCursor(Awareness awareness) {
    cursor = Cursor(this);
    CursorCache.awareness[this] = awareness;
    this.awareness = awareness;
    this.awareness.on('update', cursor.onUpdate);
    _isInit = true;
  }

  @override
  void onChange({bool init = false}) {
    super.onChange();
    // 所有的比如光标更新等， 都需要等crdt的同步逻辑执行完成才能进行
    if (_isInit) {
      cursor.updateCursor();
    }
  }
}

class Cursor {
  static final String awarenessAnchorKey = 'anchor';
  static final String awarenessFocusKey = 'focus';

  CursorSupport document;

  Cursor(this.document);

  void onUpdate(List<dynamic> f) {
    final sharedType = (document as CrdtSupport).sharedType;
    List<Range> selection = [];
    for (var entry in document.awareness.states.entries) {
      if (entry.key == sharedType.doc!.clientID) {
        break;
      }
      Point? anchor;
      Point? focus;
      final awareness = entry.value;
      if (awareness.containsKey(awarenessAnchorKey)) {
        dynamic anchor = awareness[awarenessAnchorKey];
        relativePositionToAbsolutePosition(sharedType,
            RelativePosition.createRelativePositionFromJSON(anchor));
      }
      if (awareness.containsKey(awarenessFocusKey)) {
        dynamic focus = awareness[awarenessFocusKey];
        relativePositionToAbsolutePosition(
            sharedType, RelativePosition.createRelativePositionFromJSON(focus));
      }
      if (anchor == null || focus == null) break;
      selection.add(Range(anchor: anchor, focus: focus));
    }
    setCursorData(selection);
  }

  void updateCursor() {
    final sharedType = Crdt.sharedType(document);
    final selection = document.selection;

    if (selection != null) {
      final anchor =
          absolutePositionToRelativePosition(sharedType, selection.anchor);

      final focus =
          absolutePositionToRelativePosition(sharedType, selection.focus);

      final awareness = CursorCache.awareness.get(this.document);
      final localState = HashMap<String, Object>.of(awareness?.getLocalState() ?? {});

      localState['anchor'] = anchor;
      localState['focus'] = focus;
      awareness!.setLocalState(localState);
    }
  }

  /// 全局设置多个光标
  void setCursorData(List<Range> selection) {}
}

RelativePosition absolutePositionToRelativePosition(
    TypeArray<SyncNode> sharedType, Point point) {
  final target = getTarget(sharedType, point.path);
  final text = SyncNodeHelper.getText(target as SyncNode);
  assert(text != null, 'Slate point should point to Text node');
  return RelativePosition.createRelativePositionFromTypeIndex(
      text!, point.offset);
}

Point? relativePositionToAbsolutePosition(
    TypeArray<SyncNode> sharedType, RelativePosition relativePosition) {
  assert(sharedType.doc != null, 'Shared type should be bound to a document');

  final pos = AbsolutePosition.createAbsolutePositionFromRelativePosition(
      relativePosition, sharedType.doc!);
  if (pos == null) {
    return null;
  }

  return Point.of(getSyncNodePath(pos.type.parent as SyncNode), pos.index);
}
