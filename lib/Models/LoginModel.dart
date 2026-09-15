class LoginModel {
  bool? success;
  Data? data;

  LoginModel({this.success, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != dynamic ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != dynamic) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  User? user;
  String? token;

  Data({this.user, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != dynamic ? User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != dynamic) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  dynamic avatar;
  String? role;
  String? preferredQuality;
  bool? emailVerified;
  String? createdAt;
  dynamic subscription;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.role,
    this.preferredQuality,
    this.emailVerified,
    this.createdAt,
    this.subscription,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
    role = json['role'];
    preferredQuality = json['preferred_quality'];
    emailVerified = json['email_verified'];
    createdAt = json['created_at'];
    subscription = json['subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['role'] = role;
    data['preferred_quality'] = preferredQuality;
    data['email_verified'] = emailVerified;
    data['created_at'] = createdAt;
    data['subscription'] = subscription;
    return data;
  }
}
