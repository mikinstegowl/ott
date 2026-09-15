class LiveVideoModel {
  bool? success;
  Data? data;

  LiveVideoModel({this.success, this.data});

  LiveVideoModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? image;
  String? link;
  String? description;
  bool? isActive;

  Data({this.name, this.image, this.link, this.description, this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    link = json['link'];
    description = json['description'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['link'] = link;
    data['description'] = description;
    data['is_active'] = isActive;
    return data;
  }
}
