import 'package:adawifi/auth.dart';
import 'package:adawifi/detail.dart';
import 'package:flutter/material.dart';
import 'package:adawifi/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Adawifi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SignIn(),
        '/home': (context) => MyHomePage(
              title: 'Flutter Adawifi',
            ),
        '/detail': (context) => Detail()
      },
    );
  }
}
