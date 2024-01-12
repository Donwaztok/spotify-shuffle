import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_shuffle/models/playlists.dart';
import 'package:spotify_shuffle/utils/utils.dart';

class SpotifyController {
  final List<Playlist> _playlists = [];
  String token = '';

  List<Playlist> get playlists => _playlists;

  Future<void> getToken() async {
    try {
      token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
        redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public, '
            'playlist-modify-private, '
            'user-read-currently-playing',
      );
    } catch (e) {
      if (e is PlatformException) {
        var platformException = e;
        Utils.showError(platformException.message ?? e.toString());
      } else {
        Utils.showError(e.toString());
      }
    }
  }

  Future<List<Playlist>> getPlaylists() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _playlists.clear();
        for (var item in data['items']) {
          _playlists.add(Playlist.getPlaylist(item));
        }
      } else {
        Utils.showError(
            '[${response.statusCode}] ${response.reasonPhrase} on get Playlists');
      }
    } catch (e) {
      Utils.showError('Erro ao obter as playlists: $e');
    }
    return [];
  }

  Future<void> createShuffledPlaylistWithSameSongs(Playlist playlist) async {
    List<String> trackUris = await getTracksFromPlaylist(playlist.id);
    trackUris.shuffle();

    String newPlaylistId = await createPlaylist(playlist);

    if (newPlaylistId != '') {
      await addTracksToPlaylist(newPlaylistId, trackUris);
    }
  }

  Future<List<String>> getTracksFromPlaylist(String playlistId) async {
    int offset = 0;
    List<String> trackUris = [];

    while (true) {
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/playlists/$playlistId/tracks?offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data['items']) {
          trackUris.add(item['track']['uri']);
        }

        if (data['items'].length < 100) {
          break;
        }

        offset += 100;
      } else {
        Utils.showError(
            '[${response.statusCode}] ${response.reasonPhrase} on Tracks from Playlist');
        break;
      }
    }
    return trackUris;
  }

  Future<String> createPlaylist(Playlist playlist) async {
    final response = await http.post(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': "[Shuffled] ${playlist.name}",
        'description': 'Embaralhadas por Spotify Shuffle',
        'public': playlist.public,
        'collaborative': playlist.collaborative,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      Utils.showError(
          '[${response.statusCode}] ${response.reasonPhrase} on Create Playlist');
      return '';
    }
  }

  Future<void> addTracksToPlaylist(
      String playlistId, List<String> trackUris) async {
    const int maxTracksPerRequest = 100;

    for (var i = 0; i < trackUris.length; i += maxTracksPerRequest) {
      var end = (i + maxTracksPerRequest < trackUris.length)
          ? i + maxTracksPerRequest
          : trackUris.length;
      var sublist = trackUris.sublist(i, end);

      final response = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': sublist,
        }),
      );

      if (response.statusCode == 201) {
        Utils.showError("Added Tracks $end/${trackUris.length}");
      } else {
        Utils.showError(
            '[${response.statusCode}] ${response.reasonPhrase} on Add Tracks to Playlist');
      }
    }
    await getPlaylists();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    final response = await http.delete(
      Uri.parse(
          'https://api.spotify.com/v1/playlists/${playlist.id}/followers'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Utils.showError('Playlist deleted successfully');
      await getPlaylists();
    } else {
      Utils.showError(
          '[${response.statusCode}] ${response.reasonPhrase} on Delete Playlist');
    }
  }

  Future<void> playPlaylist(Playlist playlist) async {
    SpotifySdk.play(spotifyUri: playlist.uri);
    var connectionStatus = await SpotifySdk.connectToSpotifyRemote(
      clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
      redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
    );

    if (connectionStatus) {
      await SpotifySdk.setShuffle(shuffle: false);
      await SpotifySdk.play(spotifyUri: playlist.uri);
    } else {}
  }
}
