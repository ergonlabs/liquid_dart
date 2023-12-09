import 'package:liquid_engine/liquid_engine.dart';
import 'package:liquid_engine/src/drop.dart';
import 'package:test/test.dart';

void main() {
  group('drop', () {
    test('properties', () async {
      var context = Context.create().push({"name": PersonDrop(firstName: "John", lastName: "Jones")});
      expect(await Template.parse(context, Source(null, '{{ name.firstName }}', null)).render(context), equals('John'));
      expect(await Template.parse(context, Source(null, '{{ name.lastName }}', null)).render(context), equals('Jones'));
    });

    test('nesting', () async {
      var context = Context.create().push({"name": PersonDrop(firstName: "John", lastName: "Jones")});
      var template = Template.parse(context, Source(null, '{{ name.address.country }}', null));
      expect(await template.render(context), equals('U.S.A'));
    });

    test('invokable', () async {
      var context = Context.create().push({"name": PersonDrop(firstName: "John", lastName: "Jones")});
      expect(await Template.parse(context, Source(null, '{{ name.first }}', null)).render(context), equals('John'));
      expect(await Template.parse(context, Source(null, '{{ name.last }}', null)).render(context), equals('Jones'));
    });
  });
}

class ProductDrop extends Drop {}

class AddressDrop extends Drop {
  @override
  Map<String, dynamic> get attrs => {"country": "U.S.A"};
}

class PersonDrop extends Drop {
  String firstName;
  String lastName;

  PersonDrop({required this.firstName, required this.lastName});

  String fullName() {
    return '$firstName $lastName';
  }

  @override
  Map<String, dynamic> get attrs => {
        "firstName": firstName,
        "lastName": lastName,
        "fullName": fullName(),
        "address": AddressDrop(),
      };

  @override
  List<Symbol> get invokable => [
        ...super.invokable,
        #first,
        #last,
      ];

  @override
  invoke(Symbol symbol) {
    switch (symbol) {
      case #first:
        return firstName;
      case #last:
        return lastName;
      default:
        return liquidMethodMissing(symbol);
    }
  }
}
