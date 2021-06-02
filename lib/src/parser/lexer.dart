import 'package:string_scanner/string_scanner.dart';

import '../model.dart';

class _TokenCreator {
  final TokenType type;
  final RegExp pattern;

  _TokenCreator(this.type, String pattern) : pattern = RegExp(pattern, dotAll: true);

  Token? scan(Source source, LineScanner ss) {
    final line = ss.line;
    final column = ss.column;
    if (ss.scan(pattern)) {
      return Token(type, ss.lastMatch!.group(0)!, source: source, line: line, column: column);
    }
    return null;
  }
}

class Lexer {
  final List<_TokenCreator> tokenCreators = [
    _TokenCreator(TokenType.comparison, r'==|!=|<>|<=?|>=?'),
    _TokenCreator(TokenType.single_string, r"'[^\']*'"),
    _TokenCreator(TokenType.double_string, r'"[^\"]*"'),
    _TokenCreator(TokenType.number, r'-?\d+(\.\d+)?'),
    _TokenCreator(TokenType.identifier, r'[a-zA-Z_][\w-]*\??'),
    _TokenCreator(TokenType.dotdot, r'\.\.'),
    _TokenCreator(TokenType.pipe, r'\|'),
    _TokenCreator(TokenType.dot, r'\.'),
    _TokenCreator(TokenType.assign, '='),
    _TokenCreator(TokenType.colon, ':'),
    _TokenCreator(TokenType.comma, ','),
    _TokenCreator(TokenType.open_square, r'\['),
    _TokenCreator(TokenType.close_square, ']'),
    _TokenCreator(TokenType.open_banana, r'\('),
    _TokenCreator(TokenType.close_banana, r'\)'),
    _TokenCreator(TokenType.question, r'\?'),
    _TokenCreator(TokenType.dash, '-'),
  ];
  final markup = _TokenCreator(TokenType.markup, r'((?!{{)(?!{%)(?![\s\n\r]*{[{%]-).)+');
  final whitespace = RegExp(r'\s*');

  Iterable<Token> tokenize(Source source) sync* {
    var ss = LineScanner(source.content, sourceUrl: source.file);
    while (!ss.isDone) {
      var token = markup.scan(source, ss);
      if (token != null) {
        yield token;
      }

      if (ss.matches(tagStart)) {
        yield* tokenizeTag(source, ss);
      } else if (ss.matches(varStart)) {
        yield* tokenizeVar(source, ss);
      }
    }
  }

  RegExp tagStart = RegExp(r'({%-?)|([\s\n\r]*{%-)');
  RegExp tagEnd = RegExp(r'(%})|(-%}[\s\n\r]*)');
  Iterable<Token> tokenizeTag(Source source, LineScanner ss) => tokenizeNonMarkup(
        source,
        ss,
        TokenType.tag_start,
        tagStart,
        TokenType.tag_end,
        tagEnd,
      );

  RegExp varStart = RegExp(r'({{-?)|([\s\n\r]*{{-)');
  RegExp varEnd = RegExp(r'(}})|(-}}[\s\n\r]*)');
  Iterable<Token> tokenizeVar(Source source, LineScanner ss) => tokenizeNonMarkup(
        source,
        ss,
        TokenType.var_start,
        varStart,
        TokenType.var_end,
        varEnd,
      );

  Iterable<Token> tokenizeNonMarkup(Source source, LineScanner ss, TokenType startType, Pattern start, TokenType endType, Pattern end) sync* {
    ss.expect(start);
    yield Token(startType, ss.lastMatch!.group(0)!, source: source, line: ss.line, column: ss.column - 2);

    mainLoop:
    while (ss.scan(whitespace) && !ss.matches(end)) {
      ss.scan(whitespace);

      for (final creator in tokenCreators) {
        final token = creator.scan(source, ss);
        if (token != null) {
          yield token;
          continue mainLoop;
        }
      }

      // if we get here then we didn't match a token
      ss.expect(end);
    }

    ss.expect(end);
    yield Token(endType, ss.lastMatch!.group(0)!, source: source, line: ss.line, column: ss.column - 2);
  }
}
