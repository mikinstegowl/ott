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
  Access? access;
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
        this.access,
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
    access = json['access'] != null ? Access.fromJson(json['access']) : null;
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
    if (access != null) data['access'] = access!.toJson();
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


/// What the server decided this viewer may do with this title.
///
/// `offers` is the list of ways in: subscribe, rent, buy. The app draws a
/// button per offer rather than assuming a subscription is the only route —
/// a pay-per-view title has no subscribe option at all.
class Access {
  String? type;
  bool? canPlay;
  String? mode;
  String? reason;
  List<Offer> offers = [];
  Purchase? purchase;

  Access({this.type, this.canPlay, this.mode, this.reason, this.purchase});

  Access.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    canPlay = json['can_play'];
    mode = json['mode'];
    reason = json['reason'];
    if (json['offers'] != null) {
      offers = (json['offers'] as List)
          .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    purchase = json['purchase'] != null
        ? Purchase.fromJson(Map<String, dynamic>.from(json['purchase'] as Map))
        : null;
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'can_play': canPlay,
        'mode': mode,
        'reason': reason,
        'offers': offers.map((e) => e.toJson()).toList(),
        if (purchase != null) 'purchase': purchase!.toJson(),
      };

  bool get hasRentOrBuy => offers.any((o) => o.type == 'rent' || o.type == 'buy');
  bool get hasSubscribe => offers.any((o) => o.type == 'subscribe');
  List<Offer> get ppvOffers =>
      offers.where((o) => o.type == 'rent' || o.type == 'buy').toList();
}

/// One way to unlock the title: subscribe, rent or buy.
class Offer {
  String? type;
  String? price;
  String? currency;
  String? displayPrice;
  int? watchHours;
  int? startDays;
  String? appleProductId;
  String? googleProductId;

  Offer({this.type, this.displayPrice});

  Offer.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price']?.toString();
    currency = json['currency'];
    displayPrice = json['display_price'];
    watchHours = json['watch_hours'];
    startDays = json['start_days'];
    appleProductId = json['apple_product_id'];
    googleProductId = json['google_product_id'];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'price': price,
        'currency': currency,
        'display_price': displayPrice,
        'watch_hours': watchHours,
        'start_days': startDays,
        'apple_product_id': appleProductId,
        'google_product_id': googleProductId,
      };

  /// "Rent \$1.99" / "Buy \$4.99"
  String get label =>
      '${type == 'rent' ? 'Rent' : 'Buy'} ${displayPrice ?? ''}'.trim();
}

/// A rental or purchase this viewer already holds.
class Purchase {
  String? type;
  String? startsAt;
  String? startDeadline;
  String? expiresAt;
  int? secondsRemaining;

  Purchase({this.type});

  Purchase.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    startsAt = json['starts_at'];
    startDeadline = json['start_deadline'];
    expiresAt = json['expires_at'];
    secondsRemaining = json['seconds_remaining'];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'starts_at': startsAt,
        'start_deadline': startDeadline,
        'expires_at': expiresAt,
        'seconds_remaining': secondsRemaining,
      };
}
