import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:liquid_engine/liquid_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('km', 'KH'),
      ],
      path: 'assets/translations',
      startLocale: const Locale('km', 'KH'),
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      title: "test liquid",
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        "/": (_) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("welcome".tr()),
      ),
      body: Center(
        child: Column(
          children: [
            // args
            Text('msg').tr(args: ['Easy localization', 'Dart']),

// namedArgs
            Text('msg_named').tr(namedArgs: {'lang': 'Dart'}),

// args and namedArgs
            Text('msg_mixed').tr(args: ['Easy localization'], namedArgs: {'lang': 'Dart'}),

// gender
            Text('gender').tr(gender: "female"),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _onGenerate,
        child: const Text("generate"),
      ),
    );
  }

  _onGenerate() async {
    const raw = """
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
    {{ "welcome" | tr : "d" }}
    {{ "msg" | tr : "Dart", "Great" }}
    </table>
  </body>
</html>
  """;

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
    print(await template.render(context));
  }
}
