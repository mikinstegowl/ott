class EpisodeModel {
  bool? success;
  EpisodeData? data;

  EpisodeModel({this.success, this.data});

  EpisodeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? EpisodeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class EpisodeData {
  List<Episodes>? episodes;

  EpisodeData({this.episodes});

  EpisodeData.fromJson(Map<String, dynamic> json) {
    if (json['episodes'] != null) {
      episodes = <Episodes>[];
      json['episodes'].forEach((v) {
        episodes!.add(Episodes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (episodes != null) {
      data['episodes'] = episodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Episodes {
  int? id;
  String? uuid;
  String? title;
  String? slug;
  int? episodeNumber;
  int? durationMinutes;
  String? releaseDate;
  String? thumbnail;
  String? poster;
  String? videoUrl;
  bool? isFree;
  String? status;

  Episodes(
      {this.id,
      this.uuid,
      this.title,
      this.slug,
      this.episodeNumber,
      this.durationMinutes,
      this.releaseDate,
      this.thumbnail,
      this.poster,
      this.videoUrl,
      this.isFree,
      this.status});

  Episodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    slug = json['slug'];
    episodeNumber = json['episode_number'];
    durationMinutes = json['duration_minutes'];
    releaseDate = json['release_date'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    videoUrl = json['video_url'];
    isFree = json['is_free'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['title'] = title;
    data['slug'] = slug;
    data['episode_number'] = episodeNumber;
    data['duration_minutes'] = durationMinutes;
    data['release_date'] = releaseDate;
    data['thumbnail'] = thumbnail;
    data['poster'] = poster;
    data['video_url'] = videoUrl;
    data['is_free'] = isFree;
    data['status'] = status;
    return data;
  }
}
