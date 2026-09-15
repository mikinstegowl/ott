class ShortsProgressRequestModel {
  String? episodeUuid;
  int? positionSeconds;
  int? durationSeconds;

  ShortsProgressRequestModel({
    this.episodeUuid,
    this.positionSeconds,
    this.durationSeconds,
  });

  ShortsProgressRequestModel.fromJson(Map<String, dynamic> json) {
    episodeUuid = json['episode_uuid'];
    positionSeconds = json['position_seconds'];
    durationSeconds = json['duration_seconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (episodeUuid != null) {
      data['episode_uuid'] = episodeUuid;
    }
    if (positionSeconds != null) {
      data['position_seconds'] = positionSeconds;
    }
    if (durationSeconds != null) {
      data['duration_seconds'] = durationSeconds;
    }
    return data;
  }
}

class ShortsProgressResponseModel {
  bool? success;
  String? message;
  dynamic data;

  ShortsProgressResponseModel({
    this.success,
    this.message,
    this.data,
  });

  ShortsProgressResponseModel.fromJson(Map<String, dynamic> json) {
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
