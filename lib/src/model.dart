export 'model_web.dart' if (dart.library.io) 'model_io.dart';

import 'package:easy_logger/easy_logger.dart';

abstract class Root {
  Future<Source> resolve(String relPath);
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

class LiquidEngine {
  LiquidEngine();
  static EasyLogger logger = EasyLogger(
    name: 'liquid_engine',
    defaultLevel: LevelMessages.debug,
    enableBuildModes: [BuildMode.debug, BuildMode.profile, BuildMode.release],
    enableLevels: [
      LevelMessages.debug,
      LevelMessages.info,
      LevelMessages.error,
      LevelMessages.warning,
    ],
  );
}
