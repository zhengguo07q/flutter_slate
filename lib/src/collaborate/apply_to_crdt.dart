import 'dart:math' as Math;

import 'package:slate/slate.dart';

import 'package:crdt/crdt.dart';

class ApplyToCrdt {
  static Map<Type, Function> opMappers = {
    InsertNodeOperation: ApplyToCrdt.insertNode,
    MergeNodeOperation: ApplyToCrdt.mergeNode,
    MoveNodeOperation: ApplyToCrdt.moveNode,
    RemoveNodeOperation: ApplyToCrdt.removeNode,
    SetNodeOperation: ApplyToCrdt.setNode,
    SplitNodeOperation: ApplyToCrdt.splitNode,
    InsertTextOperation: ApplyToCrdt.insertText,
    RemoveTextOperation: ApplyToCrdt.removeText,
    SetSelectionOperation: ApplyToCrdt.setSelection,
  };

  static TypeArray<SyncNode> applySlateOps(
      TypeArray<SyncNode> sharedType, List<Operation> ops, dynamic origin) {
    assert(sharedType.doc != null, 'Shared type without attached document');

    if (ops.isNotEmpty) {
      sharedType.doc!.transact((trans) {
        for (final op in ops) {
          applySlateOp(sharedType, op);
        }
      }, origin);
    }
    return sharedType;
  }

  static TypeArray<SyncNode> applySlateOp(
      TypeArray<SyncNode> sharedType, Operation op) {
    final apply = opMappers[op.runtimeType];
    if (apply == null) {
      throw UnsupportedError('Unknown operation: $op.type');
    }

    return apply(sharedType, op) as TypeArray<SyncNode>;
  }

  /// 插入节点
  static TypeArray<SyncNode> insertNode(
      TypeArray<SyncNode> doc, InsertNodeOperation op) {
    final syncParent = getParent(doc, op.path);
    final children = SyncNodeHelper.getChildren(syncParent.node);

    assert(SyncNodeHelper.getText(syncParent.node) == null || children == null,
        'Can t insert node into single node');

    children!.insert(syncParent.index, <SyncNode>[SyncNode.from(op.node)]);
    return doc;
  }

  static TypeArray<SyncNode> mergeNode(
      TypeArray<SyncNode> doc, MergeNodeOperation op) {
    final syncPoint = getParent(doc, op.path);

    final children = SyncNodeHelper.getChildren(syncPoint.node);
    assert(children != null, 'Parent of element should have children');

    final dynamic prev = children!.get(syncPoint.index - 1);
    final dynamic next = children.get(syncPoint.index);

    final prevText = SyncNodeHelper.getText(prev);
    final nextText = SyncNodeHelper.getText(next);

    if (prevText != null && nextText != null) {
      prevText.insert(prevText.length, nextText.toString());
    } else {
      final nextChildren = SyncNodeHelper.getChildren(next);
      final prevChildren = SyncNodeHelper.getChildren(prev);

      assert(nextChildren != null, 'Next element should have children');
      assert(prevChildren != null, 'Prev element should have children');

      final toPush = nextChildren!.map((dynamic child) {
        return (child as SyncNode).kClone();
      });
      prevChildren!.push(toPush.toList());
    }

    children.delete(syncPoint.index);
    return doc;
  }

  static TypeArray<SyncNode> moveNode(
      TypeArray<SyncNode> doc, MoveNodeOperation op) {
    final fromSync = getParent(doc, op.path);
    final toSync = getParent(doc, op.newPath);

    if (SyncNodeHelper.getText(fromSync.node) != null ||
        SyncNodeHelper.getText(toSync.node) != null) {
      throw UnsupportedError("Can't move node as child of a single node");
    }

    final fromChildren = SyncNodeHelper.getChildren(fromSync.node);
    final toChildren = SyncNodeHelper.getChildren(toSync.node);

    assert(fromChildren != null, 'From element should not be a single node');
    assert(toChildren != null, 'To element should not be a single node');

    final toMove = fromChildren!.get(fromSync.index) as SyncNode;
    final toInsert = toMove.kClone();

    fromChildren.delete(fromSync.index);
    toChildren!.insert(
        Math.min(toSync.index, toChildren.length), <SyncNode>[toInsert]);

    return doc;
  }

  static TypeArray<SyncNode> removeNode(
      TypeArray<SyncNode> doc, RemoveNodeOperation op) {
    final syncPoint = getParent(doc, op.path);

    if (SyncNodeHelper.getText(syncPoint.node) != null) {
      throw UnsupportedError("Can't remove node from single node");
    }

    final children = SyncNodeHelper.getChildren(syncPoint.node);
    assert(children != null, 'Parent should have children');
    children!.delete(syncPoint.index);

    return doc;
  }

  /// 得到相关节点然后设置属性
  static TypeArray<TypeMap> setNode(
      TypeArray<SyncNode> doc, SetNodeOperation op) {
    final syncNode = getTarget(doc, op.path) as SyncNode;

    op.newProperties.forEach((key, value) {
      if (key == 'children' || key == 'type') {
        throw UnsupportedError('Cannot set the "$key" property of nodes!');
      }
      if (value == null) {
        syncNode.delete(key);
      } else {
        final convertValue = AttributeUtil.convertTToString(key, value);
        syncNode.set(key, convertValue);
      }
    });
    return doc;
  }

  static TypeArray<SyncNode> splitNode(
      TypeArray<SyncNode> doc, SplitNodeOperation op) {
    final syncPoint = getParent(doc, op.path);

    final children = SyncNodeHelper.getChildren(syncPoint.node);
    assert(children != null, 'Parent of node should have children');

    final target = children!.get(syncPoint.index) as SyncNode;
    final inject = target.kClone();
    children.insert(syncPoint.index + 1, <SyncNode>[inject]);

    op.attributes.forEach((key, value) {
      final stringValue = AttributeUtil.convertTToString(key, value);
      inject.set(key, stringValue);
    });

    if (SyncNodeHelper.getText(target) != null) {
      // 文本节点分割
      final targetText = SyncNodeHelper.getText(target);
      final injectText = SyncNodeHelper.getText(inject);

      assert(targetText != null);
      assert(injectText != null);

      if (targetText!.length > op.position) {
        targetText.delete(op.position, targetText.length - op.position);
      }

      if (injectText != null) {
        injectText.delete(0, op.position);
      }
    } else {
      // 普通节点分割
      final targetChildren = SyncNodeHelper.getChildren(target);
      final injectChildren = SyncNodeHelper.getChildren(inject);

      assert(targetChildren != null);
      assert(injectChildren != null);

      targetChildren!.delete(op.position, targetChildren.length - op.position);

      injectChildren!.delete(0, op.position);
    }

    return doc;
  }

  /// 插入文本操作[InsertTextOperation]转换到[YText]
  static TypeArray<TypeMap> insertText(
      TypeArray<SyncNode> doc, InsertTextOperation op) {
    final node = getTarget(doc, op.path) as SyncNode;
    final nodeText = node.kText;

    assert(nodeText != null, 'Apply single operation to non single node');

    nodeText!.insert(op.offset, op.text);
    return doc;
  }

  /// 删除文本操作[RemoveTextOperation]转换到[YText]
  static TypeArray<TypeMap> removeText(
      TypeArray<SyncNode> doc, RemoveTextOperation op) {
    final node = getTarget(doc, op.path) as SyncNode;
    final nodeText = node.kText!;
    nodeText.delete(op.offset, op.text.length);
    return doc;
  }

  /// 选择操作暂不支持
  static TypeArray<TypeMap> setSelection(
      TypeArray<SyncNode> doc, SetSelectionOperation op) {
    return doc;
  }
}
