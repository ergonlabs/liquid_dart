import '../block.dart';
import '../context.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/tag_parser.dart';

class Cycle extends Block {
  List<ExpressionTag> values;

  Cycle(this.values) : super([]);

  @override
  Iterable<String> render(RenderContext context) {
    var state = context.getTagState(this);
    var index = ((state['index'] ?? -1) + 1) % values.length;
    state['index'] = index;
    return values[index].render(context);
  }

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    var values = <ExpressionTag>[];
    do {
      values.add(ExpressionTag(parser.parseFilterExpression()));
    } while (parser.current.type == TokenType.comma && parser.moveNext());

    return Cycle(values);
  };
}
