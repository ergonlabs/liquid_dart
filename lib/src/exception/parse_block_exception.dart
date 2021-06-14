import '../model.dart';

class ParseBlockException implements Exception {
  final String cause;

  final String start;

  final List<Token> args;

  ParseBlockException(this.cause, this.start, this.args);

  @override
  String toString() {
    //return super.toString();
    return "ParseBlockException at '$start' with args '${args.map((e) => "${e.value} (Line ${e.line}, Column ${e.column})").join(",")}'\nCaused by $cause";
  }
}
