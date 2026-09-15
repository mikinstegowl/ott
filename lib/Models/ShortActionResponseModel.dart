class ShortActionResponseModel {
  bool? success;
  String? message;
  dynamic data;

  ShortActionResponseModel({
    this.success,
    this.message,
    this.data,
  });

  ShortActionResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = success;
    dataMap['message'] = message;
    dataMap['data'] = data;
    return dataMap;
  }
}
