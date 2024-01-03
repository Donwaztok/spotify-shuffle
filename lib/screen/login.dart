import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;

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

  Future<void> login() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

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

      // var result = await SpotifySdk.connectToSpotifyRemote(
      //   clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
      //   redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
      //   accessToken: token,
      // );

      // if (!result) {
      //   _showError('Falha ao conectar ao Spotify.');
      // }
    } catch (e) {
      if (e is PlatformException) {
        var platformException = e;
        _showError(platformException.message ?? e.toString());
      } else {
        _showError(e.toString());
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }

    String? lastRoute = prefs.getString('lastRoute');
    if (lastRoute != null) {
      Navigator.pushNamedAndRemoveUntil(context, lastRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    login();
    return Scaffold(
      appBar: AppBar(
        title: const Text('login on Spotify'),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : const Text('Loading...'),
      ),
    );
  }
}
