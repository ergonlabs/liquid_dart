import 'dart:async';

import './errors.dart';
import 'block.dart';
import 'context.dart';
import 'drop.dart';
import 'model.dart';
import 'tag.dart';

abstract class Expression {
  Future<dynamic> evaluate(RenderContext context);

  @override
  String toString() {
    return 'Expression{}';
  }
}

typedef Operation = dynamic Function(dynamic a, dynamic b);

class BooleanCastExpression implements Expression {
  final Expression input;

  BooleanCastExpression(this.input);

  @override
  Future<bool> evaluate(RenderContext context) async {
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

    return _bool(await input.evaluate(context));
  }

  @override
  String toString() {
    return 'BooleanCastExpression{input: $input}';
  }
}

class NotExpression extends BooleanCastExpression {
  NotExpression(Expression input) : super(input);

  @override
  Future<bool> evaluate(RenderContext context) async => !(await super.evaluate(context));

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

  @override
  Future<dynamic> evaluate(RenderContext context) async => operation(await left.evaluate(context), await right.evaluate(context));

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
  Future<dynamic> evaluate(RenderContext context) async => value;

  @override
  String toString() {
    return 'ConstantExpression{value: $value}';
  }
}

class LookupExpression implements Expression {
  Token name;

  LookupExpression(this.name);

  @override
  Future<dynamic> evaluate(RenderContext context) async {
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
  Future<dynamic> evaluate(RenderContext context) async {
    final base = await this.base.evaluate(context);
    if (base == null) {
      return null;
    }

    if (base is Drop) {
      base.context = context;
      return base(Symbol(member.value));
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

  @override
  Future<dynamic> evaluate(RenderContext context) async {
    var output = await input.evaluate(context);
    var filter = context.filters[name.value];
    if (filter == null) {
      throw ParseException.unexpected(name);
    }
    return filter(output, await Future.wait(arguments.map((e) => _evaluateToFuture(e, context))));
  }

  Future<dynamic> _evaluateToFuture(Expression e, RenderContext context) async => await e.evaluate(context);

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
  Future<String> evaluate(RenderContext context) => block.render(context).join('');

  @override
  String toString() {
    return 'BlockExpression{block: $block}';
  }
}

class ExpressionTag implements Tag {
  Expression expression;

  @override
  Stream<String> render(RenderContext context) async* {
    var output = await expression.evaluate(context);
    yield output != null ? output.toString() : '';
  }

  ExpressionTag(this.expression);

  @override
  String toString() {
    return 'ExpressionTag{expression: $expression}';
  }
}
