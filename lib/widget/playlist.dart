import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify_shuffle/controllers/spotifycontroller.dart';

class PlaylistWidget extends StatefulWidget {
  const PlaylistWidget({super.key});

  @override
  State<PlaylistWidget> createState() => _PlaylistWidget();
}

class _PlaylistWidget extends State<PlaylistWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final spotifyController = SpotifyController();

  @override
  void initState() {
    super.initState();
    spotifyController.getToken().then((value) =>
        spotifyController.getPlaylists().then((value) => setState(() {})));
  }

  Future<void> _refresh() {
    return spotifyController.getPlaylists().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: spotifyController.playlists.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              leading:
                  spotifyController.playlists[index].getLargestImage() != null
                      ? CachedNetworkImage(
                          imageUrl: spotifyController.playlists[index]
                              .getLargestImage()!
                              .url,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : const Icon(Icons.error_outline),
              title: Text(spotifyController.playlists[index].name,
                  style: const TextStyle(
                      overflow: TextOverflow.ellipsis, fontSize: 18)),
              subtitle: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
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
            ),
          );
        },
      ),
    );
  }
}
