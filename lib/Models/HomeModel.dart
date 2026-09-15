class HomeModel {
  bool? success;
  Data? data;

  HomeModel({this.success, this.data});

  HomeModel.fromJson(Map<String, dynamic> json) {
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
  Page? page;
  List<Sections>? sections;
  SectionPagination? sectionPagination;

  Data({this.page, this.sections, this.sectionPagination});

  Data.fromJson(Map<String, dynamic> json) {
    page = json['page'] != null ? Page.fromJson(json['page']) : null;
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
    sectionPagination = json['section_pagination'] != null
        ? SectionPagination.fromJson(json['section_pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (page != null) {
      data['page'] = page!.toJson();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    if (sectionPagination != null) {
      data['section_pagination'] = sectionPagination!.toJson();
    }
    return data;
  }
}

class Page {
  int? id;
  String? title;
  String? slug;
  String? pageType;
  Meta? meta;

  Page({this.id, this.title, this.slug, this.pageType, this.meta});

  Page.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    pageType = json['page_type'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['page_type'] = pageType;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Meta {
  String? title;
  String? description;
  String? image;

  Meta({this.title, this.description, this.image});

  Meta.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    return data;
  }
}

class Sections {
  int? id;
  String? title;
  String? slug;
  String? layoutType;
  String? sourceType;
  String? sliderStyle;
  String? backgroundColor;
  bool? hasMore;
  List<Items>? items;

  Sections(
      {this.id,
        this.title,
        this.slug,
        this.layoutType,
        this.sourceType,
        this.sliderStyle,
        this.backgroundColor,
        this.hasMore,
        this.items});

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    layoutType = json['layout_type'];
    sourceType = json['source_type'];
    sliderStyle = json['slider_style'];
    backgroundColor = json['background_color'];
    hasMore = json['has_more'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['layout_type'] = layoutType;
    data['source_type'] = sourceType;
    data['slider_style'] = sliderStyle;
    data['background_color'] = backgroundColor;
    data['has_more'] = hasMore;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  int? contentId;
  String? item_type;
  String? contentUuid;
  String? title;
  String? subtitle;
  String? backgroundImage;
  String? poster;
  String? thumbnail;
  String? ctaText;
  String? ctaUrl;
  String? contentType;
  String? rating;
  int? durationMinutes;
  String? releaseYear;
  String? imdbRating;
  List<String>? genres;
  Trailer? trailer;
  String? uuid;
  String? slug;
  String? banner;
  String? shortDescription;
  bool? isFree;
  int? rank;
  WatchProgress? watchProgress;
  String? url;
  String? image;
  String? altText;
  int? total_episodes;

  Items(
      {this.id,
        this.item_type,
        this.total_episodes,
        this.contentId,
        this.contentUuid,
        this.title,
        this.subtitle,
        this.backgroundImage,
        this.poster,
        this.thumbnail,
        this.ctaText,
        this.ctaUrl,
        this.contentType,
        this.rating,
        this.durationMinutes,
        this.releaseYear,
        this.imdbRating,
        this.genres,
        this.trailer,
        this.uuid,
        this.slug,
        this.banner,
        this.shortDescription,
        this.isFree,
        this.rank,
        this.watchProgress,
        this.url,
        this.image,
        this.altText});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    item_type = json['item_type'];
    contentId = json['content_id'];
    contentUuid = json['content_uuid'];
    title = json['title'];
    total_episodes = json['total_episodes'];
    subtitle = json['subtitle'];
    backgroundImage = json['background_image'] ??  json['cover_image'];
    poster = json['poster'];
    thumbnail = json['thumbnail'] ?? json['vertical_poster'];
    ctaText = json['cta_text'];
    ctaUrl = json['cta_url'];
    contentType = json['content_type'];
    rating = json['rating'];
    durationMinutes = json['duration_minutes'];
    releaseYear = json['release_year'];
    imdbRating = json['imdb_rating'];
    genres = json['genres'] != null ? json['genres'].cast<String>() : [];
    trailer =
    json['trailer'] != null ? Trailer.fromJson(json['trailer']) : null;
    uuid = json['uuid'];
    slug = json['slug'];
    banner = json['banner'];
    shortDescription = json['short_description'];
    isFree = json['is_free'];
    rank = json['rank'];
    watchProgress = json['watch_progress'] != null
        ? WatchProgress.fromJson(json['watch_progress'])
        : null;
    url = json['url'];
    image = json['image'];
    altText = json['alt_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['content_id'] = contentId;
    data['content_uuid'] = contentUuid;
    data['title'] = title;
    data['item_type'] = item_type;
    data['subtitle'] = subtitle;
    data['background_image'] = backgroundImage;
    data['poster'] = poster;
    data['thumbnail'] = thumbnail;
    data['cta_text'] = ctaText;
    data['cta_url'] = ctaUrl;
    data['content_type'] = contentType;
    data['rating'] = rating;
    data['total_episodes'] = total_episodes;
    data['duration_minutes'] = durationMinutes;
    data['release_year'] = releaseYear;
    data['imdb_rating'] = imdbRating;
    data['genres'] = genres;
    if (trailer != null) {
      data['trailer'] = trailer!.toJson();
    }
    data['uuid'] = uuid;
    data['slug'] = slug;
    data['banner'] = banner;
    data['short_description'] = shortDescription;
    data['is_free'] = isFree;
    data['rank'] = rank;
    if (watchProgress != null) {
      data['watch_progress'] = watchProgress!.toJson();
    }
    data['url'] = url;
    data['image'] = image;
    data['alt_text'] = altText;
    return data;
  }
}

class Trailer {
  String? type;
  String? url;
  String? embedId;
  String? embedUrl;

  Trailer({this.type, this.url, this.embedId, this.embedUrl});

  Trailer.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
    embedId = json['embed_id'];
    embedUrl = json['embed_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    data['embed_id'] = embedId;
    data['embed_url'] = embedUrl;
    return data;
  }
}

class WatchProgress {
  double? percent;
  int? position;
  dynamic episodeId;
  String? episodeUuid;
  String? lastWatchedAt;

  WatchProgress(
      {this.percent,
        this.position,
        this.episodeId,
        this.episodeUuid,
        this.lastWatchedAt});

  WatchProgress.fromJson(Map<String, dynamic> json) {
    percent = (json['percent'] as num?)?.toDouble();
    position = json['position'];
    episodeId = json['episode_id'];
    episodeUuid = json['episode_uuid'];
    lastWatchedAt = json['last_watched_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['percent'] = percent;
    data['position'] = position;
    data['episode_id'] = episodeId;
    data['episode_uuid'] = episodeUuid;
    data['last_watched_at'] = lastWatchedAt;
    return data;
  }
}

class SectionPagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  bool? hasMore;

  SectionPagination(
      {this.currentPage,
        this.perPage,
        this.total,
        this.lastPage,
        this.hasMore});

  SectionPagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    total = json['total'];
    lastPage = json['last_page'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['last_page'] = lastPage;
    data['has_more'] = hasMore;
    return data;
  }
}
