import './builtins.dart';
import 'block.dart';
import 'tag.dart';

typedef Filter = dynamic Function(dynamic input, List<dynamic> args);

abstract class RenderContext {
  RenderContext? get parent;

  RenderContext get root;

  Map<String, Iterable<String>>? blocks;

  Map<String, dynamic> get variables;

  Map<String, Filter> get filters;

  Map<String, dynamic> getTagState(Tag tag);

  RenderContext push(Map<String, dynamic> variables);

  RenderContext clone();

  RenderContext cloneAsRoot();

  void registerModule(String load);
}

abstract class ParseContext {
  Map<String, BlockParserFactory> get tags;
}

abstract class Module {
  void register(Context context);
}

class Context implements RenderContext, ParseContext {
  @override
  Map<String, Iterable<String>>? blocks = {};

  @override
  Map<String, BlockParserFactory> tags = {};

  @override
  Map<String, dynamic> variables = {};

  @override
  Map<String, Filter> filters = {};

  Map<String, Module> modules = {'builtins': BuiltinsModule()};

  Map<Tag, Map<String, dynamic>> tagStates = {};

  @override
  Map<String, dynamic> getTagState(Tag tag) => parent == null
      ? tagStates.putIfAbsent(tag, () => {})
      : root.getTagState(tag);

  @override
  Context? parent;

  @override
  RenderContext get root => parent == null ? this : parent!.root;

  Context._();

  @override
  void registerModule(String load) {
    modules[load]!.register(this);
  }

  factory Context.create() {
    final context = Context._();

    context.modules['builtins']!.register(context);

    return context;
  }

  @override
  Context push(Map<String, dynamic> variables) {
    final context = Context._();
    context.blocks = Map.from(blocks!);
    context.tags = Map.from(tags);
    context.filters = Map.from(filters);
    context.variables = Map.from(this.variables);
    context.variables.addAll(variables);
    context.parent = this;
    return context;
  }

  @override
  Context clone() => push({});

  @override
  Context cloneAsRoot() {
    final context = clone();
    context.parent = null;
    return context;
  }
}
