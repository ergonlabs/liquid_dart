import 'dart:convert';
import 'dart:math';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:liquid_engine/src/model.dart';
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

    context.filters['parseInt'] = (input, args) {
      if (input is num) {
        return input.toInt();
      }
      return 0;
    };

    context.filters['parseDouble'] = (input, args) {
      if (input is num) {
        return input.toDouble();
      }
      return 0.0;
    };

    context.filters['roundDouble'] = (input, args) {
      var digit = 2;
      if (args.isNotEmpty == true) {
        var d = args.first;
        if (d is String) {
          digit = int.tryParse(d) ?? 0;
        } else if (d is num) {
          digit = d.toInt();
        }
      }
      if (input is num) {
        return input.roundDouble(places: digit);
      }
      return 0.0;
    };

    context.filters['stringAsFixed'] = (input, args) {
      var digit = 0;
      if (args.isNotEmpty == true) {
        var d = args.first;
        if (d is String) {
          digit = int.tryParse(d) ?? 0;
        } else if (d is num) {
          digit = d.toInt();
        }
      }

      if (input is num) {
        return input.toStringAsFixed(digit);
      }
      return 0.0;
    };

    context.filters['parseNum'] = (input, args) {
      if (input is num) {
        return input;
      }
      return num.tryParse('$input') ?? 0;
    };

    context.filters['abs'] = (input, args) {
      if (input is num) {
        return input.abs();
      }
      return 0;
    };

    context.filters['tr'] = (input, args) {
      LiquidEngine.logger.info("start tr");
      var _args = <String>[];
      // var _namedArgs = <String, String>{};
      // var _gender = "";
      LiquidEngine.logger.info("args ${args.runtimeType}");
      _args = List<String>.from(args);
      // if (args.isNotEmpty == true) {
      //   if (args is List<String> || args is Iterable<String>) {
      //     LiquidEngine.logger.info("args is list of string");
      //     _args = List<String>.from(args);
      //   } else {
      //     LiquidEngine.logger.info("args is list of dynamic");
      //     var m = List<Map>.from(args.map((e) => jsonDecode(e)).toList());
      //     if (m.isNotEmpty) {
      //       _args = List<String>.from(Map.from(m[0]).values);
      //     }
      //     if (m.length > 1) {
      //       _namedArgs = Map<String, String>.from(m[1]);
      //     }
      //     if (m.length > 2) {
      //       _gender = m[2].values.first;
      //     }
      //   }
      // }

      if (input is String) {
        return input.tr(
          args: _args,
          // namedArgs: _namedArgs,
          // gender: _gender,
        );
      } else {
        return "$input".tr(
          args: _args,
          // namedArgs: _namedArgs,
          // gender: _gender,
        );
      }
    };

    context.filters['qrcode'] = (input, args) {
      LiquidEngine.logger.info("start qrcode");
      var width = 300;
      var height = 200;
      var barcode = BarcodefromText("Code128");
      if (args.isNotEmpty) {
        width = int.tryParse("${args[0]}") ?? 300;
        if (args.length > 1) {
          height = int.tryParse("${args[1]}") ?? 200;
        }
        if (args.length > 2) {
          barcode = BarcodefromText("${args[2]}");
          LiquidEngine.logger.info(barcode);
        }
      }
      var image = Image(width, height);
      // Fill it with a solid color (white)
      fill(image, getColor(255, 255, 255));
      // Draw the barcode
      drawBarcode(image, barcode, "$input", font: arial_24);
      // encode as png
      var dataImage = encodePng(image);
      // base46 decode
      var byteString = base64Encode(dataImage);

      return "data:image/png;base64,$byteString";

      // var _args = <String>[];
      // LiquidEngine.logger.info("args ${args.runtimeType}");
      // _args = List<String>.from(args);
      // if (input is String) {
      //   return input.tr(
      //     args: _args,
      //   );
      // } else {
      //   return "$input".tr(
      //     args: _args,
      //   );
      // }
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

Barcode BarcodefromText(String type) {
  switch (type.toLowerCase()) {
    case "code39":
      return Barcode.code39();
    case "code93":
      return Barcode.code93();
    case "code128":
      return Barcode.code128();
    case "gs128":
      return Barcode.gs128();
    case "itf":
      return Barcode.itf();
    case "codeitf14":
      return Barcode.itf14();
    case "codeitf16":
      return Barcode.itf16();
    case "codeean13":
      return Barcode.ean13();
    case "codeean8":
      return Barcode.ean8();
    case "codeean5":
      return Barcode.ean5();
    case "codeean2":
      return Barcode.ean2();
    case "codeisbn":
      return Barcode.isbn();
    case "codeupca":
      return Barcode.upcA();
    case "codeupce":
      return Barcode.upcE();
    case "telepen":
      return Barcode.telepen();
    case "codabar":
      return Barcode.codabar();
    case "rm4scc":
      return Barcode.rm4scc();
    case "qrcode":
      return Barcode.qrCode();
    case "pdf417":
      return Barcode.pdf417();
    case "datamatrix":
      return Barcode.dataMatrix();
    case "aztec":
      return Barcode.aztec();
    default:
      return Barcode.code128();
  }
}

extension NumParsing on num {
  double roundDouble({int places = 2}) {
    var mod = pow(10.0, places) as double;
    var coercion = this + 0.00000001;
    return ((coercion * mod).round().toDouble() / mod);
  }
}
