import '../context.dart';
import '../document.dart';
import '../errors.dart';
import '../expressions.dart';
import '../model.dart';

class TagParser {
  final Iterator<Token> tokens;

  int index = 0;

  List<Token> _originalTokens = [];

  TagParser.from(List<Token> tokens) : this.fromIterator(tokens.followedBy([Token.eof]).iterator..moveNext(), tokens);

  TagParser.fromIterator(this.tokens, [this._originalTokens = const []]);

  Token get current => tokens.current;

  Token? peekNext() {
    if (index >= _originalTokens.length) {
      return null;
    }
    return _originalTokens.elementAt(index + 1);
  }

  bool moveNext() {
    if (current == Token.eof) {
      return true;
    }
    index += 1;
    return tokens.moveNext();
  }

  Expression parseBooleanExpression() {
    var exp = _parseAnd();
    if (current.value == 'or') {
      exp = BinaryOperation((a, b) => a || a, exp, _parseAnd());
    }
    return exp;
  }

  Expression _parseAnd() {
    var exp = _parseNot();
    if (current.value == 'and') {
      exp = BinaryOperation((a, b) => a && b, exp, _parseNot());
    }
    return exp;
  }

  Expression _parseNot() {
    if (current.type == TokenType.identifier && current.value == 'not') {
      moveNext();
      return NotExpression(_parseBinaryExpression());
    }
    return BooleanCastExpression(_parseBinaryExpression());
  }

  Expression _parseBinaryExpression() {
    var exp = parseFilterExpression();

    if (current.value == 'contains' || current.value == 'in') {
      var op = current;
      moveNext();
      var right = parseFilterExpression();
      if (op.value == 'contains') {
        final temp = exp;
        exp = right;
        right = temp;
      }
      exp = BinaryOperation((a, b) {
        if (b is Map) {
          return b.containsKey(a);
        } else if (b is List) {
          return b.contains(b);
        } else {
          return false;
        }
      }, exp, right);
    } else if (current.type == TokenType.comparison) {
      Operation? op;
      switch (current.value) {
        case '==':
          op = (a, b) => a == b;
          break;
        case '!=':
        case '<>':
          op = (a, b) => a != b;
          break;
        case '<':
          op = (a, b) => a < b;
          break;
        case '>':
          op = (a, b) => a > b;
          break;
        case '<=':
          op = (a, b) => a <= b;
          break;
        case '>=':
          op = (a, b) => a >= b;
          break;
      }
      moveNext();
      exp = BinaryOperation(op!, exp, parseFilterExpression());
    }

    return exp;
  }

  Expression parseSingleTokenExpression() {
    expect(types: [TokenType.identifier, TokenType.single_string, TokenType.double_string, TokenType.number]);
    final name = tokens.current;
    moveNext();

    if (name.type == TokenType.identifier) {
      if (name.value == 'true') {
        return ConstantExpression(true);
      }
      if (name.value == 'false') {
        return ConstantExpression(false);
      }
      return LookupExpression(name);
    }

    return ConstantExpression.fromToken(name);
  }

  Expression parseFilterExpression() {
    var exp = parseMemberExpression();

    return parseFilters(exp);
  }

  Expression parseMemberExpression() {
    var exp = parseSingleTokenExpression();

    while (tokens.current.type == TokenType.dot) {
      moveNext();

      exp = MemberExpression(exp, tokens.current);
      moveNext();
    }

    return exp;
  }

  void expect({List<TokenType>? types, String? value}) {
    if (types != null && !types.contains(tokens.current.type)) {
      throw ParseException.unexpected(tokens.current, expected: 'one of $types');
    }
    if (value != null && tokens.current.value != value) {
      throw ParseException.unexpected(tokens.current, expected: "'$value'");
    }
  }

  Expression parseFilters(Expression exp) {
    while (tokens.current.type == TokenType.pipe) {
      moveNext();

      expect(types: [TokenType.identifier]);
      final name = tokens.current;
      final arguments = <Expression>[];

      if (moveNext() && tokens.current.type == TokenType.colon) {
        moveNext();
        do {
          arguments.add(parseMemberExpression());
        } while (tokens.current.type == TokenType.comma && moveNext());
      }

      exp = FilterExpression(exp, name, arguments);
    }

    return exp;
  }

  DocumentFuture parseDocumentReference(ParseContext context) {
    final root = current.source?.root;
    if (root == null) {
      throw ParseException.missingRoot();
    }
    final path = parseSingleTokenExpression();
    return DocumentFuture(root, context, path);
  }
}
