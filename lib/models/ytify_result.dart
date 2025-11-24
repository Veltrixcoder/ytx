class YtifyResult {
  final String title;
  final List<YtifyThumbnail> thumbnails;
  final String resultType;
  final bool isExplicit;
  final String? videoId;
  final String? browseId;
  final String? duration;
  final int? durationSeconds;
  final String? videoType;
  final List<YtifyArtist>? artists;
  final YtifyAlbum? album;
  final String? views;

  YtifyResult({
    required this.title,
    required this.thumbnails,
    required this.resultType,
    required this.isExplicit,
    this.videoId,
    this.browseId,
    this.duration,
    this.durationSeconds,
    this.videoType,
    this.artists,
    this.album,
    this.views,
  });

  factory YtifyResult.fromJson(Map<String, dynamic> json) {
    return YtifyResult(
      title: json['title'] ?? '',
      thumbnails: (json['thumbnails'] as List?)
              ?.map((t) => YtifyThumbnail.fromJson(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
      resultType: json['resultType'] ?? '',
      isExplicit: json['isExplicit'] ?? false,
      videoId: json['videoId'],
      browseId: json['browseId'],
      duration: json['duration'],
      durationSeconds: json['duration_seconds'],
      videoType: json['videoType'],
      artists: (json['artists'] as List?)
          ?.map((a) => YtifyArtist.fromJson(Map<String, dynamic>.from(a)))
          .toList(),
      album: json['album'] != null ? YtifyAlbum.fromJson(Map<String, dynamic>.from(json['album'])) : null,
      views: json['views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnails': thumbnails.map((t) => t.toJson()).toList(),
      'resultType': resultType,
      'isExplicit': isExplicit,
      'videoId': videoId,
      'browseId': browseId,
      'duration': duration,
      'duration_seconds': durationSeconds,
      'videoType': videoType,
      'artists': artists?.map((a) => a.toJson()).toList(),
      'album': album?.toJson(),
      'views': views,
    };
  }
}

class YtifyThumbnail {
  final String url;
  final int width;
  final int height;

  YtifyThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory YtifyThumbnail.fromJson(Map<String, dynamic> json) {
    return YtifyThumbnail(
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
    };
  }
}

class YtifyArtist {
  final String name;
  final String? id;

  YtifyArtist({required this.name, this.id});

  factory YtifyArtist.fromJson(Map<String, dynamic> json) {
    return YtifyArtist(
      name: json['name'] ?? '',
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

class YtifyAlbum {
  final String name;
  final String id;

  YtifyAlbum({required this.name, required this.id});

  factory YtifyAlbum.fromJson(Map<String, dynamic> json) {
    return YtifyAlbum(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
