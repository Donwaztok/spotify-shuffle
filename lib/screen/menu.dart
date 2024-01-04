import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_shuffle/controllers/spotifycontroller.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final spotifyController =
        Provider.of<SpotifyController>(context, listen: false);
    spotifyController.getToken();
    spotifyController.getPlaylists();

    return ListView.builder(
      itemCount: spotifyController.playlists.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: spotifyController.playlists[index].getLargestImage()!.url,
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
                      .deletePlaylist(spotifyController.playlists[index]);
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  // Lógica para reproduzir a playlist
                },
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  spotifyController.createShuffledPlaylistWithSameSongs(
                      spotifyController.playlists[index]);
                },
                icon: const Icon(Icons.shuffle),
              ),
            ],
          ),
        );
      },
    );
  }
}
