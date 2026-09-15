class MagicLinkModel {
  bool? success;
  Data? data;

  MagicLinkModel({this.success, this.data});

  MagicLinkModel.fromJson(Map<String, dynamic> json) {
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
  String? magicUrl;
  int? expiresIn;

  Data({this.magicUrl, this.expiresIn});

  Data.fromJson(Map<String, dynamic> json) {
    magicUrl = json['magic_url'];
    expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['magic_url'] = magicUrl;
    data['expires_in'] = expiresIn;
    return data;
  }
}
