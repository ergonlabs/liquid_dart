import 'model.dart';

class ParseException extends Error {
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'Parse Exception: $message';

  ParseException.unexpected(Token token, {dynamic expected})
      : this('Unexpected Token: $token expected $expected');
}
