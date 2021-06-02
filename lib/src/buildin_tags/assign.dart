import '../block.dart';
import '../context.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class Assign extends Block {
  String to;
  Expression from;

  Assign(this.to, this.from, List<Tag> children) : super(children);

  @override
  Iterable<String> render(RenderContext context) {
    var innerContext = context.push({to: from.evaluate(context)});
    return super.render(innerContext);
  }

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    final to = parser.current.value;

    parser.moveNext();
    parser.expect(types: [TokenType.assign]);

    parser.moveNext();
    return Assign(to, parser.parseFilterExpression(), children);
  };
}
