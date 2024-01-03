import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  List<String> playlists = [];

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
        playlists = List<String>.from(
            data['items'].map((playlist) => playlist['name'].toString()));
      }
    } catch (e) {
      _showError('Erro ao obter as playlists: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> redirectToLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'lastRoute', ModalRoute.of(context)!.settings.name ?? '/Menu');
    Navigator.pushNamed(context, '/login');
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
          } else if (snapshot.data == null) {
            redirectToLogin();
            return Container();
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
                        title: Text(playlists[index]),
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
