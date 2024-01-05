import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_shuffle/utils/utils.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;

  @override
  void initState() {
    super.initState();
  }

  void setupPlayerState() async {
    try {
      // await SpotifySdk.connectToSpotifyRemote(
      //   clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
      //   redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
      // );

      // var playerStateSubscription = SpotifySdk.subscribePlayerState();
      // playerStateSubscription.listen((playerState) {
      //   setState(() {
      //     _playerState = playerState;
      //   });
      // });
    } catch (e) {
      Utils.showError((e as PlatformException).message ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_playerState == null) {
      return Card(
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: const ListTile(
          title:
              SizedBox(height: 2, width: 5, child: LinearProgressIndicator()),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.album),
            title: const Text('Música'),
            subtitle: Slider(
              value: 0,
              onChanged: (newRating) {},
              min: 0,
              max: 100,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {},
            ),
          ),
          Text('Track: ${_playerState?.track?.name ?? 'None'}'),
          Text('Artist: ${_playerState?.track?.artist.name ?? 'None'}'),
          Text('Duration: ${_playerState?.track?.duration ?? 'None'}'),
          // Adicione mais informações conforme necessário
        ],
      ),
    );
  }
}
