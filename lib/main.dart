import 'package:flutter/material.dart';
import 'package:medika/dashboard.dart';
import 'package:medika/choose.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://svpjbgozbutsvpmlecyu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2cGpiZ296YnV0c3ZwbWxlY3l1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk2MTk2NzcsImV4cCI6MjA0NTE5NTY3N30.TnjKwHmST74CME98shR4AibUXIs1RXZNCGTKLfVJd0Y',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

