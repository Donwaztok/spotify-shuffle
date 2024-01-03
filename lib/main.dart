import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_shuffle/screen/menu.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
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
      initialRoute: '/menu',
      routes: {
        '/menu': (context) => const Menu(),
      },
    );
  }
}
