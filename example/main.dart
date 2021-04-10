import 'package:liquid_engine/liquid_engine.dart';

void main() {
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
