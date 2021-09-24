import 'package:intl/intl.dart';

import 'block.dart';
import 'buildin_tags/assign.dart';
import 'buildin_tags/capture.dart';
import 'buildin_tags/comment.dart';
import 'buildin_tags/cycle.dart';
import 'buildin_tags/extends.dart';
import 'buildin_tags/filter.dart';
import 'buildin_tags/for.dart';
import 'buildin_tags/if.dart';
import 'buildin_tags/ifchanged.dart';
import 'buildin_tags/include.dart';
import 'buildin_tags/load.dart';
import 'buildin_tags/named_block.dart';
import 'buildin_tags/regroup.dart';
import 'context.dart';

class BuiltinsModule implements Module {
  @override
  void register(Context context) {
    context.tags['assign'] = BlockParser.simple(Assign.factory);
    context.tags['cache'] = BlockParser.simple(Cache.factory);
    context.tags['capture'] = BlockParser.simple(Capture.factory);
    context.tags['comment'] = BlockParser.simple(Comment.factory);
    context.tags['for'] = For.factory;
    context.tags['cycle'] = BlockParser.simple(Cycle.factory, hasEndTag: false);
    context.tags['ifchanged'] = BlockParser.simple(IfChanged.factory);
    context.tags['if'] = If.factory;
    context.tags['unless'] = If.unlessFactory;
    context.tags['include'] = Include.factory;
    context.tags['filter'] = BlockParser.simple(FilterBlock.factory);
    context.tags['load'] = BlockParser.simple(Load.factory, hasEndTag: false);
    context.tags['block'] = BlockParser.simple(NamedBlock.factory);
    context.tags['extends'] = Extends.factory;
    context.tags['regroup'] = Regroup.factory;

    context.filters['default'] = (input, args) {
      var output = input != null ? input.toString() : '';
      if (output.isNotEmpty) {
        return output;
      }

      for (final arg in args) {
        output = arg != null ? arg.toString() : '';
        if (output.isNotEmpty) {
          return output;
        }
      }

      return '';
    };

    context.filters['default_if_none'] = (input, args) {
      if (input != null) {
        return input;
      }

      for (final arg in args) {
        if (arg != null) {
          return arg;
        }
      }

      return '';
    };

    context.filters['add'] = (input, args) {
      assert(input != null);
      var output = input;
      if (output is List) {
        for (var arg in args) {
          output = [...output, ...arg];
        }
      } else if (output is num) {
        for (var arg in args) {
          var v = num.tryParse('$arg');
          assert(v != null && v is num);
          output += v;
        }
      }
      return output;
    };

    context.filters['minus'] = (input, args) {
      assert(input != null);
      var output = input;
      if (output is List) {
        for (var arg in args) {
          var list = arg as List;
          output = output.where((e) => !list.contains(e)).toList();
        }
      } else if (output is num) {
        for (var arg in args) {
          var v = num.tryParse('$arg');
          assert(v != null && v is num);
          output -= v;
        }
      }
      return output;
    };

    context.filters['multi'] = (input, args) {
      assert(input != null && input is num);
      var output = input;
      for (final arg in args) {
        var v = num.tryParse('$arg');
        assert(v != null && v is num);
        output *= v;
      }
      return output;
    };

    context.filters['divide'] = (input, args) {
      assert(input != null && input is num);
      var output = input;
      for (final arg in args) {
        var v = num.tryParse('$arg');
        assert(v != null && v is num);
        output /= v;
      }
      return output;
    };

    context.filters['modulus'] = (input, args) {
      assert(input != null && input is num);
      var output = input;
      for (final arg in args) {
        var v = num.tryParse('$arg');
        assert(v != null && v is num);
        output %= v;
      }
      return output;
    };

    context.filters['date'] = (input, args) {
      var output = input;
      if (input is String) {
        output = DateTime.tryParse(input);
      }
      output ??= DateTime.now();

      for (var arg in args) {
        var formatter = DateFormat('yyyy-MM-dd');
        if (arg != null) {
          if (arg is String) {
            formatter = DateFormat(arg);
          } else if (arg is DateFormat) {
            formatter = arg;
          }
        }

        output = formatter.format((output as DateTime));
      }
      return output;
    };

    context.filters['size'] = (input, args) {
      if (input is Iterable) {
        return input.length;
      } else if (input is String) {
        return input.length;
      } else if (input is Object) {
        return 0;
      }
      return 0;
    };

    context.filters['isEmpty'] = (input, args) {
      if (input == null) {
        return true;
      } else if (input is Iterable) {
        return input.isEmpty;
      } else if (input is String) {
        if (input == 'null') {
          return true;
        }
        return input.isEmpty;
      }
      return true;
    };

    context.filters['isNotEmpty'] = (input, args) {
      if (input == null) {
        return false;
      } else if (input is Iterable) {
        return input.isNotEmpty;
      } else if (input is String) {
        if (input == 'null') {
          return false;
        }
        return input.isNotEmpty;
      }
      return false;
    };

    context.filters['downcase'] = context.filters['lower'] = (input, args) => input!.toString().toLowerCase();

    context.filters['upcase'] = context.filters['upper'] = (input, args) => input!.toString().toUpperCase();

    context.filters['capitalize'] = context.filters['capfirst'] = (input, args) => input!.toString().replaceFirstMapped(
          RegExp(r'^\w'),
          (m) => m.group(0)!.toUpperCase(),
        );

    context.filters['join'] = (input, args) => (input as Iterable).join(args.isNotEmpty ? args[0] : ' ');

    context.variables['true'] = true;
    context.variables['false'] = false;
    context.variables['null'] = null;
  }
}
