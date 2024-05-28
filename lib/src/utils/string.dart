RegExp SPACE = RegExp(r'\s');
RegExp PUNCTUATION = RegExp(
    r'[\u0021-\u0023\u0025-\u002A\u002C-\u002F\u003A\u003B\u003F\u0040\u005B-\u005D\u005F\u007B\u007D\u00A1\u00A7\u00AB\u00B6\u00B7\u00BB\u00BF\u037E\u0387\u055A-\u055F\u0589\u058A\u05BE\u05C0\u05C3\u05C6\u05F3\u05F4\u0609\u060A\u060C\u060D\u061B\u061E\u061F\u066A-\u066D\u06D4\u0700-\u070D\u07F7-\u07F9\u0830-\u083E\u085E\u0964\u0965\u0970\u0AF0\u0DF4\u0E4F\u0E5A\u0E5B\u0F04-\u0F12\u0F14\u0F3A-\u0F3D\u0F85\u0FD0-\u0FD4\u0FD9\u0FDA\u104A-\u104F\u10FB\u1360-\u1368\u1400\u166D\u166E\u169B\u169C\u16EB-\u16ED\u1735\u1736\u17D4-\u17D6\u17D8-\u17DA\u1800-\u180A\u1944\u1945\u1A1E\u1A1F\u1AA0-\u1AA6\u1AA8-\u1AAD\u1B5A-\u1B60\u1BFC-\u1BFF\u1C3B-\u1C3F\u1C7E\u1C7F\u1CC0-\u1CC7\u1CD3\u2010-\u2027\u2030-\u2043\u2045-\u2051\u2053-\u205E\u207D\u207E\u208D\u208E\u2329\u232A\u2768-\u2775\u27C5\u27C6\u27E6-\u27EF\u2983-\u2998\u29D8-\u29DB\u29FC\u29FD\u2CF9-\u2CFC\u2CFE\u2CFF\u2D70\u2E00-\u2E2E\u2E30-\u2E3B\u3001-\u3003\u3008-\u3011\u3014-\u301F\u3030\u303D\u30A0\u30FB\uA4FE\uA4FF\uA60D-\uA60F\uA673\uA67E\uA6F2-\uA6F7\uA874-\uA877\uA8CE\uA8CF\uA8F8-\uA8FA\uA92E\uA92F\uA95F\uA9C1-\uA9CD\uA9DE\uA9DF\uAA5C-\uAA5F\uAADE\uAADF\uAAF0\uAAF1\uABEB\uFD3E\uFD3F\uFE10-\uFE19\uFE30-\uFE52\uFE54-\uFE61\uFE63\uFE68\uFE6A\uFE6B\uFF01-\uFF03\uFF05-\uFF0A\uFF0C-\uFF0F\uFF1A\uFF1B\uFF1F\uFF20\uFF3B-\uFF3D\uFF3F\uFF5B\uFF5D\uFF5F-\uFF65]');
RegExp CHAMELEON = RegExp(r'\u2018\u2019]');
const SURROGATE_START = 0xd800;
const SURROGATE_END = 0xdfff;
const ZERO_WIDTH_JOINER = 0x200d;

/// 获取文本字符串中第一个字符末尾的距离。
int getCharacterDistance(String text) {
  var offset = 0;
  // prev types:
  // SURR: surrogate pair
  // MOD: modifier (technically also surrogate pair)
  // ZWJ: zero width joiner
  // VAR: variation selector
  // BMP: sequenceable character from basic multilingual plane
  // 'SURR' | 'MOD' | 'ZWJ' | 'VAR' | 'BMP' | null
  String? prev;
  var charCode = text.codeUnitAt(0);

  while (charCode != 0) {
    if (isSurrogate(charCode)) {
      final modifier = isModifier(charCode, text, offset);

      // Early returns are the heart of this function, where we decide if previous and current
      // codepoints should form a single character (in terms of how many of them should selection
      // jump over).
      if (prev == 'SURR' || prev == 'BMP') {
        break;
      }

      offset += 2;
      prev = modifier ? 'MOD' : 'SURR';

      charCode = 0;
      if(text.length > offset){
        charCode = text.codeUnitAt(offset);
      }
      continue;
    }

    if (charCode == ZERO_WIDTH_JOINER) {
      offset += 1;
      prev = 'ZWJ';
      charCode = text.codeUnitAt(offset);

      continue;
    }

    if (isBMPEmoji(charCode)) {
      if (prev != null && prev != 'ZWJ' && prev != 'VAR') {
        break;
      }
      offset += 1;
      prev = 'BMP';
      charCode = text.codeUnitAt(offset);

      continue;
    }

    if (isVariationSelector(charCode)) {
      if (prev != null && prev != 'ZWJ') {
        break;
      }
      offset += 1;
      prev = 'VAR';
      charCode = text.codeUnitAt(offset);
      continue;
    }

    // Modifier 'groups up' with what ever character is before that (even whitespace), need to
    // look ahead.
    if (prev == 'MOD') {
      offset += 1;
      break;
    }

    // 如果while循环到达这里，我们就完成了(例如拉丁字符)。
    break;
  }

  return offset==0 ? 1:offset;
}

/// 获取到文本字符串中第一个单词末尾的距离。
int getWordDistance(String text) {
  var length = 0;
  var i = 0;
  var started = false;

  while (text.length > i) {
    var char = text[i];
    final l = getCharacterDistance(char);
    char = text.substring(i, i + l);
    final rest = text.substring(i + l);

    if (isWordCharacter(char, rest)) {
      started = true;
      length += l;
    } else if (!started) {
      length += l;
    } else {
      break;
    }

    i += l;
  }

  return length;
}

/// 检查一个字符是否是单词字符。
/// 使用' remaining '参数是因为有时你必须读取后面的字符才能真正确定它。
bool isWordCharacter(String char, String remaining) {
  if (SPACE.hasMatch(char)) {
    return false;
  }
  //递归查看下一个是否为单词字符。
  if (CHAMELEON.hasMatch(char)) {
    var next = remaining[0];
    final length = getCharacterDistance(next);
    next = remaining.substring(0, length);
    final rest = remaining.substring(length);

    if (isWordCharacter(next, rest)) {
      return true;
    }
  }

  if (PUNCTUATION.hasMatch(char)) {
    return false;
  }

  return true;
}

/// 确定' code '是否是代理项
bool isSurrogate(int code) {
  return SURROGATE_START <= code && code <= SURROGATE_END;
}

///
///
/// https://emojipedia.org/modifiers/
bool isModifier(int code, String text, int offset) {
  if (code == 0xd83c) {
    final next = text.codeUnitAt(offset + 1);
    return next <= 0xdfff && next >= 0xdffb;
  }
  return false;
}

/// 这是一个可变的代码选择器
///
/// https://codepoints.net/variation_selectors
bool isVariationSelector(int code) {
  return code <= 0xfe0f && code >= 0xfe00;
}

/// 这是表情符号序列中使用的BMP代码之一。
///
/// https://emojipedia.org/emoji-zwj-sequences/
bool isBMPEmoji(int code) {
  // 这需要维护
  // 幸运的是，只有在新的Unicode标准发布时才会出现这种情况。
  // 如果维护跟不上，就会优雅地失败，就像Slate之前处理所有表情符号一样。
  return code == 0x2764 || // heart (❤)
          code == 0x2642 || // male (♂)
          code == 0x2640 || // female (♀)
          code == 0x2620 || // scull (☠)
          code == 0x2695 || // medical (⚕)
          code == 0x2708 || // plane (✈️)
          code == 0x25ef // large circle (◯)
      ;
}



RegExp regexSymbolWithCombiningMarks = RegExp(r'(<%= allExceptCombiningMarks %>)(<%= combiningMarks %>+)');
RegExp regexSurrogatePair = RegExp(r'([\uD800-\uDBFF])([\uDC00-\uDFFF])');

String reverseText(String string) {
  return string.split('').reversed.join();
}