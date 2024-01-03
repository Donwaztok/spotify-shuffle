import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_shuffle/models/playlists.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  List<Playlist> playlists = [];

  Future<void> getPlaylists() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('accessToken')}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        playlists.clear();
        for (var item in data['items']) {
          playlists.add(Playlist.getPlaylist(item));
        }
      } else {
        _showError('[${response.statusCode}] ${response.reasonPhrase}');
      }
    } catch (e) {
      _showError('Erro ao obter as playlists: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
        redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing',
      );

      prefs.setString('accessToken', token);
    } catch (e) {
      if (e is PlatformException) {
        var platformException = e;
        _showError(platformException.message ?? e.toString());
      } else {
        _showError(e.toString());
      }
    }
    return prefs.getString('accessToken');
  }

  void _showError(String error) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(error),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: FutureBuilder<String?>(
        future: getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Erro ao obter o token');
          } else {
            return FutureBuilder(
              future: getPlaylists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Erro ao obter as playlists');
                } else {
                  return ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: playlists[index].getLargestImage()!.url,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(playlists[index].name,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                playlists[index].collaborative
                                    ? const Text('Colaborativa',
                                        style: TextStyle(fontSize: 12))
                                    : const SizedBox.shrink(),
                                playlists[index].public
                                    ? const Text('Pública',
                                        style: TextStyle(fontSize: 12))
                                    : const SizedBox.shrink(),
                              ],
                            ),
                            Text(playlists[index].owner.displayName,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Lógica para reproduzir a playlist
                              },
                              icon: const Icon(Icons.play_arrow),
                            ),
                            IconButton(
                              onPressed: () {
                                // Lógica para embaralhar a playlist
                              },
                              icon: const Icon(Icons.shuffle),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
