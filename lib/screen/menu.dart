import 'package:flutter/material.dart';
import 'package:spotify_shuffle/widget/player.dart';
import 'package:spotify_shuffle/widget/playlist.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _Menu();
}

class _Menu extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Shuffle'),
      ),
      body: const Column(
        children: <Widget>[
          // Widget de reprodução de música
          PlayerWidget(),
          // Lista de playlists
          Expanded(
            child: PlaylistWidget(),
          ),
        ],
      ),
    );
  }
}
