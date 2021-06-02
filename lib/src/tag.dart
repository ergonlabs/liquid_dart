import 'dart:async';

import 'context.dart';

abstract class Tag {
  Stream<String> render(RenderContext context);
}

class TagStatic implements Tag {
  final String value;

  TagStatic(this.value);

  @override
  Stream<String> render(RenderContext context) => Stream.fromIterable([value]);
}
