import '../block.dart';

class Comment extends Block {
  Comment() : super([]);

  static final SimpleBlockFactory factory = (tokens, children) {
    return Comment();
  };
}
