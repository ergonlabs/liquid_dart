import '../block.dart';
import '../context.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/tag_parser.dart';

class FirstOf extends Block {
  List<Expression> values;

  FirstOf(this.values) : super([]);

  @override
  Stream<String> render(RenderContext context) async* {
    for (final value in values) {
      final test = await BooleanCastExpression(value).evaluate(context);
      if (test) {
        yield (await value.evaluate(context)).toString();
        return;
      }
    }
  }

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    var values = <Expression>[];
    do {
      values.add(parser.parseFilterExpression());
    } while (parser.current.type != TokenType.eof);
    return FirstOf(values);
  };
}
