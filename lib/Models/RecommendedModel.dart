class RecommendedModel {
  bool? success;
  List<Data>? data;

  RecommendedModel({this.success, this.data});

  RecommendedModel.fromJson(Map<String, dynamic> json) {
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
  String? uuid;
  String? title;
  String? slug;
  String? contentType;
  String? thumbnail;
  String? poster;
  String? releaseYear;
  String? imdbRating;
  List<String>? genres;

  Data(
      {this.id,
        this.uuid,
        this.title,
        this.slug,
        this.contentType,
        this.thumbnail,
        this.poster,
        this.releaseYear,
        this.imdbRating,
        this.genres});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    slug = json['slug'];
    contentType = json['content_type'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    releaseYear = json['release_year'];
    imdbRating = json['imdb_rating'];
    genres = json['genres'] != null ? json['genres'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['title'] = title;
    data['slug'] = slug;
    data['content_type'] = contentType;
    data['thumbnail'] = thumbnail;
    data['poster'] = poster;
    data['release_year'] = releaseYear;
    data['imdb_rating'] = imdbRating;
    data['genres'] = genres;
    return data;
  }
}
