import 'package:liquid_engine/liquid_engine.dart';
import 'package:liquid_engine/src/context.dart';
import 'package:liquid_engine/src/model.dart';
import 'package:liquid_engine/src/template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tests', () {
    test('First Test', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static markup', null));

      expect(template.render(context), equals('static markup'));
    });

    test('missing var', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ missing }} markup', null));

      expect(template.render(context), equals('static  markup'));
    });

    test('valid var', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ variable }} markup', null));

      context.variables['variable'] = 'fun';

      expect(template.render(context), equals('static fun markup'));
    });

    test('string var', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ "variable" }} markup', null));

      context.variables['variable'] = 'fun';

      expect(template.render(context), equals('static variable markup'));
    });

    test('assign', () {
      final context = Context.create();

      var template =
          Template.parse(context, Source(null, '{% assign variable = "fun" %}static {{ variable }} markup{% endassign %}', null));

      context.variables['variable'] = 'badtimes';

      expect(template.render(context), equals('static fun markup'));
    });

    test('capture', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% capture variable %}markup{% endcapture %}static {{ variable }}', null));

      context.variables['variable'] = 'badtimes';

      expect(template.render(context), equals('static markup'));
    });

    test('comment', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% comment %}markup{% endcomment %}static', null));

      expect(template.render(context), equals('static'));
    });

    test('for', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo %} {{ x }} potabo{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(template.render(context), equals(' a potabo 4 potabo 4.5 potabo'));
    });

    test('for empty', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo2 %} {{ x }} potabo{% else %}EMPTY!{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(template.render(context), equals('EMPTY!'));
    });

    test('cycle', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo %} {% cycle 1, 2, 3 %}{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(template.render(context), equals(' 1 2 3'));
    });

    test('expressions', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{{ a }} {{ d.1 }} {{ b.a }} {{ "nuf" | reverse }}{{ c }}{{ c.c }}', null));

      context.filters['reverse'] = (i, a) => reverse(i.toString());
      context.variables['a'] = 'this';
      context.variables['b'] = {'a': 'is'};
      context.variables['d'] = [
        'wat',
        'so',
        'wat',
      ];

      expect(template.render(context), equals('this so is fun'));
    });

    test('filter', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% filter reverse%}nuf{% endfilter %}', null));

      context.filters['reverse'] = (i, a) => reverse(i.toString());

      expect(template.render(context), equals('fun'));
    });

    test('as', () {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% filter reverse as XX %}nuf{% endfilter %}{{ XX }} {{ XX }}', null));

      context.filters['reverse'] = (i, a) => reverse(i.toString());

      expect(template.render(context), equals('fun fun'));
    });

    test('if', () {
      final context = Context.create();

      context.variables['a'] = 'this';
      context.variables['b'] = {'a': 'is'};
      context.variables['d'] = [
        'wat',
        'so',
        'wat',
      ];

      var template = Template.parse(context, Source(null, '{% if a == "this" %}yes{% endif %}', null));
      expect(template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% else %}yes{% endif %}', null));
      expect(template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% elseif true %}yes{% else %}no{% endif %}', null));
      expect(template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% elseif 7 > 4 %}yes{% else %}no{% endif %}', null));
      expect(template.render(context), equals('yes'));
    });

    test('include', () {
      final context = Context.create();
      final root = TestRoot({
        'name_snippet.html': '{{ greeting }}, {{ person|default:"friend" }}!',
        'simple': '{% include "name_snippet.html" %}',
        'args': '{% include "name_snippet.html" with person="Jane" greeting="Howdy" %}',
        'only': '{% include "name_snippet.html" with greeting="Hi" only %}',
      });

      context.variables['person'] = "John";
      context.variables['greeting'] = "Hello";

      var template = Template.parse(context, root.resolve('simple'));
      expect(template.render(context), equals('Hello, John!'));
      template = Template.parse(context, root.resolve('args'));
      expect(template.render(context), equals('Howdy, Jane!'));
      template = Template.parse(context, root.resolve('only'));
      expect(template.render(context), equals('Hi, friend!'));
    });

    test('extends', () {
      final context = Context.create();
      final root = TestRoot({
        'base2': 'outer == {% block fun %}base2{% endblock %}',
        'base1': '{% extends base_var %}{% block fun %}base1{% endblock %}',
        'base0': '{% extends "base1" %}{% block fun %}base0{% endblock %}',
      });

      context.variables['base_var'] = 'base2';

      var template = Template.parse(context, root.resolve('base0'));
      expect(template.render(context), equals('outer == base0'));
      template = Template.parse(context, root.resolve('base1'));
      expect(template.render(context), equals('outer == base1'));
      template = Template.parse(context, root.resolve('base2'));
      expect(template.render(context), equals('outer == base2'));
    });
  });

  test('regroup', () {
    // https://docs.djangoproject.com/en/3.0/ref/templates/builtins/#regroup
    final context = Context.create();

    var template = Template.parse(
        context,
        Source(
            null,
            '{% regroup cities by country as country_list %} ' +
                '<ul> {% for country in country_list %} ' +
                '<li>{{ country.grouper }} ' +
                '<ul>  {% for city in country.list %} ' +
                '<li> {{ city.name }}: {{ city.population }} </li>' +
                '  {% endfor %}  </ul> ' +
                ' </li> ' +
                '{% endfor %} </ul>',
            null));

    context.variables['cities'] = [
      {'name': 'Mumbai', 'population': '19,000,000', 'country': 'India'},
      {'name': 'Calcutta', 'population': '15,000,000', 'country': 'India'},
      {'name': 'New York', 'population': '20,000,000', 'country': 'USA'},
      {'name': 'Chicago', 'population': '7,000,000', 'country': 'USA'},
      {'name': 'Tokyo', 'population': '33,000,000', 'country': 'Japan'},
    ];

    expect(
        template.render(context),
        equals(
            ' <ul>  <li>India <ul>   <li> Mumbai: 19,000,000 </li>   <li> Calcutta: 15,000,000 </li>    </ul>  </li>  <li>USA <ul>   <li> New York: 20,000,000 </li>   <li> Chicago: 7,000,000 </li>    </ul>  </li>  <li>Japan <ul>   <li> Tokyo: 33,000,000 </li>    </ul>  </li>  </ul>'));
  });
}

reverse(String string) {
  final sb = StringBuffer();
  for (int i = string.length - 1; i >= 0; i--) {
    sb.writeCharCode(string.codeUnitAt(i));
  }
  return sb.toString();
}

class TestRoot implements Root {
  Map<String, String> files;

  TestRoot(this.files);

  @override
  Uri get path => null;

  @override
  Source resolve(String relPath) {
    return Source(null, files[relPath], this);
  }
}
