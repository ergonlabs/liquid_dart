import 'context.dart';

abstract class Tag {
  Iterable<String> render(RenderContext context);
}

class TagStatic implements Tag {
  final String value;

  TagStatic(this.value);

  @override
  Iterable<String> render(RenderContext context) => [value];
}