import '../tag.dart';

class TagRenderException implements Exception {
  final error;
  final stacktrace;
  final Tag tag;

  TagRenderException(this.error, this.stacktrace, this.tag) : super();

  @override
  String toString() {
    //return super.toString();
    String result = "TagRenderException at tag $tag:\n  $error\nStacktrace was at:\n$stacktrace";
    return result;
  }
}
