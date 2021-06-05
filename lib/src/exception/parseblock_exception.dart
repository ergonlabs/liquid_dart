import '../model.dart';

class ParseblockException implements Exception {
  final String cause;

  final String start;

  final List<Token> args;

  ParseblockException(this.cause, this.start, this.args);

  @override
  String toString() {
    //return super.toString();
    return "ParseblockException at '$start' with args '${args.map((e) => "${e.value} (Line ${e.line}, Column ${e.column})").join(",")}'\nCaused by $cause";
  }
}
