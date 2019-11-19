import 'dart:collection';

import '../errors.dart';
import '../parser/tag_parser.dart';
import '../expressions.dart';

import '../context.dart';
import '../block.dart';
import '../model.dart';
import '../tag.dart';

class Load extends Block {
  String library;

  Load(this.library): super([]);

  @override
  Iterable<String> render(RenderContext context) {

    return Iterable.empty();
  }

  static final SimpleBlockFactory factory = (tokens, children) {
    var parser = TagParser.from(tokens);
    parser.expect(types: [TokenType.identifier]);
    final library = parser.current.value;
    return Load(library);
  };
}
