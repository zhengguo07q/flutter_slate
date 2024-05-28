import 'package:slate/slate.dart';
import 'package:slate/src/transforms/node_insert_nodes.dart';
import 'package:slate/src/transforms/node_lift_nodes.dart';
import 'package:slate/src/transforms/node_merge_nodes.dart';
import 'package:slate/src/transforms/node_move_nodes.dart';
import 'package:slate/src/transforms/node_remove_nodes.dart';
import 'package:slate/src/transforms/node_set_nodes.dart';
import 'package:slate/src/transforms/node_split_nodes.dart';
import 'package:slate/src/transforms/node_unset_nodes.dart';
import 'package:slate/src/transforms/node_unwrap_nodes.dart';
import 'package:slate/src/transforms/node_wrap_nodes.dart';
import 'package:slate/src/transforms/selection_collapse.dart';
import 'package:slate/src/transforms/selection_deselect.dart';
import 'package:slate/src/transforms/selection_move.dart';
import 'package:slate/src/transforms/selection_select.dart';
import 'package:slate/src/transforms/selection_set_point.dart';
import 'package:slate/src/transforms/selection_set_selection.dart';
import 'package:slate/src/transforms/text_delete.dart';
import 'package:slate/src/transforms/text_insert_fragment.dart';
import 'package:slate/src/transforms/text_insert_text.dart';

NodeMatch matchPath(Document document, Path path) {
  final nodeEntry = LocationPathEntry.node(document, path);
  return ({Node? node, Path? path}) => node == nodeEntry.node;
}


class NodeTransforms {
  static Future<void> insertNodes(Document document, List<Node> nodes,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool? select,
      bool voids = false}) async {
    nodeInsertNodes(document, nodes,
        atl: atl,
        match: match,
        mode: mode,
        hanging: hanging,
        select: select,
        voids: voids);
  }

  static void removeNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool voids = false}) {
    nodeRemoveNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      hanging: hanging,
      voids: voids,
    );
  }

  static void moveNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      required Path to,
      bool voids = false}) {
    nodeMoveNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      to: to,
      voids: voids,
    );
  }

  static void mergeNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool voids = false}) {
    nodeMergeNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      hanging: hanging,
      voids: voids,
    );
  }

  static void splitNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool always = false,
      int height = 0,
      bool voids = false}) {
    nodeSplitNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      always: always,
      height: height,
      voids: voids,
    );
  }

  static void liftNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool voids = false}) {
    nodeLiftNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      voids: voids,
    );
  }

  static void setNodes(
    Document document,
    Map<String, Attribute?> props, {
    Location? atl,
    NodeMatch? match,
    Mode mode = Mode.lowest,
    bool hanging = false,
    bool split = false,
    bool voids = false,
  }) {
    nodeSetNodes(
      document,
      props,
      atl: atl,
      match: match,
      mode: mode,
      hanging: hanging,
      split: split,
      voids: voids,
    );
  }

  static void unsetNodes(Document document, dynamic prop,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    nodeUnsetNodes(
      document,
      prop,
      atl: atl,
      match: match,
      mode: mode,
      split: split,
      voids: voids,
    );
  }

  static void unwrapNodes(Document document,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    nodeUnwrapNodes(
      document,
      atl: atl,
      match: match,
      mode: mode,
      split: split,
      voids: voids,
    );
  }

  static void wrapNodes(Document document, Node element,
      {Location? atl,
      NodeMatch? match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    nodeWrapNodes(
      document,
      element,
      atl: atl,
      match: match,
      mode: mode,
      split: split,
      voids: voids,
    );
  }
}

class TextTransforms {
  static void delete(
    Document document, {
    Location? atl,
    int distance = 1,
    Unit unit = Unit.character,
    bool reverse = false,
    bool hanging = false,
    bool voids = false,
  }) {
    textDelete(document,
        atl: atl,
        distance: distance,
        unit: unit,
        reverse: reverse,
        hanging: hanging,
        voids: voids);
  }

  static void insertFragment(
    Document document,
    List<Node> fragment, {
    Location? atl,
    bool hanging = false,
    bool voids = false,
  }) {
    textInsertFragment(
      document,
      fragment,
      atl: atl,
      hanging: hanging,
      voids: voids,
    );
  }

  static void insertText(
    Document document,
    String text, {
    Location? atl,
    bool voids = false,
  }) {
    textInsertText(
      document,
      text,
      atl: atl,
      voids: voids,
    );
  }
}

class SelectionTransforms {
  /// 闭合选取到特定位置
  ///
  /// [Edge]的四个位置
  static void collapse(
    Document document, {
    Edge edge = Edge.anchor,
  }) {
    selectionCollapse(
      document,
      edge: edge,
    );
  }

  static void deselect(Document document) {
    selectionDeselect(document);
  }

  /// 移动选区位置
  static void move(Document document,
      {int distance = 1,
      Unit? unit = Unit.character,
      bool? reverse = false,
      Edge? edge}) {
    selectionMove(
      document,
      distance: distance,
      unit: unit,
      reverse: reverse,
      edge: edge,
    );
  }

  /// 选择特定的位置
  static void select(
    Document document,
    Location target,
  ) {
    selectionSelect(
      document,
      target,
    );
  }

  static void setPoint(
    Document document,
    Map<String, String> attributes, {
    Edge edge = Edge.start,
  }) {
    selectionSetPoint(
      document,
      attributes,
      edge: edge,
    );
  }

  static void setSelection(
    Document document,
    Range newSelection,
  ) {
    selectionSetSelection(
      document,
      newSelection,
    );
  }
}


