import '../block.dart';
import '../context.dart';
import '../document.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class Extends extends Block {
  final DocumentFuture base;

  Extends._(this.base) : super([]);

  @override
  Stream<String> render(RenderContext context) {
    return Stream.empty();
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
