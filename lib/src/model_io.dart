
import 'dart:io';

import '../liquid_engine.dart';

class BuildPath implements Root {
  final Uri _path;

  BuildPath(this._path);

  @override
  Future<Source> resolve(String relPath) async {
    final file = _path.resolve(relPath);
    final content = await File.fromUri(file).readAsString();
    return Source(file, content, this);
  }
}