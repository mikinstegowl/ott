class FcmModel {
  bool? success;
  String? message;
  Data? data;

  FcmModel({this.success, this.message, this.data});

  FcmModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? token;
  String? platform;
  String? deviceName;
  String? lastUsedAt;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.userId,
        this.token,
        this.platform,
        this.deviceName,
        this.lastUsedAt,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    token = json['token'];
    platform = json['platform'];
    deviceName = json['device_name'];
    lastUsedAt = json['last_used_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['token'] = token;
    data['platform'] = platform;
    data['device_name'] = deviceName;
    data['last_used_at'] = lastUsedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
