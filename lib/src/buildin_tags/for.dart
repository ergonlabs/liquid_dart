import '../block.dart';
import '../context.dart';
import '../errors.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class For extends Block {
  String to;
  Expression from;

  List<Tag> innerChildren;
  List<Tag> elseChildren;

  For(this.to, this.from, this.innerChildren, this.elseChildren) : super([]);

  @override
  Iterable<String> render(RenderContext context) {
    var collection = List.from(from.evaluate(context) ?? []);

    if (collection.isEmpty) {
      return super.renderTags(context, elseChildren);
    }

    var parentLoop = context.variables['forloop'];

    var index = 0;
    return collection.map<Iterable<String>>((item) {
      final innerContext = context.push({
        to: item,
        'forloop': {
          'name': '$to-$from',
          'length': collection.length,
          'counter': (index + 1),
          'counter0': index,
          'revcounter': (collection.length - index),
          'revcounter0': (collection.length - index - 1),
          'index': (index + 1),
          'index0': index,
          'rindex': (collection.length - index),
          'rindex0': (collection.length - index - 1),
          'first': (index == 0),
          'last': (index == (collection.length - 1)),
          'parentloop': parentLoop,
        }
      });
      index++;
      return super.renderTags(innerContext, innerChildren);
    }).flatten();
  }

  static final BlockParserFactory factory = () => _ForBlockParser();
}

class _ForBlockParser extends BlockParser {
  List<Tag>? innerChildren;

  @override
  void start(context, args) {
    super.start(context, args);
    innerChildren = null;
  }

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    final to = parser.current.value;

    parser.moveNext();
    parser.expect(types: [TokenType.identifier], value: 'in');

    parser.moveNext();
    return For(to, parser.parseFilterExpression(), innerChildren ?? children,
        innerChildren != null ? children : []);
  }

  @override
  void unexpectedTag(
      Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    if (start.value == 'else' || start.value == 'empty') {
      if (innerChildren != null) {
        throw ParseException('Only one {% else %} is allowed in a {% for %}');
      }
      innerChildren = List.from(childrenSoFar);
      childrenSoFar.clear();
    } else {
      throw ParseException.unexpected(start,
          expected: '{% else %} or {% endfor %}');
    }
  }
}

extension JaggedIterable<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() sync* {
    for (final inner in this) {
      yield* inner;
    }
  }
}
