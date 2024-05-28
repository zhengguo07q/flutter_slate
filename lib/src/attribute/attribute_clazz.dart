import '../../slate.dart';
import 'attribute.dart';

class BoldAttribute extends Attribute<bool> {
  BoldAttribute() : super('bold', AttributeScope.inline, true);
}

class ItalicAttribute extends Attribute<bool> {
  ItalicAttribute() : super('italic', AttributeScope.inline, true);
}

class SmallAttribute extends Attribute<bool> {
  SmallAttribute() : super('small', AttributeScope.inline, true);
}

class UnderlineAttribute extends Attribute<bool> {
  UnderlineAttribute() : super('underline', AttributeScope.inline, true);
}

class StrikeThroughAttribute extends Attribute<bool> {
  StrikeThroughAttribute() : super('strike', AttributeScope.inline, true);
}

class InlineCodeAttribute extends Attribute<bool> {
  InlineCodeAttribute() : super('code', AttributeScope.inline, true);
}

class FontAttribute extends Attribute<String?> {
  FontAttribute(String? val) : super('font', AttributeScope.inline, val);
}

class SizeAttribute extends Attribute<String?> {
  SizeAttribute(String? val) : super('size', AttributeScope.inline, val);
}

class LinkAttribute extends Attribute<String?> {
  LinkAttribute(String? val) : super('link', AttributeScope.inline, val);
}

class ColorAttribute extends Attribute<String?> {
  ColorAttribute(String? val) : super('color', AttributeScope.inline, val);
}

class BackgroundAttribute extends Attribute<String?> {
  BackgroundAttribute(String? val)
      : super('background', AttributeScope.inline, val);
}

/// This is custom attribute for hint
class PlaceholderAttribute extends Attribute<bool> {
  PlaceholderAttribute() : super('placeholder', AttributeScope.inline, true);
}

class HeaderAttribute extends Attribute<int?> {
  HeaderAttribute({int? level}) : super('header', AttributeScope.block, level);
}

class IndentAttribute extends Attribute<int?> {
  IndentAttribute({int? level}) : super('indent', AttributeScope.block, level);
}

class AlignAttribute extends Attribute<String?> {
  AlignAttribute(String? val) : super('align', AttributeScope.block, val);
}

class ListAttribute extends Attribute<String?> {
  ListAttribute(String? val) : super('list', AttributeScope.block, val);
}

class CodeBlockAttribute extends Attribute<bool> {
  CodeBlockAttribute() : super('code-block', AttributeScope.block, true);
}

class BlockQuoteAttribute extends Attribute<bool> {
  BlockQuoteAttribute() : super('blockquote', AttributeScope.block, true);
}

class DirectionAttribute extends Attribute<String?> {
  DirectionAttribute(String? val)
      : super('direction', AttributeScope.block, val);
}

class WidthAttribute extends Attribute<String?> {
  WidthAttribute(String? val) : super('width', AttributeScope.ignore, val);
}

class HeightAttribute extends Attribute<String?> {
  HeightAttribute(String? val) : super('height', AttributeScope.ignore, val);
}

class StyleAttribute extends Attribute<String?> {
  StyleAttribute(String? val) : super('style', AttributeScope.ignore, val);
}

class TokenAttribute extends Attribute<String> {
  TokenAttribute(String val) : super('token', AttributeScope.ignore, val);
}

class ScriptAttribute extends Attribute<String> {
  ScriptAttribute(String val) : super('script', AttributeScope.ignore, val);
}

///###################################节点关系###################################################
///节点ID
class IdAttribute extends Attribute<String>{
  IdAttribute(String value) : super('id', AttributeScope.ignore, value);
}

/// 父ID
class ParentIdAttribute extends Attribute<String>{
  ParentIdAttribute(String value) : super('pid', AttributeScope.ignore, value);
}

/// 孩子ID列表
class ChildrenIdsAttribute extends Attribute<List<String>>{
  ChildrenIdsAttribute(List<String> value) : super('cIds', AttributeScope.ignore, value);
}

///###################################思维导图主题###################################################
///主题ID
class MindThemeIdAttribute extends Attribute<int>{
  MindThemeIdAttribute(int value): super('mtId', AttributeScope.mindmap, value);
}

/// 边框样式
class MindThemeBorderStyleAttribute extends Attribute<int>{
  MindThemeBorderStyleAttribute(int value): super('mtbs', AttributeScope.mindmap, value);
}

/// 边框宽度
class MindThemeBorderWidgetAttribute extends Attribute<int>{
  MindThemeBorderWidgetAttribute(int value): super('mtbw', AttributeScope.mindmap, value);
}

/// 边框颜色
class MindThemeBorderColorAttribute extends Attribute<int>{
  MindThemeBorderColorAttribute(int value): super('mtbc', AttributeScope.mindmap, value);
}

/// 线条形状
class MindThemeLineShapeAttribute extends Attribute<int>{
  MindThemeLineShapeAttribute(int value): super('mtlss', AttributeScope.mindmap, value);
}

/// 线条样式
class MindThemeLineStyleAttribute extends Attribute<int>{
  MindThemeLineStyleAttribute(int value): super('mtlst', AttributeScope.mindmap, value);
}

/// 线条终点
class MindThemeLineEndPointAttribute extends Attribute<int>{
  MindThemeLineEndPointAttribute(int value): super('mtlep', AttributeScope.mindmap, value);
}

/// 线条宽度
class MindThemeLineWidthAttribute extends Attribute<int>{
  MindThemeLineWidthAttribute(int value): super('mtlep', AttributeScope.mindmap, value);
}

/// 线条颜色
class MindThemeLineColorAttribute extends Attribute<int>{
  MindThemeLineColorAttribute(int value): super('mtlc', AttributeScope.mindmap, value);
}

///###################################文档主题#######################################################
class DocumentThemeIdAttribute extends Attribute<int>{
  DocumentThemeIdAttribute(int value): super('dThemeId', AttributeScope.document, value);
}