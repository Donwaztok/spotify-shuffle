import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_shuffle/models/playlists.dart';
import 'package:spotify_shuffle/utils/utils.dart';

class SpotifyController {
  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

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
        Utils.showError(platformException.message ?? e.toString());
      } else {
        Utils.showError(e.toString());
      }
    }
    return prefs.getString('accessToken');
  }

  Future<List<Playlist>> getPlaylists() async {
    getToken();
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
    // Obtenha a lista de músicas da playlist original
    List<String> trackUris = await getTracksFromPlaylist(playlist.id);

    // Embaralhe as músicas
    trackUris.shuffle();

    // Crie uma nova playlist com o mesmo nome da original
    String newPlaylistId = await createPlaylist(playlist);

    // Adicione as músicas embaralhadas na nova playlist
    await addTracksToPlaylist(newPlaylistId, trackUris);
  }

// Função para obter a lista de músicas da playlist original
  Future<List<String>> getTracksFromPlaylist(String playlistId) async {
    // Faça a chamada para a API do Spotify para obter as músicas da playlist
    // Use a biblioteca http para fazer a requisição
    // Você pode usar o pacote 'http' do pub.dev: https://pub.dev/packages/http
    // Exemplo de implementação:
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer ${prefs.getString('accessToken')}',
      },
    );

    // Verifique se a resposta é bem-sucedida (código de status 200)
    if (response.statusCode == 200) {
      // Decodifique a resposta JSON
      final data = jsonDecode(response.body);
      List<String> trackUris = [];
      for (var item in data['items']) {
        // Adicione as URIs das músicas à lista
        trackUris.add(item['track']['uri']);
      }
      return trackUris;
    } else {
      // Lide com erros ao obter as músicas da playlist original
      // Pode exibir uma mensagem de erro ou realizar outra ação apropriada
      Utils.showError(
          '[${response.statusCode}] ${response.reasonPhrase} on Tracks from Playlist');
      return [];
    }
  }

  Future<String> createPlaylist(Playlist playlist) async {
    // Certifique-se de que o usuário já está autenticado usando o método getAccessToken
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      // Faça a chamada para a API do Spotify para criar a nova playlist
      final response = await http.post(
        Uri.parse(
            'https://api.spotify.com/v1/users/${playlist.owner.id}/playlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': "[Shuffled] ${playlist.name}",
          'description': 'Embaralhadas por Spotify Shuffle',
          'public': playlist.public,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        Utils.showError(
            '[${response.statusCode}] ${response.reasonPhrase} on Create Playlist');
        // Lide com erros ao criar a nova playlist
        // Pode exibir uma mensagem de erro ou realizar outra ação apropriada
        return '';
      }
    } else {
      // Lide com o caso em que o usuário não está autenticado
      // Pode exibir uma mensagem de erro ou realizar outra ação apropriada
      return '';
    }
  }

// Função para adicionar as músicas embaralhadas na nova playlist
  Future<void> addTracksToPlaylist(
      String playlistId, List<String> trackUris) async {
    // Make sure the user is authenticated using the getAccessToken method
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      // Make the API call to add tracks to the playlist
      final response = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': trackUris,
        }),
      );

      if (response.statusCode == 201) {
        // Tracks were successfully added to the playlist
        Utils.showError('Tracks were successfully added to the playlist');
        // Update playlists
        await getPlaylists();
      } else {
        // Handle errors when adding tracks to the playlist
        // You can display an error message or take other appropriate action
        Utils.showError(
            '[${response.statusCode}] ${response.reasonPhrase} on Add Tracks to Playlist');
      }
    } else {
      // Handle the case where the user is not authenticated
      // You can display an error message or take other appropriate action
    }
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.delete(
      Uri.parse(
          'https://api.spotify.com/v1/playlists/${playlist.id}/followers'),
      headers: {
        'Authorization': 'Bearer ${prefs.getString('accessToken')}',
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
}
