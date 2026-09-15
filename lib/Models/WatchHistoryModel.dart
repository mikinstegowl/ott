class WatchHistoryRequest {
  int? contentId;
  int? episodeId;
  int? watchPosition;
  int? durationSeconds;
  String? deviceType;

  WatchHistoryRequest({
    this.contentId,
    this.episodeId,
    this.watchPosition,
    this.durationSeconds,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'episode_id': episodeId,
      'watch_position': watchPosition,
      'duration_seconds': durationSeconds,
      'device_type': deviceType ?? 'mobile',
    };
  }
}

class WatchHistoryResponse {
  bool? success;
  WatchHistoryData? data;

  WatchHistoryResponse({this.success, this.data});

  WatchHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? WatchHistoryData.fromJson(json['data']) : null;
  }
}

class WatchHistoryData {
  String? percentWatched;
  bool? isCompleted;

  WatchHistoryData({this.percentWatched, this.isCompleted});

  WatchHistoryData.fromJson(Map<String, dynamic> json) {
    percentWatched = json['percent_watched'];
    isCompleted = json['is_completed'];
  }
}
