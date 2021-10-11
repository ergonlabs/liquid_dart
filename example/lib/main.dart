import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:liquid_engine/liquid_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('km', 'KH')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      title: "test liquid",
      routes: {
        "/": (_) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("liquid flutter"),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: _onGenerate,
            child: Text("generate"),
          ),
        ),
      ),
    );
  }

  _onGenerate() {
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
}
