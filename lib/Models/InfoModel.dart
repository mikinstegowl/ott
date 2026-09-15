class InfoModel {
  bool? success;
  Data? data;

  InfoModel({this.success, this.data});

  InfoModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? id;
  String? uuid;
  String? title;
  String? slug;
  String? contentType;
  String? contentTypeName;
  String? description;
  String? shortDescription;
  dynamic durationMinutes;
  String? releaseYear;
  String? releaseDate;
  String? rating;
  String? imdbRating;
  String? platformRating;
  String? country;
  bool? isFree;
  bool? isFeatured;
  String? status;
  int? viewCount;
  String? thumbnail;
  String? poster;
  String? banner;
  dynamic trailer;
  dynamic trailerUrl;
  bool? hasVideo;
  String? videoSource;
  Language? language;
  List<Genres>? genres;
  List<dynamic>? tags;
  List<dynamic>? cast;
  List<dynamic>? directors;
  List<Seasons>? seasons;
  bool? inWatchlist;
  dynamic watchProgress;
  Meta? meta;
  Share? share;

  Data(
      {this.id,
        this.uuid,
        this.title,
        this.slug,
        this.contentType,
        this.contentTypeName,
        this.description,
        this.shortDescription,
        this.durationMinutes,
        this.releaseYear,
        this.releaseDate,
        this.rating,
        this.imdbRating,
        this.platformRating,
        this.country,
        this.isFree,
        this.isFeatured,
        this.status,
        this.viewCount,
        this.thumbnail,
        this.poster,
        this.banner,
        this.trailer,
        this.trailerUrl,
        this.hasVideo,
        this.videoSource,
        this.language,
        this.genres,
        this.tags,
        this.cast,
        this.directors,
        this.seasons,
        this.inWatchlist,
        this.watchProgress,
        this.meta,
        this.share});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    slug = json['slug'];
    contentType = json['content_type'];
    contentTypeName = json['content_type_name'];
    description = json['description'];
    shortDescription = json['short_description'];
    durationMinutes = json['duration_minutes'];
    releaseYear = json['release_year'];
    releaseDate = json['release_date'];
    rating = json['rating'];
    imdbRating = json['imdb_rating'];
    platformRating = json['platform_rating'];
    country = json['country'];
    isFree = json['is_free'];
    isFeatured = json['is_featured'];
    status = json['status'];
    viewCount = json['view_count'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    banner = json['banner'];
    trailer = json['trailer'];
    trailerUrl = json['trailer_url'];
    hasVideo = json['has_video'];
    videoSource = json['video_source'];
    language = json['language'] != null
        ? Language.fromJson(json['language'])
        : null;
    if (json['genres'] != null) {
      genres = <Genres>[];
      json['genres'].forEach((v) {
        genres!.add(Genres.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = List<dynamic>.from(json['tags']);
    }
    if (json['cast'] != null) {
      cast = List<dynamic>.from(json['cast']);
    }
    if (json['directors'] != null) {
      directors = List<dynamic>.from(json['directors']);
    }
    if (json['seasons'] != null) {
      seasons = <Seasons>[];
      json['seasons'].forEach((v) {
        seasons!.add(Seasons.fromJson(v));
      });
    }
    inWatchlist = json['in_watchlist'];
    watchProgress = json['watch_progress'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    share = json['share'] != null ? Share.fromJson(json['share']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['title'] = title;
    data['slug'] = slug;
    data['content_type'] = contentType;
    data['content_type_name'] = contentTypeName;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['duration_minutes'] = durationMinutes;
    data['release_year'] = releaseYear;
    data['release_date'] = releaseDate;
    data['rating'] = rating;
    data['imdb_rating'] = imdbRating;
    data['platform_rating'] = platformRating;
    data['country'] = country;
    data['is_free'] = isFree;
    data['is_featured'] = isFeatured;
    data['status'] = status;
    data['view_count'] = viewCount;
    data['thumbnail'] = thumbnail;
    data['poster'] = poster;
    data['banner'] = banner;
    data['trailer'] = trailer;
    data['trailer_url'] = trailerUrl;
    data['has_video'] = hasVideo;
    data['video_source'] = videoSource;
    if (language != null) {
      data['language'] = language!.toJson();
    }
    if (genres != null) {
      data['genres'] = genres!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags;
    }
    if (cast != null) {
      data['cast'] = cast;
    }
    if (directors != null) {
      data['directors'] = directors;
    }
    if (seasons != null) {
      data['seasons'] = seasons!.map((v) => v.toJson()).toList();
    }
    data['in_watchlist'] = inWatchlist;
    data['watch_progress'] = watchProgress;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (share != null) {
      data['share'] = share!.toJson();
    }
    return data;
  }
}

class Language {
  String? code;
  String? name;

  Language({this.code, this.name});

  Language.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}

class Genres {
  int? id;
  String? name;
  String? slug;

  Genres({this.id, this.name, this.slug});

  Genres.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}

class Seasons {
  int? id;
  int? seasonNumber;
  String? title;
  int? episodeCount;
  String? releaseYear;

  Seasons(
      {this.id,
        this.seasonNumber,
        this.title,
        this.episodeCount,
        this.releaseYear});

  Seasons.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seasonNumber = json['season_number'];
    title = json['title'];
    episodeCount = json['episode_count'];
    releaseYear = json['release_year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['season_number'] = seasonNumber;
    data['title'] = title;
    data['episode_count'] = episodeCount;
    data['release_year'] = releaseYear;
    return data;
  }
}

class Meta {
  String? title;
  String? description;

  Meta({this.title, this.description});

  Meta.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

class Share {
  String? url;
  String? title;
  String? description;
  String? image;

  Share({this.url, this.title, this.description, this.image});

  Share.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    return data;
  }
}
