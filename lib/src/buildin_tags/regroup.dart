import '../block.dart';
import '../context.dart';
import '../errors.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class Regroup extends Block {
  Expression from;
  String groupBy;
  String to;

  Regroup(this.from, this.groupBy, this.to) : super([]);

  @override
  Stream<String> render(RenderContext context) async* {
    List list = await from.evaluate(context);
    var collection = List.from(list);
    var groupers = <String>{};
    collection.forEach((element) {
      groupers.add(element[groupBy]);
    });

    var result = [];
    groupers.forEach((grouper) {
      var item = {};
      item['grouper'] = grouper;
      item['list'] = collection.where((element) => element[groupBy] == grouper).toList();
      result.add(item);
    });
    context.variables[to] = result;
  }

  static final BlockParserFactory factory = () => _RegroupBlockParser();

  @override
  String toString() {
    return 'Regroup{from: $from, groupBy: $groupBy, to: $to}';
  }
}

class _RegroupBlockParser extends BlockParser {
  @override
  void start(context, args) {
    super.start(context, args);
  }

  // {% for athlete in athlete_list %}
  // {% regroup cities by country as country_list %}
  @override
  Block create(List<Token> tokens, List<Tag> children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    Expression from = parser.parseFilterExpression();
    // parseFilterExpression automatically moves to the next token

    //parser.moveNext();
    parser.expect(types: [TokenType.identifier], value: 'by');

    parser.moveNext();
    parser.expect(types: [TokenType.identifier]);
    String groupby = parser.current.value;

    parser.moveNext();
    parser.expect(types: [TokenType.identifier], value: 'to');

    parser.moveNext();
    parser.expect(types: [TokenType.identifier]);
    String to = parser.current.value;

    return Regroup(from, groupby, to);
  }

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    throw ParseException.unexpected(start, expected: '{% regroup list by groupBy to newList %}');
  }

  @override
  bool get hasEndTag => false;
}

extension JaggedIterable<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() sync* {
    for (final inner in this) {
      yield* inner;
    }
  }
}
