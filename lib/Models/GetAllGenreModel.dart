class GetAllGenreModel {
  bool? success;
  List<Data>? data;

  GetAllGenreModel({this.success, this.data});

  GetAllGenreModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? slug;
  String? description;
  String? thumbnail;
  String? banner;
  int? contentCount;

  Data({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.thumbnail,
    this.banner,
    this.contentCount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    banner = json['banner'];
    contentCount = json['content_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['banner'] = banner;
    data['content_count'] = contentCount;
    return data;
  }
}
