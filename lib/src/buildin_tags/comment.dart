import 'dart:collection';

import 'package:liquid/src/errors.dart';
import 'package:liquid/src/expressions.dart';

import '../context.dart';
import '../block.dart';

class Comment extends Block {
  Comment(): super([]);

  static final SimpleBlockFactory factory = (tokens, children) {
    return Comment();
  };
}
