import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_shuffle/controllers/spotifycontroller.dart';
import 'package:spotify_shuffle/screen/menu.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Configurações do Scaffold
      body: ChangeNotifierProvider(
        create: (_) => SpotifyController(),
        builder: (context, child) => const Menu(),
      ),
    );
  }
}
