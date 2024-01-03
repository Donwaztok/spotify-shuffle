class Playlist {
  final bool collaborative;
  final String description;
  final String href;
  final String id;
  final List<PlaylistImage> images;
  final String name;
  final PlaylistOwner owner;
  final bool public;
  final String snapshotId;
  final PlaylistTracks tracks;
  final String type;
  final String uri;

  Playlist({
    required this.collaborative,
    required this.description,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.owner,
    required this.public,
    required this.snapshotId,
    required this.tracks,
    required this.type,
    required this.uri,
  });

  static Playlist getPlaylist(dynamic item) {
    List<PlaylistImage> images = [];
    for (var image in item['images']) {
      images.add(
        PlaylistImage(
          height: image['height'],
          url: image['url'],
          width: image['width'],
        ),
      );
    }

    PlaylistOwner owner = PlaylistOwner(
      displayName: item['owner']['display_name'],
      externalUrls: PlaylistOwnerExternalUrls(
        spotify: item['owner']['external_urls']['spotify'],
      ),
      href: item['owner']['href'],
      id: item['owner']['id'],
      type: item['owner']['type'],
      uri: item['owner']['uri'],
    );

    PlaylistTracks tracks = PlaylistTracks(
      href: item['tracks']['href'],
      total: item['tracks']['total'],
    );

    return Playlist(
      collaborative: item['collaborative'],
      description: item['description'],
      href: item['href'],
      id: item['id'],
      images: images,
      name: item['name'],
      owner: owner,
      public: item['public'],
      snapshotId: item['snapshot_id'],
      tracks: tracks,
      type: item['type'],
      uri: item['uri'],
    );
  }

  PlaylistImage? getSmallestImage() {
    if (images.isEmpty) {
      return null;
    }

    PlaylistImage smallestImage = images[0];
    for (var image in images) {
      if (image.width < smallestImage.width &&
          image.height < smallestImage.height) {
        smallestImage = image;
      }
    }

    return smallestImage;
  }

  PlaylistImage? getMediumImage() {
    if (images.isEmpty) {
      return null;
    }

    PlaylistImage mediumImage = images[0];
    for (var image in images) {
      if (image.width >= 300 &&
          image.width < 640 &&
          image.height >= 300 &&
          image.height < 640) {
        mediumImage = image;
        break;
      }
    }

    return mediumImage;
  }

  PlaylistImage? getLargestImage() {
    if (images.isEmpty) {
      return null;
    }

    PlaylistImage largestImage = images[0];
    for (var image in images) {
      if (image.width > largestImage.width &&
          image.height > largestImage.height) {
        largestImage = image;
      }
    }

    return largestImage;
  }
}

class PlaylistImage {
  final int height;
  final String url;
  final int width;

  PlaylistImage({
    required this.height,
    required this.url,
    required this.width,
  });
}

class PlaylistOwner {
  final String displayName;
  final PlaylistOwnerExternalUrls externalUrls;
  final String href;
  final String id;
  final String type;
  final String uri;

  PlaylistOwner({
    required this.displayName,
    required this.externalUrls,
    required this.href,
    required this.id,
    required this.type,
    required this.uri,
  });
}

class PlaylistOwnerExternalUrls {
  final String spotify;

  PlaylistOwnerExternalUrls({
    required this.spotify,
  });
}

class PlaylistTracks {
  final String href;
  final int total;

  PlaylistTracks({
    required this.href,
    required this.total,
  });
}
