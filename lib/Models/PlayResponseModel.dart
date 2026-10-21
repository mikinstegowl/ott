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
  AdSchedule? ads;
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
    this.ads,
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
    ads = json['ads'] != null
        ? AdSchedule.fromJson(Map<String, dynamic>.from(json['ads'] as Map))
        : null;
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
    if (ads != null) data['ads'] = ads!.toJson();
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


/// The ad breaks for this play, as the server decided them.
///
/// `enabled` is false for anyone with an ad-free entitlement — an ad-free
/// plan, or a rental or purchase of this title — in which case `schedule` is
/// empty and the player simply never interrupts.
class AdSchedule {
  bool enabled = false;
  List<AdBreak> schedule = [];
  String? placeableType;
  int? placeableId;

  AdSchedule({this.enabled = false});

  AdSchedule.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'] == true;
    placeableType = json['placeable_type'];
    placeableId = json['placeable_id'];
    if (json['schedule'] != null) {
      schedule = (json['schedule'] as List)
          .map((e) => AdBreak.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.playAt.compareTo(b.playAt));
    }
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'placeable_type': placeableType,
        'placeable_id': placeableId,
        'schedule': schedule.map((e) => e.toJson()).toList(),
      };
}

/// One creative, pinned to one second of the video.
class AdBreak {
  int placementId = 0;
  int playAt = 0;
  AdCreative? ad;

  AdBreak();

  AdBreak.fromJson(Map<String, dynamic> json) {
    placementId = (json['placement_id'] as num?)?.toInt() ?? 0;
    playAt = (json['play_at'] as num?)?.toInt() ?? 0;
    ad = json['ad'] != null
        ? AdCreative.fromJson(Map<String, dynamic>.from(json['ad'] as Map))
        : null;
  }

  Map<String, dynamic> toJson() => {
        'placement_id': placementId,
        'play_at': playAt,
        if (ad != null) 'ad': ad!.toJson(),
      };
}

class AdCreative {
  int id = 0;
  String? name;
  String? advertiser;
  String? clickUrl;
  int? duration;
  int? skippableAfter;
  String? videoUrl;

  AdCreative();

  AdCreative.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt() ?? 0;
    name = json['name'];
    advertiser = json['advertiser'];
    clickUrl = json['click_url'];
    duration = (json['duration'] as num?)?.toInt();
    skippableAfter = (json['skippable_after'] as num?)?.toInt();
    final urls = json['video_urls'];
    videoUrl = (urls is Map ? urls['master'] : null) ?? json['video_url'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'advertiser': advertiser,
        'click_url': clickUrl,
        'duration': duration,
        'skippable_after': skippableAfter,
        'video_url': videoUrl,
      };

  bool get isSkippable => skippableAfter != null;
}
