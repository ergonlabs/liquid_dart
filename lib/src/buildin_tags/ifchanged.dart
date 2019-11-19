import 'dart:collection';

import 'package:liquid/src/errors.dart';
import 'package:liquid/src/parser/tag_parser.dart';
import 'package:liquid/src/expressions.dart';

import '../context.dart';
import '../block.dart';
import '../model.dart';
import '../tag.dart';

class IfChanged extends Block {
  IfChanged(children) : super(children);

  @override
  Iterable<String> render(RenderContext context) {
    var state = context.getTagState(this);
    var output = state['output'];
    var result = super.render(context).join();
    if (output == result) {
      return Iterable.empty();
    }
    state['output'] = result;
    return [result];
  }

  static final SimpleBlockFactory factory =
      (tokens, children) => IfChanged(children);
}
