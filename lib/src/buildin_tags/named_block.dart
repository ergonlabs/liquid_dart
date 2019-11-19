import 'package:liquid/src/context.dart';
import 'package:liquid/src/errors.dart';
import 'package:liquid/src/tag.dart';

import '../block.dart';

class NamedBlock extends Block {
  final String name;

  NamedBlock(this.name, List<Tag> children) : super(children);

  @override
  Iterable<String> render(RenderContext context) {
    if (context.blocks.containsKey(name)) {
      return context.blocks[name];
    }
    return super.render(context);
  }

  static SimpleBlockFactory get factory => (tokens, children) {
    if (tokens.length == 0) {
      throw ParseException('{% block %} missing name');
    }
    if (tokens.length > 1) {
      throw ParseException.unexpected(tokens[1]);
    }

    return NamedBlock(tokens.first.value, children);
  };
}
