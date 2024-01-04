import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify_shuffle/controllers/spotifycontroller.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _Menu();
}

class _Menu extends State<Menu> {
  final spotifyController = SpotifyController();

  @override
  void initState() {
    super.initState();
    spotifyController.getPlaylists().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Shuffle'),
      ),
      body: ListView.builder(
        itemCount: spotifyController.playlists.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl:
                  spotifyController.playlists[index].getLargestImage()!.url,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            title: Text(spotifyController.playlists[index].name,
                style: const TextStyle(overflow: TextOverflow.ellipsis)),
            subtitle: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                            "${spotifyController.playlists[index].tracks.total} tracks",
                            style: const TextStyle(fontSize: 12)),
                        spotifyController.playlists[index].public
                            ? const Text(' | Pública',
                                style: TextStyle(fontSize: 12))
                            : const SizedBox.shrink(),
                        spotifyController.playlists[index].collaborative
                            ? const Text(' | Colaborativa',
                                style: TextStyle(fontSize: 12))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    Text(spotifyController.playlists[index].owner.displayName,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
                IconButton(
                  onPressed: () {
                    spotifyController
                        .deletePlaylist(spotifyController.playlists[index])
                        .then((value) => setState(() {}));
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    spotifyController
                        .playPlaylist(spotifyController.playlists[index]);
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    spotifyController
                        .createShuffledPlaylistWithSameSongs(
                            spotifyController.playlists[index])
                        .then((value) => setState(() {}));
                  },
                  icon: const Icon(Icons.shuffle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
