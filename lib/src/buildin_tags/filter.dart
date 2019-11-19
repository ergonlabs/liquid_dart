import '../block.dart';
import '../context.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/tag_parser.dart';

class FilterBlock extends Block {
  Expression input;

  FilterBlock(this.input) : super([]);

  @override
  Iterable<String> render(RenderContext context) {
    return [input.evaluate(context)];
  }

  static final SimpleBlockFactory factory = (tokens, children) {
    tokens.insert(0, Token(TokenType.pipe, '|'));
    var parser = TagParser.from(tokens);
    return FilterBlock(parser.parseFilters(BlockExpression.fromTags(children)));
  };
}
