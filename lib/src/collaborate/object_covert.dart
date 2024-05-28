import 'package:slate/slate.dart';
import 'package:crdt/crdt.dart';

/// 这个类主要应用在初始化的时候
///   在协同发起方，这个类把当前的文档模型转换为slate文档模型，然后传输给其他协作者
///   在协作者方，这个类把对方传输过来的yjs文档模型转化为slate文档模型
class ObjectConvert {
  /// 把整个[Node]列表转换为YJS的根文档模型
  static void toSharedDoc(TypeArray<SyncNode> sharedDoc, List<Node> children) {
    sharedDoc.insert(0, children.map((node) => SyncNode.from(node)).toList());
  }

  /// 把整个YJS的根文档模型转换为[Node]列表
  static List<Node> toSlateDoc(TypeArray<SyncNode> doc) {
    return doc.map((syncNode) => syncNode.to()).toList();
  }


  /// 把普通的列表转换为slate的[Path]
  ///
  /// 需要检查这个是否为一个slate路径对象
  static Path checkToSlatePath(List<int> list) {
    return Path.of(list.where((node) => node.runtimeType == 'int'));
  }
}
