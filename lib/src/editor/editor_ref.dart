import 'package:slate/slate.dart';
import 'package:slate/src/location/path_ref.dart';
import 'package:slate/src/location/point_ref.dart';
import 'package:slate/src/location/range_ref.dart';

class EditorRef {
  static PathRef makePathRef(Document document, Path path,
      {Affinity affinity = Affinity.forward}) {
    final ref = PathRef(path, affinity, (ref) {
      final current = ref.current;
      EditorRef.pathRefs(document).remove(ref);
      //ref.current = null;
      return current;
    });

    EditorRef.pathRefs(document).add(ref);
    return ref;
  }

  static Set<PathRef> pathRefs(Document document) {
    var refs = SlateCache.pathRefs.get(document);

    if (refs == null) {
      refs = Set<PathRef>();
      SlateCache.pathRefs[document] = refs;
    }
    return refs;
  }

  static PointRef makePointRef(Document document, Point point,
      {Affinity affinity = Affinity.forward}) {
    final ref = PointRef(point, affinity, (ref) {
      final current = ref.current;
      EditorRef.pointRefs(document).remove(ref);
      //ref.current = null;
      return current;
    });

    EditorRef.pointRefs(document).add(ref);
    return ref;
  }

  static Set<PointRef> pointRefs(Document document) {
    var refs = SlateCache.pointRefs.get(document);

    if (refs == null) {
      refs = Set<PointRef>();
      SlateCache.pointRefs[document] = refs;
    }

    return refs;
  }

  static RangeRef makeRangeRef(Document document, Range range,
      {Affinity affinity = Affinity.forward}) {
    final ref = RangeRef(range, affinity, (ref) {
      final current = ref.current;
      EditorRef.rangeRefs(document).remove(ref);
      //ref.current = null;
      return current;
    });

    EditorRef.rangeRefs(document).add(ref);
    return ref;
  }

  static Set<RangeRef> rangeRefs(Document document) {
    var refs = SlateCache.rangeRefs.get(document);

    if (refs == null) {
      refs = Set<RangeRef>();
      SlateCache.rangeRefs[document] = refs;
    }

    return refs;
  }
}
