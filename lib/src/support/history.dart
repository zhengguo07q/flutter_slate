import 'dart:collection';

import 'package:slate/slate.dart';


mixin HistorySupport on Document {
  late History history;
  bool _isInit = false;

  @override
  void initialize() {
    history = History(this);
    _isInit = true;
    return super.initialize();
  }

  @override
  void apply(Operation op) {
    if (_isInit) {
      history.apply(op);
    }
    super.apply(op);
  }
}

class History {
  History(this.document);

  late HistorySupport document;

  final Queue<Queue<Operation>> undoList =
  Queue<Queue<Operation>>();
  final Queue<Queue<Operation>> redoList =
  Queue<Queue<Operation>>();

  bool get hasUndo => undoList.isNotEmpty;

  bool get hasRedo => redoList.isNotEmpty;

  void apply(Operation op) {
    // 取最后一个操作列表，取最后一个操作
    Queue<Operation>? lastBatch;
    Operation? lastOp;
    if (undoList.isNotEmpty) {
      lastBatch = undoList.last;
      if (lastBatch.isNotEmpty) {
        lastOp = lastBatch.last;
      }
    }

    // 是否覆盖，相同或组合无意义操作
    final overwrite = History.shouldOverwrite(op, lastOp);
    // 做undo redo时候不保存
    var save = History.isSaving(document);
    // 是否正在进行合并。相同类型的操作合并
    var merge = History.isMerging(document);

    if (save == false) {
      save = History.shouldSave(op, lastOp);
    }

    // 需要保存的普通操作
    if (save == null) {
      if (merge == false) {
        if (lastBatch == null) {
          merge = false;
        } else if (document.operations.isNotEmpty) {
          merge = true;
        } else {
          // 相同类型的操作合并
          merge = History.shouldMerge(op, lastOp) || overwrite;
        }
      }

      if (lastBatch != null && merge) {
        // 覆盖的话，是删除之前最后一个，因为这个无意义
        if (overwrite) {
          lastBatch.removeLast();
        }
        // 把当前操作添加进去？
        lastBatch.addLast(op);
      } else {
        // 一个全新的历史
        final batch = Queue<Operation>.from([op]);
        undoList.addLast(batch);
      }

      // 长度是否被溢出
      while (undoList.length > 100) {
        undoList.removeFirst();
      }

      // 有了新的undo 则redo不能要了
      if (History.shouldClear(op)) {
        redoList.clear();
      }
    }
  }

  void redo() {
    if (hasRedo) {
      final batch = redoList.last;
      withoutSaving(document, () {
        EditorNormalizing.withoutNormalizing(document, () {
          for (final op in batch) {
            document.apply(op);
          }
        });
      });

      redoList.removeLast();
      undoList.addLast(batch);
    }
  }

  void undo() {
    if (hasUndo) {
      final batch = undoList.last;
      final inverseOps =
      Queue.from(batch.map((op) => op.inverse()).toList().reversed);

      withoutSaving(document, () {
        EditorNormalizing.withoutNormalizing(document, () {
          for (final op in inverseOps) {
            document.apply(op);
          }
        });
      });

      redoList.addLast(batch);
      undoList.removeLast();
    }
  }

  static void withoutSaving(Document document, Function fn) {
    final prev = isSaving(document);
    HistoryCache.saving[document] = false;
    fn();
    HistoryCache.saving[document] = prev;
  }

  static bool isMerging(Document document) {
    return HistoryCache.merging[document] ?? false;
  }

  static bool? isSaving(Document document) {
    return HistoryCache.saving[document] ?? null;
  }

  /// 是否需要将某个操作合并到之前的操作中。
  ///
  /// 设置属性操作合并
  /// 相同位置的插入文本操作合并
  /// 相同位置的删除文本操作合并
  static bool shouldMerge(Operation op, Operation? prev) {
    if (op is SetSelectionOperation) {
      return true;
    }

    if (prev != null &&
        op is InsertTextOperation &&
        prev is InsertTextOperation &&
        op.offset == prev.offset + prev.text.length &&
        op.path.equals(prev.path)) {
      return true;
    }

    if (prev != null &&
        op is RemoveTextOperation &&
        prev is RemoveTextOperation &&
        // deleteBackward merge
        (op.offset + op.text.length == prev.offset ||
            // deleteForward merge
            op.offset == prev.offset) &&
        op.path.equals(prev.path)) {
      return true;
    }

    return false;
  }

  /// 检查操作是否需要保存到历史记录。
  static bool shouldSave(Operation op, Operation? prev) {
    if (op is SetSelectionOperation &&
        (op.properties == null || op.newProperties == null)) {
      return false;
    }
    return true;
  }

  /// 检查某个操作是否需要覆盖上一个操作。
  ///
  /// 前一个是选择操作，后一个也是选择操作，则合并
  /// 前一个是删除操作，后一个是插入操作，这两个操作节点相同，则合并
  static bool shouldOverwrite(Operation op, Operation? prev) {
    if (prev != null &&
        op is SetSelectionOperation &&
        prev is SetSelectionOperation) {
      return true;
    }
    return false;
  }

  /// 检查是否需要清除redo堆栈。
  static bool shouldClear(Operation op) {
    if (op is SetSelectionOperation) {
      return false;
    }
    return true;
  }
}
