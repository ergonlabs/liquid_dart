import 'dart:io';

class Root {
  final Uri path;

  Root(this.path);

  Future<Source> resolve(String relPath) async {
    final file = path.resolve(relPath);
    final content = await File.fromUri(file).readAsString();
    return Source(file, content, this);
  }
}

class Source {
  final Uri? file;
  final String content;
  final Root? root;

  Source(this.file, this.content, this.root);

  Source.fromString(String content) : this(null, content, null);
}

enum TokenType {
  pipe,
  dot,
  assign,
  colon,
  comma,
  open_square,
  close_square,
  open_banana,
  close_banana,
  question,
  dash,
  identifier,
  single_string,
  double_string,
  number,
  dotdot,
  comparison,
  tag_start,
  tag_end,
  var_start,
  var_end,
  markup,
  eof,
}

class Token {
  final TokenType? type;
  final String value;
  final Source? source;
  final int? line;
  final int? column;

  static Token eof = Token(TokenType.eof, '<EOF>');

  Token(this.type, this.value, {this.source, this.line, this.column});

  @override
  String toString() => '<$type line=$line column=$column value=\'$value\'>';
}
