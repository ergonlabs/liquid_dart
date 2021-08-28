import '../block.dart';
import '../context.dart';

class IfChanged extends Block {
  IfChanged(children) : super(children);

  @override
  Stream<String> render(RenderContext context) async* {
    var state = context.getTagState(this);
    var output = state['output'];
    var result = await super.render(context).join();
    if (output == result) {
      return;
    }
    state['output'] = result;
    yield result;
  }

  static final SimpleBlockFactory factory = (tokens, children) => IfChanged(children);
}
