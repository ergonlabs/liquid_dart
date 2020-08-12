import './errors.dart';
import 'block.dart';
import 'context.dart';
import 'model.dart';
import 'tag.dart';

abstract class Expression {
  dynamic evaluate(RenderContext context);

  @override
  String toString() {
    return 'Expression{}';
  }
}

typedef dynamic Operation(dynamic a, dynamic b);

class BooleanCastExpression implements Expression {
  final Expression input;

  BooleanCastExpression(this.input);

  @override
  evaluate(RenderContext context) {
    bool _bool(dynamic a) {
      if (a == null) {
        return false;
      } else if (a is bool) {
        return a;
      } else if (a is String) {
        return a.isNotEmpty;
      } else if (a is List) {
        return a.isNotEmpty;
      } else if (a is Map) {
        return a.isNotEmpty;
      } else if (a is num) {
        return !a.isNaN && a != 0;
      }
      return true;
    }

    return _bool(input.evaluate(context));
  }

  @override
  String toString() {
    return 'BooleanCastExpression{input: $input}';
  }
}

class NotExpression extends BooleanCastExpression {
  NotExpression(Expression input) : super(input);

  @override
  evaluate(RenderContext context) => !super.evaluate(context);

  @override
  String toString() {
    return 'NotExpression{}';
  }
}

class BinaryOperation implements Expression {
  Operation operation;
  Expression left;
  Expression right;

  BinaryOperation(this.operation, this.left, this.right);

  dynamic evaluate(RenderContext context) => operation(left.evaluate(context), right.evaluate(context));

  @override
  String toString() {
    return 'BinaryOperation{operation: $operation, left: $left, right: $right}';
  }
}

class ConstantExpression implements Expression {
  dynamic value;

  ConstantExpression(this.value);

  factory ConstantExpression.fromToken(Token token) {
    if (token.type == TokenType.single_string || token.type == TokenType.double_string) {
      return ConstantExpression(token.value.substring(1, token.value.length - 1));
    } else if (token.type == TokenType.number) {
      return ConstantExpression(num.parse(token.value));
    } else {
      throw ParseException.unexpected(token);
    }
  }

  @override
  evaluate(RenderContext context) => value;

  @override
  String toString() {
    return 'ConstantExpression{value: $value}';
  }
}

class LookupExpression implements Expression {
  Token name;

  LookupExpression(this.name);

  @override
  evaluate(RenderContext context) {
    return context.variables[name.value];
  }

  @override
  String toString() {
    return 'LookupExpression{name: $name}';
  }
}

class MemberExpression implements Expression {
  Expression base;
  Token member;

  MemberExpression(this.base, this.member);

  @override
  evaluate(RenderContext context) {
    final base = this.base.evaluate(context);
    if (base == null) {
      return null;
    }
    if (base is Map) {
      return base[member.value];
    }
    if (base is List) {
      return base[int.parse(member.value) % base.length];
    } else {
      print('Warning: $this only supports bases of type List or Map, found ${base.runtimeType} instead, returning null');
      return null;
    }
  }

  @override
  String toString() {
    return 'MemberExpression{base: $base, member: $member}';
  }
}

class FilterExpression implements Expression {
  final Expression input;
  final Token name;
  final List<Expression> arguments;

  FilterExpression(this.input, this.name, this.arguments);

  dynamic evaluate(RenderContext context) {
    var output = input.evaluate(context);
    var filter = context.filters[name.value];
    if (filter == null) {
      throw ParseException.unexpected(name);
    }
    return filter(output, arguments.map((e) => e.evaluate(context)).toList());
  }

  @override
  String toString() {
    return 'FilterExpression{input: $input, name: $name, arguments: $arguments}';
  }
}

class BlockExpression implements Expression {
  final Block block;

  BlockExpression(this.block);

  BlockExpression.fromTags(List<Tag> tags) : this(Block(tags));

  @override
  evaluate(RenderContext context) => block.render(context).join("");

  @override
  String toString() {
    return 'BlockExpression{block: $block}';
  }
}

class ExpressionTag implements Tag {
  Expression expression;

  @override
  Iterable<String> render(RenderContext context) sync* {
    var output = expression.evaluate(context);
    yield output != null ? output.toString() : '';
  }

  ExpressionTag(this.expression);

  @override
  String toString() {
    return 'ExpressionTag{expression: $expression}';
  }
}
