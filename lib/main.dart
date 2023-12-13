import 'package:flutter/material.dart';
import 'package:spotify_shuffle/screen/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conectar ao Spotify',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const Login(),
    );
  }
}
