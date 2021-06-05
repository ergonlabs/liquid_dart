import 'dart:async';

import './tag.dart';
import 'context.dart';
import 'errors.dart';
import 'exception/tagrender_exception.dart';
import 'model.dart';
import 'parser/parser.dart';

class Block implements Tag {
  final List<Tag> children;

  Block(this.children);

  @override
  Stream<String> render(RenderContext context) => renderTags(context, children);

  Stream<String> renderTags(RenderContext context, Iterable<Tag> children) async* {
    for (final child in children) {
      try {
        yield* child.render(context);
      } catch (error, stacktrace) {
        throw TagrenderException(error, stacktrace, child);
      }
    }
  }
}

class AsBlock extends Block {
  final String to;

  AsBlock(this.to, List<Tag> children) : super(children);

  @override
  Stream<String> render(RenderContext context) {
    context.variables[to] = super.render(context).join();
    return Stream.empty();
  }
}

abstract class BlockParser {
  late ParseContext context;

  Block create(List<Token> tokens, List<Tag> children);

  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar);

  bool approveTag(Token start, List<Tag> childrenSoFar, Token? asToken) => start.value != 'extend' && start.value != 'load';

  BlockParser();

  static BlockParserFactory simple(SimpleBlockFactory factory, {hasEndTag = true}) {
    return () => _SimpleBlockParser(factory, hasEndTag);
  }

  void start(ParseContext context, List<Token> args) {
    this.context = context;
  }

  bool get hasEndTag => true;
}

typedef BlockParserFactory = BlockParser Function();

typedef SimpleBlockFactory = Block Function(List<Token> tokens, List<Tag> children);

class _SimpleBlockParser extends BlockParser {
  final SimpleBlockFactory factory;
  @override
  final bool hasEndTag;

  _SimpleBlockParser(this.factory, this.hasEndTag);

  @override
  Block create(List<Token> tokens, List<Tag> children) => factory(tokens, children);

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    throw ParseException.unexpected(start);
  }
}
