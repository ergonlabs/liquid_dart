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

  DocumentFuture(this.root, this.context, this.path);

  Document resolve(RenderContext context) {
    var path = this.path.evaluate(context);
    if (path is Template) {
      return path.document;
    }
    if (path is Document) {
      return path;
    }
    return Template.parse(this.context, root.resolve(path)).document;
  }
}

class Document extends Block {
  DocumentFuture? base;
  List<String> loads;

  Document(this.base, this.loads, List<Tag> children) : super(children);

  @override
  Iterable<String> render(RenderContext initialContext) {
    var context = initialContext.cloneAsRoot();

    for (final load in loads) {
      context.registerModule(load);
    }

    if (base == null) {
      return super.render(context);
    }

    var baseContext = initialContext.cloneAsRoot();
    for (final tag in children) {
      if (tag is NamedBlock) {
        baseContext.blocks[tag.name] = tag.render(context);
      } else {
        tag.render(context);
      }
    }
    return base!.resolve(context).render(baseContext);
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
  void unexpectedTag(
      Parser parser, Token start, List<Token> args, List<Tag> childrenSoFar) {
    throw ParseException.unexpected(start);
  }
}
