import './errors.dart';
import './expressions.dart';
import './model.dart';
import './template.dart';
import 'block.dart';
import 'buildin_tags/extends.dart';
import 'buildin_tags/load.dart';
import 'buildin_tags/named_block.dart';
import 'context.dart';
import 'parser/parser.dart';
import 'tag.dart';

class DocumentFuture {
  final Root root;
  final ParseContext context;
  final Expression path;

  Document? _document;

  DocumentFuture(this.root, this.context, this.path);

  Future<Document> resolve(RenderContext context) async {
    return _document ?? (_document = await _resolve(context));
  }

  Future<Document> _resolve(RenderContext context) async {
    var path = await this.path.evaluate(context);
    if (path is Template) {
      return path.document;
    }
    if (path is Document) {
      return path;
    }
    return Template.parse(this.context, await root.resolve(path)).document;
  }
}

class Document extends Block {
  DocumentFuture? base;
  List<String> loads;

  Document(this.base, this.loads, List<Tag> children) : super(children);

  @override
  Stream<String> render(RenderContext initialContext) async* {
    var context = initialContext.cloneAsRoot();

    for (final load in loads) {
      context.registerModule(load);
    }

    if (base == null) {
      yield* super.render(context);
      return;
    }

    var baseContext = initialContext.cloneAsRoot();
    for (final tag in children) {
      if (tag is NamedBlock) {
        baseContext.blocks[tag.name] = await tag.render(context).join();
      } else {
        tag.render(context);
      }
    }
    yield* (await base!.resolve(context)).render(baseContext);
  }
}

class DocumentParser extends BlockParser {
  @override
  bool approveTag(Token start, List<Tag> childrenSoFar, Token? asToken) {
    if (start.value == 'extends') {
      return childrenSoFar.isEmpty;
    }
    if (start.value == 'load') {
      return childrenSoFar.every((t) => t is Load || t is Extends);
    }
    if (childrenSoFar.isNotEmpty && childrenSoFar.first is Extends) {
      return asToken != null || start.value == 'block';
    }
    return super.approveTag(start, childrenSoFar, asToken);
  }

  @override
  Block create(List<Token> tokens, List<Tag> children) {
    var start = 0;
    DocumentFuture? base;
    final loads = <String>[];
    if (children.isNotEmpty) {
      if (children.length > start && children[start] is Extends) {
        base = (children[start] as Extends).base;
        start++;
      }

      while (children.length > start && children[start] is Load) {
        loads.add((children[start] as Load).library);
        start++;
      }
    }
    return Document(base, loads, children.sublist(start));
  }

  @override
  void unexpectedTag(Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    throw ParseException.unexpected(start);
  }
}
