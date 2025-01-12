import 'package:flutter/material.dart';
//import 'package:lost_and_found/Screens/UploadForm.dart';

import 'screens/LoginForm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost and Found',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const LoginForm(),
    );
  }
}
