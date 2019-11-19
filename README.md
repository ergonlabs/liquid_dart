A dart port of the liquid / django template engine. 

Created under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:liquid_engine/liquid_engine.dart';

main() {
  final raw = '''
<html>
  <title>{{ title | default: 'Liquid Example'}}</title>
  <body>
    <table>
    {% for user in users %}
      <tr>
        <td>{{ user.name }}</td>
        <td>{{ user.email }}</td>
        <td>{{ user.roles | join: ', ' | default: 'none' }}</td>
      </tr>
    {% endfor %}
    </table>
  </body>
</html>
  ''';

  final context = Context.create();

  context.variables['users'] = [
    {
      'name': 'Standard User',
      'email': 'standard@test.com',
      'roles': [],
    },
    {
      'name': 'Admin Administrator',
      'email': 'admin@test.com',
      'roles': ['admin', 'super-admin'],
    },
  ];

  final template = Template.parse(context, Source.fromString(raw));
  print(template.render(context));
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ergonlabs/liquid_dart/issues
