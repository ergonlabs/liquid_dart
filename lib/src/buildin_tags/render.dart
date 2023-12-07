import '../block.dart';
import '../context.dart';
import '../document.dart';
import '../expressions.dart';
import '../model.dart';
import '../parser/parser.dart';
import '../parser/tag_parser.dart';
import '../tag.dart';

class Render extends Block {
  final List<_Assign> assignments;
  final DocumentFuture childBuilder;

  Render._(this.assignments, this.childBuilder) : super([]);

  @override
  Stream<String> render(RenderContext context) async* {
    var innerContext = context;
    innerContext = innerContext.clone();
    innerContext.variables.clear();

    innerContext = innerContext.push({for (var a in assignments) a.to: await a.from.evaluate(context)});

    yield* (await childBuilder.resolve(innerContext)).render(innerContext);
  }

  static BlockParserFactory factory = () => _RenderBlockParser();
}

class _Assign {
  final String to;
  final Expression from;

  _Assign(this.to, this.from);
}

class _RenderBlockParser extends BlockParser {
  @override
  bool get hasEndTag => false;

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    final parser = TagParser.from(tokens);
    final childBuilder = parser.parseDocumentReference(context);

    var assignments = <_Assign>[];

    if (parser.current.value == ",") {
      parser.moveNext();

      while (parser.current.type == TokenType.identifier) {
        final to = parser.current;

        if (parser.peekNext() != null && parser.peekNext()!.value == ",") {
          assignments.add(_Assign(to.value, parser.parseSingleTokenExpression()));
          parser.moveNext();
          continue;
        }

        if (parser.current.value == ",") {
          parser.moveNext();
        }

        if (parser.peekNext() != null) {
          if (parser.peekNext()!.value == ":") {
            parser.moveNext();
            parser.moveNext();
            parser.expect(types: [TokenType.identifier, TokenType.single_string, TokenType.double_string, TokenType.number]);
            assignments.add(_Assign(to.value, parser.parseSingleTokenExpression()));
          }
        }
        parser.moveNext();
      }
    }

    if (parser.current.value == 'with') {
      while (parser.current.type == TokenType.identifier) {

        parser.expect(types: [TokenType.identifier]);

        if (parser.peekNext() != null) {
          parser.moveNext();
          final to = parser.parseSingleTokenExpression();
          if (parser.current.value == 'as') {
            parser.moveNext();
            parser.expect(types: [TokenType.identifier]);
            assignments.add(_Assign(parser.current.value, to ));
          }
        }
        parser.moveNext();
      }
    }

    return Render._(assignments, childBuilder);
  }

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {}
}
