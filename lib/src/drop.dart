import 'package:gato/gato.dart' as gato;
import 'package:liquid_engine/liquid_engine.dart';

extension SymbolExtension on Symbol {
  String get name {
    var _name = toString();
    return toString().replaceRange(_name.length - 2, _name.length, '').replaceAll("Symbol(\"", '');
  }
}

abstract class Drop {
  List<Symbol> invokable = [];
  Map<String, dynamic> attrs = {};

  RenderContext? context = null;

  dynamic liquidMethodMissing(Symbol method) => null;

  dynamic call(Symbol attr) {
    if (get(attr.name) != null) return get(attr.name);
    if (invokable.isNotEmpty && invokable.contains(attr)) {
      return invoke(attr);
    }

    return liquidMethodMissing(attr);
  }

  dynamic operator [](String path) {
    return get(path);
  }

  dynamic invoke(Symbol symbol) {
    return null;
  }

  dynamic exec(Symbol method) {
    return this(method);
  }

  dynamic get(String path) {
    return gato.get(attrs, path);
  }
}
