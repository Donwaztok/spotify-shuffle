import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_shuffle/utils/utils.dart';
import 'package:spotify_shuffle/widget/progressbar.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  late Stream<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    setupPlayerState();
  }

  @override
  void dispose() {
    super.dispose();
    SpotifySdk.disconnect();
  }

  void setupPlayerState() async {
    try {
      await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
        redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL'] ?? '',
        scope: 'user-read-playback-position',
      );

      _playerStateSubscription = SpotifySdk.subscribePlayerState();
      _playerStateSubscription.listen((playerState) {
        setState(() {
          _playerState = playerState;
        });
      });
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
          title: SizedBox(
            height: 2,
            child: LinearProgressIndicator(color: Colors.green),
          ),
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
            minVerticalPadding: 0,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://i.scdn.co/image/${_playerState?.track?.imageUri.raw.split(":").last}',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            title: Text(
              _playerState?.track?.name ?? '<Track>',
              style: const TextStyle(
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(
              _playerState?.track?.artist.name ?? '<Artist>',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(_playerState?.isPaused ?? true
                  ? Icons.play_arrow
                  : Icons.pause),
              onPressed: () {
                if (_playerState?.isPaused ?? true) {
                  SpotifySdk.resume();
                } else {
                  SpotifySdk.pause();
                }
              },
            ),
          ),
          ProgressBar(duration: _playerState?.track?.duration ?? 1),
        ],
      ),
    );
  }
}
