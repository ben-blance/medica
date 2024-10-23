import 'package:flutter/material.dart';
import 'package:medika/dashboard.dart';
import 'package:medika/choose.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,

      ),
      home: Choose(),
    );
  }
}

