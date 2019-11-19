import '../block.dart';
import '../context.dart';
import '../document.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class Include extends Block {
  final List<_Assign> assignments;
  final bool clearVariables;
  final DocumentFuture childBuilder;

  Include._(this.assignments, this.clearVariables, this.childBuilder)
      : super([]);

  @override
  Iterable<String> render(RenderContext context) {
    var innerContext = context;
    if (clearVariables) {
      innerContext = innerContext.clone();
      innerContext.variables.clear();
    }
    innerContext = innerContext.push(Map.fromIterable(
      assignments,
      key: (a) => a.to,
      value: (a) => a.from.evaluate(context),
    ));

    return childBuilder.resolve(context).render(innerContext);
  }

  static BlockParserFactory factory = () => _IncludeBlockParser();
}

class _Assign {
  final String to;
  final Expression from;

  _Assign(this.to, this.from);
}

class _IncludeBlockParser extends BlockParser {
  @override
  bool get hasEndTag => false;

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    final parser = TagParser.from(tokens);
    final childBuilder = parser.parseDocumentReference(context);

    final assignments = <_Assign>[];
    if (parser.current != null && parser.current.value == 'with') {
      parser.moveNext();
      while (parser.current.type == TokenType.identifier &&
          parser.current.value != 'only') {
        parser.expect(types: [TokenType.identifier]);
        final to = parser.current;

        parser.moveNext();
        parser.expect(types: [TokenType.assign]);
        parser.moveNext();

        final from = parser.parseFilterExpression();
        assignments.add(_Assign(to.value, from));
      }
    }

    final clearVariable =
        parser.current != null && parser.current.value == 'only';

    return Include._(assignments, clearVariable, childBuilder);
  }

  @override
  void unexpectedTag(
      Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {}
}
