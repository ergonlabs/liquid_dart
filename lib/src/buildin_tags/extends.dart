import 'dart:collection';

import 'package:liquid/src/buildin_tags/assign.dart';
import 'package:liquid/src/document.dart';
import 'package:liquid/src/errors.dart';
import 'package:liquid/src/parser/parser.dart';
import 'package:liquid/src/parser/tag_parser.dart';
import 'package:liquid/src/expressions.dart';

import '../context.dart';
import '../block.dart';
import '../model.dart';
import '../tag.dart';

class Extends extends Block {
  final DocumentFuture base;

  Extends._(this.base)
      : super([]);

  @override
  Iterable<String> render(RenderContext context) {
    return Iterable.empty();
  }

  static BlockParserFactory factory = () => _BlockParser();
}

class _BlockParser extends BlockParser {
  @override
  bool get hasEndTag => false;

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    final parser = TagParser.from(tokens);
    return Extends._(parser.parseDocumentReference(context));
  }

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {}
}
