import './tag.dart';
import 'context.dart';
import 'errors.dart';
import 'model.dart';
import 'parser/parser.dart';

class Block implements Tag {
  final List<Tag> children;

  Block(this.children);

  @override
  Iterable<String> render(RenderContext context) =>
      renderTags(context, children);

  Iterable<String> renderTags(
      RenderContext context, Iterable<Tag> children) sync* {
    for (final child in children) {
      yield* child.render(context);
    }
  }
}

class AsBlock extends Block {
  final String to;

  AsBlock(this.to, List<Tag> children) : super(children);

  @override
  Iterable<String> render(RenderContext context) {
    context.variables[to] = super.render(context).join();
    return Iterable.empty();
  }
}

abstract class BlockParser {
  ParseContext context;

  Block create(List<Token> tokens, List<Tag> children);

  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar);

  bool approveTag(Token start, List<Tag> childrenSoFar, Token asToken) =>
      start.value != 'extend' && start.value != 'load';

  BlockParser();

  static BlockParserFactory simple(SimpleBlockFactory factory,
      {hasEndTag = true}) {
    return () => _SimpleBlockParser(factory, hasEndTag);
  }

  void start(ParseContext context, List<Token> args) {
    this.context = context;
  }

  bool get hasEndTag => true;
}

typedef BlockParser BlockParserFactory();

typedef Block SimpleBlockFactory(List<Token> tokens, List<Tag> children);

class _SimpleBlockParser extends BlockParser {
  final SimpleBlockFactory factory;
  final bool hasEndTag;

  _SimpleBlockParser(this.factory, this.hasEndTag);

  @override
  Block create(List<Token> tokens, List<Tag> children) =>
      factory(tokens, children);

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    throw ParseException.unexpected(start);
  }
}
