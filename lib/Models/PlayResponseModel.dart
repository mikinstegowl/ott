class PlayResponseModel {
  bool? success;
  String? message;
  String? msgHeader;
  String? msgDesc;
  String? msgBtn;
  String? code;
  PlayData? data;

  PlayResponseModel({
    this.success,
    this.message,
    this.msgHeader,
    this.msgDesc,
    this.msgBtn,
    this.code,
    this.data,
  });

  PlayResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    msgHeader = json['msg_header'];
    msgDesc = json['msg_desc'];
    msgBtn = json['msg_btn'];
    code = json['code']?.toString();
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = PlayData.fromJson(json['data']);
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['msg_header'] = msgHeader;
    data['msg_desc'] = msgDesc;
    data['msg_btn'] = msgBtn;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PlayData {
  int? contentId;
  String? title;
  int? duration;
  dynamic watchProgress;
  String? videoSource;
  String? maxQuality;
  VideoUrls? videoUrls;
  String? embedId;
  String? embedUrl;
  String? watchUrl;
  String? plansUrl;

  PlayData({
    this.contentId,
    this.title,
    this.duration,
    this.watchProgress,
    this.videoSource,
    this.maxQuality,
    this.videoUrls,
    this.embedId,
    this.embedUrl,
    this.watchUrl,
    this.plansUrl,
  });

  PlayData.fromJson(Map<String, dynamic> json) {
    contentId = json['content_id'];
    title = json['title'];
    duration = json['duration'];
    watchProgress = json['watch_progress'];
    videoSource = json['video_source'];
    maxQuality = json['max_quality'];
    if (json['video_urls'] != null && json['video_urls'] is Map<String, dynamic>) {
      videoUrls = VideoUrls.fromJson(json['video_urls']);
    } else {
      videoUrls = null;
    }
    embedId = json['embed_id'];
    embedUrl = json['embed_url'];
    watchUrl = json['watch_url'];
    plansUrl = json['plans_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content_id'] = contentId;
    data['title'] = title;
    data['duration'] = duration;
    data['watch_progress'] = watchProgress;
    data['video_source'] = videoSource;
    data['max_quality'] = maxQuality;
    if (videoUrls != null) {
      data['video_urls'] = videoUrls!.toJson();
    }
    data['embed_id'] = embedId;
    data['embed_url'] = embedUrl;
    data['watch_url'] = watchUrl;
    data['plans_url'] = plansUrl;
    return data;
  }
}

class VideoUrls {
  String? master;
  String? p360;
  String? p720;
  String? p1080;
  String? k4;

  VideoUrls({this.master, this.p360, this.p720, this.p1080, this.k4});

  VideoUrls.fromJson(Map<String, dynamic> json) {
    master = json['master'];
    p360 = json['360p'];
    p720 = json['720p'];
    p1080 = json['1080p'];
    k4 = json['4K'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['master'] = master;
    data['360p'] = p360;
    data['720p'] = p720;
    data['1080p'] = p1080;
    data['4K'] = k4;
    return data;
  }
}
