import 'context.dart';

abstract class Tag {
  Iterable<String> render(RenderContext context);

  @override
  String toString() {
    return 'Tag{}';
  }
}

class TagStatic implements Tag {
  final String value;

  TagStatic(this.value);

  @override
  Iterable<String> render(RenderContext context) => [value];

  @override
  String toString() {
    return 'TagStatic{value: $value}';
  }
}
