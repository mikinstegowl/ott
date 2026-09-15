class ContentTypeModel {
  bool? success;
  List<ContentTypeData>? data;

  ContentTypeModel({this.success, this.data});

  ContentTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ContentTypeData>[];
      json['data'].forEach((v) {
        data!.add(ContentTypeData.fromJson(v));
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

class ContentTypeData {
  int? id;
  String? name;
  String? slug;
  String? icon;

  ContentTypeData({this.id, this.name, this.slug, this.icon});

  ContentTypeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['icon'] = icon;
    return data;
  }
}
