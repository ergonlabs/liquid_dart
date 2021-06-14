import '../tag.dart';

class TagRenderException implements Exception {
  final error;
  final stacktrace;
  final Tag tag;

  TagRenderException(this.error, this.stacktrace, this.tag);

  @override
  String toString() {
    //return super.toString();
    var result = 'TagRenderException at tag $tag:\n  $error\nStacktrace was at:\n$stacktrace';
    return result;
  }
}
