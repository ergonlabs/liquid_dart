import '../block.dart';
import '../context.dart';
import '../model.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

abstract class CaptureBase extends Block {
  String to;

  CaptureBase(this.to, List<Tag> children) : super(children);

  RenderContext scope(RenderContext context);

  @override
  Iterable<String> render(RenderContext context) {
    final markup = super.render(context).join();

    scope(context).variables[to] = markup;

    return Iterable.empty();
  }
}

class Cache extends CaptureBase {
  Cache(String to, List<Tag> children) : super(to, children);

  @override
  RenderContext scope(RenderContext context) => context.root;

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    final to = parser.current!.value;
    return Cache(to, children);
  };
}

class Capture extends CaptureBase {
  Capture(String to, List<Tag> children) : super(to, children);

  @override
  RenderContext scope(RenderContext context) => context;

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    final to = parser.current!.value;
    return Capture(to, children);
  };
}
