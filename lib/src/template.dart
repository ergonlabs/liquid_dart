import './block.dart';

import 'context.dart';
import 'document.dart';
import 'model.dart';
import 'parser/parser.dart';

extension JsSplit on String {
  Iterable<String> inclusiveSplit(RegExp pattern) sync* {
    final matches = pattern.allMatches(this);
    var pos = 0;

    for (final match in matches) {
      if (match.start > pos) {
        yield this.substring(pos, match.start);
      }
      yield match.group(0);
      pos = match.end;
    }

    if (pos < this.length - 1) {
      yield this.substring(pos);
    }
  }
}

class Template {
  final Source source;
  final Document document;

  Template(this.source, this.document);

  factory Template.parse(ParseContext context, Source source) =>
      Template(source, Parser(context, source).parse());

  String render(Context context) =>
      (StringBuffer()..writeAll(document.render(context))).toString();
}
