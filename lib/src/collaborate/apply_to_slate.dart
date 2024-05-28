import 'package:slate/slate.dart';
import 'package:crdt/crdt.dart';


class ApplyToSlate {
  /// 应用当前所有的YJS事件到文档
  static void applyYjsEvents(Document document, List<Event> events) {
    EditorNormalizing.withoutNormalizing(document, () {
      for (final event in events) {
        translateYjsEvent(document, event).forEach(document.apply);
      }
    });
  }

  /// 转换一个[YEvent] 到操作
  static List<Operation> translateYjsEvent(Document document, Event event) {
    if (event is TypeArrayEvent) {
      return translateArrayEvent(document, event);
    }
    if (event is TypeMapEvent) {
      return translateMapEvent(document, event);
    }
    if (event is TypeTextEvent) {
      return translateTextEvent(document, event);
    }
    throw UnsupportedError('Unsupported yjs event');
  }

  /// 将一个Yjs数组事件转换为一个slate操作。
  static List<Operation> translateArrayEvent(
      Document document, TypeArrayEvent<dynamic> event) {
    final targetPath = ObjectConvert.checkToSlatePath(event.path as List<int>);
    final targetElement = document.get(targetPath);

    assert(
        !KText.isText(targetElement), 'Cannot apply array event to single node');

    var offset = 0;
    final ops = <Operation>[];
    final children = List.of(targetElement.children);

    for (final delta in event.changes.delta) {
      if (delta.type == DeltaType.retain) {
        offset += delta.amount ?? 0;
      }

      if (delta.type == DeltaType.delete) {
        final path = Path.of([...targetPath, offset]);
        children
          ..removeRange(offset, offset + (delta.amount ?? 0))
          ..forEach(
              (node) => {ops.add(RemoveNodeOperation(path: path, node: node))});
      }

      if (delta.type == DeltaType.insert) {
        assert(delta.inserts != null,
            'Unexpected array insert content type: expected array, got $delta.insert');

        final toInsert = delta.inserts!.map<dynamic>((syncNode)=>(syncNode as SyncNode).to());

        const i = 0;
        toInsert.fold<int>(i, (i, dynamic node) {
          ops.add(InsertNodeOperation(
              path: Path.of([...targetPath, offset + i]), node: node as Node));
          return i++;
        });

        children.insertAll(offset, toInsert as Iterable<Node>);
        offset += delta.inserts!.length;
      }
    }

    return ops;
  }

  /// 将一个Yjs[YMapEvent]对象事件转换为一个slate操作。
  static List<Operation> translateMapEvent(
      Document document, TypeMapEvent<dynamic> event) {
    final targetPath = ObjectConvert.checkToSlatePath(event.path as List<int>);
    final targetSyncElement = event.target as SyncNode;
    final targetElement = document.get(targetPath);

    final keyChanges = event.changes.keys.entries;
    // 构造新的属性
    final newProperties = <String, Attribute>{};
    for (final changeEntry in keyChanges) {
      String? value;
      if (changeEntry.value.action != YChangeType.delete) {
        value = targetSyncElement.get(changeEntry.key) as String;
      }
      if (value != null) {
        newProperties[changeEntry.key] = Attribute.fromKeyValue(changeEntry.key, value)!;
      } else {
        newProperties.remove(changeEntry.key);
      }
    }
    // 取出旧的属性
    final properties = <String, Attribute>{};
    for (final changeEntry in keyChanges) {
      final attr = targetElement.attributes[changeEntry.key];
      if (attr != null) {
        newProperties[changeEntry.key] = attr.value;
      }
    }

    return [
      SetNodeOperation(
          path: targetPath,
          properties: properties,
          newProperties: newProperties)
    ];
  }

  /// 将一个Yjs[YTextEvent]文本事件转换为一个slate操作。
  static List<Operation> translateTextEvent(
      Document document, TypeTextEvent event) {
    final targetPath = ObjectConvert.checkToSlatePath(event.path as List<int>);
    final targetText = document.get(targetPath);

    assert(KText.isText(targetText), 'Cannot apply single event to non-single node');

    var offset = 0;
    var text = targetText.text!;
    final ops = <Operation>[];

    for (final delta in event.changes.delta) {
      if (delta.type == DeltaType.retain) {
        offset += delta.amount ?? 0;
      }

      if (delta.type == DeltaType.delete) {
        final endOffset = offset + (delta.amount ?? 0);
        ops.add(RemoveTextOperation(
            path: targetPath,
            offset: offset,
            text: text.substring(offset, endOffset)));
        text = text.substring(0, offset) + text.substring(endOffset);
      }

      if (delta.type == DeltaType.insert) {
        assert(delta.inserts.toString() == 'string',
            'Unexpected single insert content type: expected string, got ${delta.inserts}');

        ops.add(InsertTextOperation(
            path: targetPath, offset: offset, text: delta.inserts.toString()));

        offset += delta.inserts!.length;
        text = text.substring(0, offset) +
            delta.inserts.toString() +
            text.substring(offset);
      }
    }

    return ops;
  }
}
