/// 表示节点与节点之间的关系
enum Affinity {
  forward,  // 向前
  backward, // 向后
  outward,  // 向外
  inward,   // 向里
}


/// 代表当前操作的单位
enum Unit{
  offset,     // 给定偏移的
  character,  // 字符
  word,       // 单词
  line,       // 行的
  block,      // 块的
}

/// 光标位置
enum Edge{
  anchor,     // 描点
  focus,      // 焦点
  start,      // 最左边
  end,        // 最右边
}

enum Direction {
  forward,     // 向前
  backward     // 向后
}

/// 模式
enum Mode{
  all,        // 匹配所有元素
  highest,    // 只匹配最高位元素, 低位元素不用处理
  lowest      // 只匹配最低位元素, 高位不用处理
}