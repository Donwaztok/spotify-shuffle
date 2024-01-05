class Playlist {
  bool collaborative;
  String description;
  String href;
  String id;
  List<PlaylistImage> images;
  String name;
  PlaylistOwner owner;
  bool public;
  String snapshotId;
  PlaylistTracks tracks;
  String type;
  String uri;

  Playlist(
    this.collaborative,
    this.description,
    this.href,
    this.id,
    this.images,
    this.name,
    this.owner,
    this.public,
    this.snapshotId,
    this.tracks,
    this.type,
    this.uri,
  );

  static Playlist getPlaylist(dynamic item) {
    List<PlaylistImage> images = [];
    for (var image in item['images']) {
      images.add(
        PlaylistImage(
          image['height'] ?? 0,
          image['url'],
          image['width'] ?? 0,
        ),
      );
    }

    PlaylistOwner owner = PlaylistOwner(
      item['owner']['display_name'],
      PlaylistOwnerExternalUrls(item['owner']['external_urls']['spotify']),
      item['owner']['href'],
      item['owner']['id'],
      item['owner']['type'],
      item['owner']['uri'],
    );

    PlaylistTracks tracks = PlaylistTracks(
      item['tracks']['href'],
      item['tracks']['total'] ?? 0,
    );

    return Playlist(
      item['collaborative'],
      item['description'],
      item['href'],
      item['id'],
      images,
      item['name'],
      owner,
      item['public'],
      item['snapshot_id'],
      tracks,
      item['type'],
      item['uri'],
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
  int height;
  String url;
  int width;

  PlaylistImage(this.height, this.url, this.width);
}

class PlaylistOwner {
  String displayName;
  PlaylistOwnerExternalUrls externalUrls;
  String href;
  String id;
  String type;
  String uri;

  PlaylistOwner(
    this.displayName,
    this.externalUrls,
    this.href,
    this.id,
    this.type,
    this.uri,
  );
}

class PlaylistOwnerExternalUrls {
  String spotify;

  PlaylistOwnerExternalUrls(this.spotify);
}

class PlaylistTracks {
  String href;
  int total;

  PlaylistTracks(this.href, this.total);
}
