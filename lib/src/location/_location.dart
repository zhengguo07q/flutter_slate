import 'package:slate/slate.dart';

mixin Location {
  static bool isSpan(dynamic value) {
    return value is Span;
  }
}

class Span with Location {
  Span(this.path1, this.path2);

  final Path path1;
  final Path path2;
}
