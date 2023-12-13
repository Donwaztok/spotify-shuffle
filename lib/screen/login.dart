import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login no Spotify'),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                child: const Text('Conectar'),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });

                  try {
                    var result = await SpotifySdk.connectToSpotifyRemote(
                      clientId: 'seu_id_de_cliente',
                      redirectUrl: 'sua_url_de_redirecionamento',
                    );

                    if (result) {
                      _showError('Conectado ao Spotify com sucesso.');
                    } else {
                      _showError('Falha ao conectar ao Spotify.');
                    }
                  } catch (e) {
                    if (e is PlatformException) {
                      var platformException = e;
                      _showError(platformException.message ?? e.toString());
                    } else {
                      _showError(e.toString());
                    }
                  }

                  setState(() {
                    _loading = false;
                  });
                },
              ),
      ),
    );
  }
}
