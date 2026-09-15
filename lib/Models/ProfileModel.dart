class ProfileModel {
  bool? success;
  Data? data;

  ProfileModel({this.success, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  String? avatar;
  String? role;
  String? preferredQuality;
  bool? emailVerified;
  String? createdAt;
  Subscription? subscription;

  Data({
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

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
    role = json['role'];
    preferredQuality = json['preferred_quality'];
    emailVerified = json['email_verified'];
    createdAt = json['created_at'];
    subscription =
        json['subscription'] != null
            ? Subscription.fromJson(json['subscription'])
            : null;
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
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    return data;
  }
}

class Subscription {
  int? id;
  String? planName;
  String? status;
  String? maxQuality;
  int? maxScreens;
  String? endsAt;

  Subscription({
    this.id,
    this.planName,
    this.status,
    this.maxQuality,
    this.maxScreens,
    this.endsAt,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planName = json['plan_name'];
    status = json['status'];
    maxQuality = json['max_quality'];
    maxScreens = json['max_screens'];
    endsAt = json['ends_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['plan_name'] = planName;
    data['status'] = status;
    data['max_quality'] = maxQuality;
    data['max_screens'] = maxScreens;
    data['ends_at'] = endsAt;
    return data;
  }
}
