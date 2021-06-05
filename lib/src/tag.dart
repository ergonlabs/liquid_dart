import 'dart:async';

import 'context.dart';

abstract class Tag {
  Stream<String> render(RenderContext context);
  @override
  String toString() {
    return 'Tag{}';
  }
}

class TagStatic implements Tag {
  final String value;

  TagStatic(this.value);

  @override
  Stream<String> render(RenderContext context) => Stream.fromIterable([value]);
  @override
  String toString() {
    return 'TagStatic{value: $value}';
  }
}
