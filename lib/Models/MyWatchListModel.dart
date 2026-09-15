class MyWatchListModel {
  bool? success;
  Data? data;

  MyWatchListModel({this.success, this.data});

  MyWatchListModel.fromJson(Map<String, dynamic> json) {
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
  List<Items>? items;
  Pagination? pagination;

  Data({this.items, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Items {
  int? id;
  String? addedAt;
  Content? content;

  Items({this.id, this.addedAt, this.content});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addedAt = json['added_at'];
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['added_at'] = addedAt;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class Content {
  int? id;
  String? uuid;
  String? title;
  String? slug;
  String? contentType;
  String? thumbnail;
  String? poster;
  String? releaseYear;
  List<String>? genres;

  Content(
      {this.id,
        this.uuid,
        this.title,
        this.slug,
        this.contentType,
        this.thumbnail,
        this.poster,
        this.releaseYear,
        this.genres});

  Content.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    slug = json['slug'];
    contentType = json['content_type'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    releaseYear = json['release_year'];
    genres = json['genres'].cast<String>();
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
    data['genres'] = genres;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? total;
  bool? hasMore;

  Pagination({this.currentPage, this.lastPage, this.total, this.hasMore});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    total = json['total'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['total'] = total;
    data['has_more'] = hasMore;
    return data;
  }
}
