import '../block.dart';
import '../context.dart';
import '../errors.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class If extends Block {
  final List<MapEntry<Expression, List<Tag>>> conditions;

  If(this.conditions) : super([]);

  @override
  Stream<String> render(RenderContext context) async* {
    for (final condition in conditions) {
      final test = await condition.key.evaluate(context);
      if (test) {
        yield* renderTags(context, condition.value);
        return;
      }
    }
  }

  static final BlockParserFactory factory = () => _IfBlockParser();
  static final BlockParserFactory unlessFactory = () => _UnlessBlockParser();
}

class _IfBlockParser extends BlockParser {
  final List<MapEntry<Expression, List<Tag>>> conditions = [];
  Expression? lastExpression;

  @override
  void start(context, args) {
    super.start(context, args);
    conditions.clear();
    lastExpression = TagParser.from(args).parseBooleanExpression();
  }

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    conditions.add(MapEntry(lastExpression ?? ConstantExpression(true), List.from(children)));
    return createFromConditions(conditions);
  }

  If createFromConditions(List<MapEntry<Expression, List<Tag>>> conditions) {
    return If(conditions);
  }

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    if (start.value == 'elseif') {
      if (lastExpression == null) {
        throw ParseException.unexpected(start, expected: '{% elseif %} must preced {% else %}');
      }
      conditions.add(MapEntry(lastExpression!, List.from(childrenSoFar)));
      childrenSoFar.clear();
      lastExpression = TagParser.from(args).parseBooleanExpression();
    } else if (start.value == 'else') {
      if (lastExpression == null) {
        throw ParseException.unexpected(start, expected: '{% endif %}');
      }
      conditions.add(MapEntry(lastExpression!, List.from(childrenSoFar)));
      childrenSoFar.clear();
      lastExpression = null;
    } else {
      throw ParseException.unexpected(start, expected: '{% elseif %} or {% else %} or {% endif %}');
    }
  }
}

class _UnlessBlockParser extends _IfBlockParser {
  @override
  If createFromConditions(List<MapEntry<Expression, List<Tag>>> conditions) {
    conditions[0] = MapEntry(
      NotExpression(conditions[0].key),
      conditions[0].value,
    );
    return super.createFromConditions(conditions);
  }
}
