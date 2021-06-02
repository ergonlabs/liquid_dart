import '../block.dart';
import '../context.dart';
import '../document.dart';
import '../errors.dart';
import '../expressions.dart';
import '../model.dart';
import '../tag.dart';
import 'lexer.dart';
import 'tag_parser.dart';

class Parser {
  final Source source;
  final Iterator<Token> tokens;
  final ParseContext context;

  Parser(this.context, this.source)
      : tokens = Lexer().tokenize(source).iterator;

  Document parse() {
    return parseBlock(DocumentParser(), [], '<doc>', null) as Document;
  }

  Block parseBlock(
      BlockParser builder, List<Token> args, String start, Token? asTarget) {
    var innerChildren = <Tag>[];
    builder.start(context, args);
    if (builder.hasEndTag) {
      parseBlockChildren(
        start,
        innerChildren,
        builder,
      );
    }
    var block = builder.create(args, innerChildren);
    if (asTarget != null) {
      block = AsBlock(asTarget.value, [block]);
    }
    return block;
  }

  void parseBlockChildren(
    String start,
    List<Tag> children,
    BlockParser parent,
  ) {
    final end = 'end$start';
    while (tokens.moveNext()) {
      switch (tokens.current.type) {
        case TokenType.tag_start:
          tokens.moveNext();

          expect(types: [TokenType.identifier]);
          final start = tokens.current;
          final args = <Token>[];
          while (
              tokens.moveNext() && tokens.current.type != TokenType.tag_end) {
            args.add(tokens.current);
          }

          if (start.value == end) {
            return;
          }

          Token? asTarget;
          if (args.length >= 2 &&
              args[args.length - 1].type == TokenType.identifier &&
              args[args.length - 2].value == 'as') {
            asTarget = args.last;
            args.length = args.length - 2;
          }

          if (context.tags.containsKey(start.value)) {
            var builder = context.tags[start.value]!();
            if (!parent.approveTag(start, children, asTarget)) {
              throw ParseException.unexpected(start);
            }
            children.add(parseBlock(builder, args, start.value, asTarget));
          } else {
            parent.unexpectedTag(this, start, args, children);
          }

          break;
        case TokenType.var_start:
          children.add(parseVar());
          break;
        case TokenType.markup:
          children.add(TagStatic(tokens.current.value));
          break;
        default:
          throw ParseException.unexpected(tokens.current);
      }
    }
  }

  ExpressionTag parseVar() {
    tokens.moveNext();

    var exp = TagParser.fromIterator(tokens).parseFilterExpression();

    expect(value: '}}');
    return ExpressionTag(exp);
  }

  void expect({List<TokenType>? types, String? value, Token? token}) {
    token ??= tokens.current;
    if (types != null && !types.contains(token.type)) {
      throw ParseException.unexpected(token, expected: 'one of $types');
    }
    if (value != null && token.value != value) {
      throw ParseException.unexpected(token, expected: "'$value'");
    }
  }
}
