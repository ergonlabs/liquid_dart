import 'package:liquid_engine/liquid_engine.dart';
import 'package:liquid_engine/src/exception/parse_block_exception.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  group('tests', () {
    test('First Test', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static markup', null));

      expect(await template.render(context), equals('static markup'));
    });

    test('missing var', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ missing }} markup', null));

      expect(await template.render(context), equals('static  markup'));
    });

    test('valid var', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ variable }} markup', null));

      context.variables['variable'] = 'fun';

      expect(await template.render(context), equals('static fun markup'));
    });

    test('whitespace', () async {
      var render = (String source) async {
        final context = Context.create();

        var template = Template.parse(context, Source(null, source, null));

        context.variables['variable'] = 'fun';

        return await template.render(context);
      };

      expect(await render('fun \n {{ variable }} \n fun'), equals('fun \n fun \n fun'));
      expect(await render('fun \n {{ variable -}} \n fun'), equals('fun \n funfun'));
      expect(await render('fun \n {{- variable }} \n fun'), equals('funfun \n fun'));
      expect(await render('fun \n {{- variable -}} \n fun'), equals('funfunfun'));
    });

    test('string var', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, 'static {{ "variable" }} markup', null));

      context.variables['variable'] = 'fun';

      expect(await template.render(context), equals('static variable markup'));
    });

    test('assign', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% assign variable = "fun" %}static {{ variable }} markup{% endassign %}', null));

      context.variables['variable'] = 'badtimes';

      expect(await template.render(context), equals('static fun markup'));
    });

    test('bad assign', () async {
      final context = Context.create();

      expect(
        () => Template.parse(context, Source(null, '{% assign %}', null)),
        throwsA(isA<ParseBlockException>()),
      );
    });

    test('capture', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% capture variable %}markup{% endcapture %}static {{ variable }}', null));

      context.variables['variable'] = 'badtimes';

      expect(await template.render(context), equals('static markup'));
    });

    test('comment', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% comment %}markup{% endcomment %}static', null));

      expect(await template.render(context), equals('static'));
    });

    test('for', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo %} {{ x }} potabo{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(await template.render(context), equals(' a potabo 4 potabo 4.5 potabo'));
    });

    test('for empty', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo2 %} {{ x }} potabo{% else %}EMPTY!{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(await template.render(context), equals('EMPTY!'));
    });

    test('cycle', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% for x in potabo %} {% cycle 1, 2, 3 %}{% endfor %}', null));

      context.variables['potabo'] = ['a', 4, 4.5];

      expect(await template.render(context), equals(' 1 2 3'));
    });

    test('expressions', () async {
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

      expect(await template.render(context), equals('this so is fun'));
    });

    test('builtins', () async {
      final context = Context.create();

      var template = Template.parse(
          context, Source(null, '{{ "" | default: "default" }} {{ null | default_if_none: "null" }} {{ list | size }} {{ "upper" | upper }} {{ "lower" | lower }} {{ "capfirst" | capfirst }}', null));
      context.variables['null'] = null;
      context.variables['list'] = [1, 2, 3];

      expect(await template.render(context), equals('default null 3 UPPER lower Capfirst'));
    });

    test('filter', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% filter reverse%}nuf{% endfilter %}', null));

      context.filters['reverse'] = (i, a) => reverse(i.toString());

      expect(await template.render(context), equals('fun'));
    });

    test('as', () async {
      final context = Context.create();

      var template = Template.parse(context, Source(null, '{% filter reverse as XX %}nuf{% endfilter %}{{ XX }} {{ XX }}', null));

      context.filters['reverse'] = (i, a) => reverse(i.toString());

      expect(await template.render(context), equals('fun fun'));
    });

    test('if', () async {
      final context = Context.create();

      context.variables['a'] = 'this';
      context.variables['b'] = {'a': 'is'};
      context.variables['d'] = [
        'wat',
        'so',
        'wat',
      ];

      var template = Template.parse(context, Source(null, '{% if a == "this" %}yes{% endif %}', null));
      expect(await template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% else %}yes{% endif %}', null));
      expect(await template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% elseif true %}yes{% else %}no{% endif %}', null));
      expect(await template.render(context), equals('yes'));
      template = Template.parse(context, Source(null, '{% if a != "this" %}no{% elseif 7 > 4 %}yes{% else %}no{% endif %}', null));
      expect(await template.render(context), equals('yes'));
    });

    test('include', () async {
      final context = Context.create();
      final root = TestRoot({
        'name_snippet.html': '{{ greeting }}, {{ person|default:"friend" }}!',
        'simple': '{% include "name_snippet.html" %}',
        'args': '{% include "name_snippet.html" with person="Jane" greeting="Howdy" %}',
        'only': '{% include "name_snippet.html" with greeting="Hi" only %}',
      });

      context.variables['person'] = 'John';
      context.variables['greeting'] = 'Hello';

      var template = Template.parse(context, await root.resolve('simple'));
      expect(await template.render(context), equals('Hello, John!'));
      template = Template.parse(context, await root.resolve('args'));
      expect(await template.render(context), equals('Howdy, Jane!'));
      template = Template.parse(context, await root.resolve('only'));
      expect(await template.render(context), equals('Hi, friend!'));
    });

    test('render', () async {
      final context = Context.create();
      final root = TestRoot({
        'render': '{% render "name.html" %}',
        'render_with_parameters': '{% render "name_age.html", first_name, last_name, age:1 %}',
        'render_with_with': '{% render "name.html" with first_name as name %}',
        'render_with_for': '{% render "name.html" for names as name %}',
        'name_age.html': '{{ first_name }} {{ last_name }}! {{age}}',
        'name.html': '{{ name }}!',
      });

      context.variables['first_name'] = 'John';
      context.variables['last_name'] = 'John';
      context.variables['greeting'] = 'Hello';
      context.variables['names'] = ['john', 'mark', 'mary'];

      var template = Template.parse(context, await root.resolve('render'));
      expect(await template.render(context), equals('!'));

      template = Template.parse(context, await root.resolve('render_with_parameters'));
      expect(await template.render(context), equals('John John! 1'));

      template = Template.parse(context, await root.resolve('render_with_with'));
      expect(await template.render(context), equals('John!'));

      template = Template.parse(context, await root.resolve('render_with_for'));
      expect(await template.render(context), equals(['john', 'mark', 'mary'].map((e) => '$e!').join('')));
    });

    test('extends', () async {
      final context = Context.create();
      final root = TestRoot({
        'base2': 'outer == {% block fun %}base2{% endblock %}',
        'base1': '{% extends base_var %}{% block fun %}base1{% endblock %}',
        'base0': '{% extends "base1" %}{% block fun %}base0{% endblock %}',
      });

      context.variables['base_var'] = 'base2';

      var template = Template.parse(context, await root.resolve('base0'));
      expect(await template.render(context), equals('outer == base0'));
      template = Template.parse(context, await root.resolve('base1'));
      expect(await template.render(context), equals('outer == base1'));
      template = Template.parse(context, await root.resolve('base2'));
      expect(await template.render(context), equals('outer == base2'));
    });
  });

  test('regroup', () async {
    // https://docs.djangoproject.com/en/3.0/ref/templates/builtins/#regroup
    final context = Context.create();

    var template = Template.parse(
        context,
        Source(
            null,
            '{% regroup cities by country to country_list %} ' +
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

    String result = await template.render(context);
    expect(
        result,
        equals(
            ' <ul>  <li>India <ul>   <li> Mumbai: 19,000,000 </li>   <li> Calcutta: 15,000,000 </li>    </ul>  </li>  <li>USA <ul>   <li> New York: 20,000,000 </li>   <li> Chicago: 7,000,000 </li>    </ul>  </li>  <li>Japan <ul>   <li> Tokyo: 33,000,000 </li>    </ul>  </li>  </ul>'));
  });
}
