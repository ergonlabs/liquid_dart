import 'dart:collection';

import '../errors.dart';
import '../expressions.dart';

import '../context.dart';
import '../block.dart';

class Comment extends Block {
  Comment(): super([]);

  static final SimpleBlockFactory factory = (tokens, children) {
    return Comment();
  };
}
