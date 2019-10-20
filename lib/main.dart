import 'package:adawifi/auth.dart';
import 'package:adawifi/detail.dart';
import 'package:flutter/material.dart';
import 'package:adawifi/home.dart';

void main() => runApp(MyApp());

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
        '/': (context) => Auth(),
        '/home': (context) => MyHomePage(
              title: 'Flutter Adawifi',
            ),
        '/detail': (context) => Detail()
      },
    );
  }
}
