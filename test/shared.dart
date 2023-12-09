import 'package:liquid_engine/liquid_engine.dart';

String reverse(String string) {
  final sb = StringBuffer();
  for (int i = string.length - 1; i >= 0; i--) {
    sb.writeCharCode(string.codeUnitAt(i));
  }
  return sb.toString();
}

class TestRoot implements Root {
  Map<String, String> files;

  TestRoot(this.files);

  @override
  Future<Source> resolve(String relPath) async {
    return Source(null, files[relPath]!, this);
  }
}