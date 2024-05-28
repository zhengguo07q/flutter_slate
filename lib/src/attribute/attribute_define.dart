import 'dart:collection';

import 'attribute_clazz.dart';
import 'attribute.dart';

class AttributeRegister {
  static final Map<String, Attribute> registry = LinkedHashMap.of({
    bold.key: bold,
    italic.key: italic,
    small.key: small,
    underline.key: underline,
    strikeThrough.key: strikeThrough,
    inlineCode.key: inlineCode,
    font.key: font,
    size.key: size,
    link.key: link,
    color.key: color,
    background.key: background,
    placeholder.key: placeholder,
    header.key: header,
    align.key: align,
    direction.key: direction,
    list.key: list,
    codeBlock.key: codeBlock,
    blockQuote.key: blockQuote,
    indent.key: indent,
    width.key: width,
    height.key: height,
    style.key: style,
    token.key: token,
    script.key: script,
    // 节点关系
    id.key: id,
    parentId.key: parentId,
    childrenIds.key: childrenIds,
    // 思维导图主题
    mindThemeId.key: mindThemeId,
    mindThemeBorderStyle.key: mindThemeBorderStyle,
    mindThemeBorderWidget.key: mindThemeBorderWidget,
    mindThemeBorderColor.key: mindThemeBorderColor,
    mindThemeLineShape.key: mindThemeLineShape,
    mindThemeLineStyle.key: mindThemeLineStyle,
    mindThemeLineEndPoint.key: mindThemeLineEndPoint,
    mindThemeLineWidth.key: mindThemeLineWidth,
    mindThemeLineColor.key: mindThemeLineColor,
    // 文档主题
    docThemeId.key: docThemeId,
  });

  static final BoldAttribute bold = BoldAttribute();

  static final ItalicAttribute italic = ItalicAttribute();

  static final SmallAttribute small = SmallAttribute();

  static final UnderlineAttribute underline = UnderlineAttribute();

  static final StrikeThroughAttribute strikeThrough = StrikeThroughAttribute();

  static final InlineCodeAttribute inlineCode = InlineCodeAttribute();

  static final FontAttribute font = FontAttribute(null);

  static final SizeAttribute size = SizeAttribute(null);

  static final LinkAttribute link = LinkAttribute(null);

  static final ColorAttribute color = ColorAttribute(null);

  static final BackgroundAttribute background = BackgroundAttribute(null);

  static final PlaceholderAttribute placeholder = PlaceholderAttribute();

  static final HeaderAttribute header = HeaderAttribute();

  static final IndentAttribute indent = IndentAttribute();

  static final AlignAttribute align = AlignAttribute(null);

  static final ListAttribute list = ListAttribute(null);

  static final CodeBlockAttribute codeBlock = CodeBlockAttribute();

  static final BlockQuoteAttribute blockQuote = BlockQuoteAttribute();

  static final DirectionAttribute direction = DirectionAttribute(null);

  static final WidthAttribute width = WidthAttribute(null);

  static final HeightAttribute height = HeightAttribute(null);

  static final StyleAttribute style = StyleAttribute(null);

  static final TokenAttribute token = TokenAttribute('');

  static final ScriptAttribute script = ScriptAttribute('');

  static const String mobileWidth = 'mobileWidth';

  static const String mobileHeight = 'mobileHeight';

  static const String mobileMargin = 'mobileMargin';

  static const String mobileAlignment = 'mobileAlignment';

  static final Set<String> inlineKeys = {
    bold.key,
    italic.key,
    small.key,
    underline.key,
    strikeThrough.key,
    link.key,
    color.key,
    background.key,
    placeholder.key,
  };

  static final Set<String> blockKeys = LinkedHashSet.of({
    header.key,
    align.key,
    list.key,
    codeBlock.key,
    blockQuote.key,
    indent.key,
    direction.key,
  });

  static final Set<String> blockKeysExceptHeader = LinkedHashSet.of({
    list.key,
    align.key,
    codeBlock.key,
    blockQuote.key,
    indent.key,
    direction.key,
  });

  static final Set<String> exclusiveBlockKeys = LinkedHashSet.of({
    header.key,
    list.key,
    codeBlock.key,
    blockQuote.key,
  });

  static Attribute<int?> h1 = HeaderAttribute(level: 1);

  static Attribute<int?> h2 = HeaderAttribute(level: 2);

  static Attribute<int?> h3 = HeaderAttribute(level: 3);

  // "attributes":{"align":"left"}
  static Attribute<String?> leftAlignment = AlignAttribute('left');

  // "attributes":{"align":"center"}
  static Attribute<String?> centerAlignment = AlignAttribute('center');

  // "attributes":{"align":"right"}
  static Attribute<String?> rightAlignment = AlignAttribute('right');

  // "attributes":{"align":"justify"}
  static Attribute<String?> justifyAlignment = AlignAttribute('justify');

  // "attributes":{"list":"bullet"}
  static Attribute<String?> ul = ListAttribute('bullet');

  // "attributes":{"list":"ordered"}
  static Attribute<String?> ol = ListAttribute('ordered');

  // "attributes":{"list":"checked"}
  static Attribute<String?> checked = ListAttribute('checked');

  // "attributes":{"list":"unchecked"}
  static Attribute<String?> unchecked = ListAttribute('unchecked');

  // "attributes":{"direction":"rtl"}
  static Attribute<String?> rtl = DirectionAttribute('rtl');

  // "attributes":{"indent":1"}
  static Attribute<int?> indentL1 = IndentAttribute(level: 1);

  // "attributes":{"indent":2"}
  static Attribute<int?> indentL2 = IndentAttribute(level: 2);

  // "attributes":{"indent":3"}
  static Attribute<int?> indentL3 = IndentAttribute(level: 3);

  static Attribute<int?> getIndentLevel(int? level) {
    if (level == 1) {
      return indentL1;
    }
    if (level == 2) {
      return indentL2;
    }
    if (level == 3) {
      return indentL3;
    }
    return IndentAttribute(level: level);
  }

  ///########################################################
  static Attribute<String> id = IdAttribute('');

  static Attribute<String> parentId = ParentIdAttribute('');

  static ChildrenIdsAttribute childrenIds = ChildrenIdsAttribute(<String>[]);

  ///#######################################################

  static Attribute<int> mindThemeId = MindThemeIdAttribute(0);

  static Attribute<int> mindThemeBorderStyle = MindThemeBorderStyleAttribute(0);

  static Attribute<int> mindThemeBorderWidget =
      MindThemeBorderWidgetAttribute(0);

  static Attribute<int> mindThemeBorderColor = MindThemeBorderColorAttribute(0);

  static Attribute<int> mindThemeLineShape = MindThemeLineShapeAttribute(0);

  static Attribute<int> mindThemeLineStyle = MindThemeLineStyleAttribute(0);

  static Attribute<int> mindThemeLineWidth = MindThemeLineWidthAttribute(0);

  static Attribute<int> mindThemeLineEndPoint =
      MindThemeLineEndPointAttribute(0);

  static Attribute<int> mindThemeLineColor = MindThemeLineColorAttribute(0);

  ///#######################################################
  static Attribute<int> docThemeId = DocumentThemeIdAttribute(0);
}
