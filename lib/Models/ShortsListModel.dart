class ShortsListModel {
  bool? success;
  List<Data>? data;

  ShortsListModel({this.success, this.data});

  ShortsListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? itemType;
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

  Data(
      {this.id,
        this.itemType,
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
        this.genres});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemType = json['item_type'];
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
    genres = json['genres'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_type'] = itemType;
    data['uuid'] = uuid;
    data['title'] = title;
    data['slug'] = slug;
    data['short_description'] = shortDescription;
    data['vertical_poster'] = verticalPoster;
    data['cover_image'] = coverImage;
    data['total_episodes'] = totalEpisodes;
    data['free_episode_count'] = freeEpisodeCount;
    data['view_count'] = viewCount;
    data['is_trending'] = isTrending;
    data['is_featured'] = isFeatured;
    data['genres'] = genres;
    return data;
  }
}
