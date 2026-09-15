import 'package:ottapp/Models/InfoModel.dart';

class ShortDramaModel {
  bool? success;
  ShortDramaData? data;

  ShortDramaModel({this.success, this.data});

  ShortDramaModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? ShortDramaData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class ShortDramaData {
  int? id;
  String? uuid;
  String? title;
  String? slug;
  String? shortDescription;
  String? verticalPoster;
  String? coverImage;
  int? totalEpisodes;
  int? freeEpisodeCount;
  int? viewCount;
  bool? isTrending;
  bool? isFeatured;
  List<String>? genres;
  String? description;
  List<String>? tags;
  int? likeCount;
  int? bookmarkCount;
  bool? isLiked;
  bool? isBookmarked;
  bool? inWatchlist;
  dynamic watchProgress;
  List<ShortEpisodeItem>? episodes;
  Share? share;

  ShortDramaData({
    this.id,
    this.uuid,
    this.title,
    this.slug,
    this.shortDescription,
    this.verticalPoster,
    this.coverImage,
    this.totalEpisodes,
    this.freeEpisodeCount,
    this.viewCount,
    this.isTrending,
    this.isFeatured,
    this.genres,
    this.description,
    this.tags,
    this.likeCount,
    this.bookmarkCount,
    this.isLiked,
    this.isBookmarked,
    this.inWatchlist,
    this.watchProgress,
    this.episodes,
    this.share,
  });

  ShortDramaData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    slug = json['slug'];
    shortDescription = json['short_description'];
    verticalPoster = json['vertical_poster'];
    coverImage = json['cover_image'];
    totalEpisodes = json['total_episodes'];
    freeEpisodeCount = json['free_episode_count'];
    viewCount = json['view_count'];
    isTrending = json['is_trending'];
    isFeatured = json['is_featured'];
    if (json['genres'] != null) {
      genres = List<String>.from(json['genres'] ?? []);
    }
    description = json['description'];
    if (json['tags'] != null) {
      tags = List<String>.from(json['tags'] ?? []);
    }
    likeCount = json['like_count'];
    bookmarkCount = json['bookmark_count'];
    isLiked = json['is_liked'];
    isBookmarked = json['is_bookmarked'];
    inWatchlist = json['in_watchlist'];
    watchProgress = json['watch_progress'];
    share = json['share'] != null && json['share'] is Map<String, dynamic>
        ? Share.fromJson(json['share'])
        : null;
    if (json['episodes'] != null && json['episodes'] is List) {
      episodes = <ShortEpisodeItem>[];
      for (var v in (json['episodes'] as List)) {
        if (v is Map<String, dynamic>) {
          episodes?.add(ShortEpisodeItem.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['uuid'] = uuid;
    map['title'] = title;
    map['slug'] = slug;
    map['short_description'] = shortDescription;
    map['vertical_poster'] = verticalPoster;
    map['cover_image'] = coverImage;
    map['total_episodes'] = totalEpisodes;
    map['free_episode_count'] = freeEpisodeCount;
    map['view_count'] = viewCount;
    map['is_trending'] = isTrending;
    map['is_featured'] = isFeatured;
    map['genres'] = genres;
    map['description'] = description;
    map['tags'] = tags;
    map['like_count'] = likeCount;
    map['bookmark_count'] = bookmarkCount;
    map['is_liked'] = isLiked;
    map['is_bookmarked'] = isBookmarked;
    map['in_watchlist'] = inWatchlist;
    map['watch_progress'] = watchProgress;
    if (share != null) {
      map['share'] = share?.toJson();
    }
    if (episodes != null) {
      map['episodes'] = episodes?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ShortEpisodeItem {
  int? id;
  String? uuid;
  int? episodeNumber;
  String? title;
  String? description;
  String? thumbnail;
  int? durationSeconds;
  bool? isFree;
  bool? isLocked;
  bool? hasVideo;
  String? videoSource;
  bool? isLiked;
  int? likeCount;

  ShortEpisodeItem({
    this.id,
    this.uuid,
    this.episodeNumber,
    this.title,
    this.description,
    this.thumbnail,
    this.durationSeconds,
    this.isFree,
    this.isLocked,
    this.hasVideo,
    this.videoSource,
    this.isLiked,
    this.likeCount,
  });

  ShortEpisodeItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    episodeNumber = json['episode_number'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    durationSeconds = json['duration_seconds'];
    isFree = json['is_free'];
    isLocked = json['is_locked'];
    hasVideo = json['has_video'];
    videoSource = json['video_source'];
    isLiked = json['is_liked'];
    likeCount = json['like_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['uuid'] = uuid;
    map['episode_number'] = episodeNumber;
    map['title'] = title;
    map['description'] = description;
    map['thumbnail'] = thumbnail;
    map['duration_seconds'] = durationSeconds;
    map['is_free'] = isFree;
    map['is_locked'] = isLocked;
    map['has_video'] = hasVideo;
    map['video_source'] = videoSource;
    map['is_liked'] = isLiked;
    map['like_count'] = likeCount;
    return map;
  }
}
