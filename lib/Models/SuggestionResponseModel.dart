import 'package:ottapp/Models/HomeModel.dart';

class SuggestionResponseModel {
  bool? success;
  SuggestionData? suggestionData;
  List<Items>? data;

  SuggestionResponseModel({this.success, this.suggestionData, this.data});

  SuggestionResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = <Items>[];
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      suggestionData = SuggestionData.fromJson(json['data']);
      
      if (suggestionData?.contents != null) {
        data!.addAll(suggestionData!.contents!);
      }
      if (suggestionData?.shorts != null) {
        data!.addAll(suggestionData!.shorts!);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['success'] = success;
    if (suggestionData != null) {
      jsonMap['data'] = suggestionData!.toJson();
    } else if (data != null) {
      jsonMap['data'] = {
        'contents': data!.where((e) => e.item_type != 'shorts').map((v) => v.toJson()).toList(),
        'shorts': data!.where((e) => e.item_type == 'shorts').map((v) => v.toJson()).toList(),
      };
    }
    return jsonMap;
  }
}

class SuggestionData {
  List<Items>? contents;
  List<Items>? shorts;
  List<SuggestionGenre>? genres;
  List<SuggestionPerson>? people;

  SuggestionData({this.contents, this.shorts, this.genres, this.people});

  SuggestionData.fromJson(Map<String, dynamic> json) {
    if (json['contents'] != null && json['contents'] is List) {
      contents = <Items>[];
      for (var v in json['contents']) {
        contents!.add(Items.fromJson(v));
      }
    }
    if (json['shorts'] != null && json['shorts'] is List) {
      shorts = <Items>[];
      for (var v in json['shorts']) {
        final shortItem = Items.fromJson(v);
        shortItem.item_type = 'shorts';
        shortItem.contentType = 'Short Series';
        shortItem.thumbnail = v['vertical_poster'] ?? v['thumbnail'];
        shortItem.poster = v['vertical_poster'] ?? v['poster'];
        shorts!.add(shortItem);
      }
    }
    if (json['genres'] != null && json['genres'] is List) {
      genres = <SuggestionGenre>[];
      for (var v in json['genres']) {
        genres!.add(SuggestionGenre.fromJson(v));
      }
    }
    if (json['people'] != null && json['people'] is List) {
      people = <SuggestionPerson>[];
      for (var v in json['people']) {
        people!.add(SuggestionPerson.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (contents != null) {
      map['contents'] = contents!.map((v) => v.toJson()).toList();
    }
    if (shorts != null) {
      map['shorts'] = shorts!.map((v) => v.toJson()).toList();
    }
    if (genres != null) {
      map['genres'] = genres!.map((v) => v.toJson()).toList();
    }
    if (people != null) {
      map['people'] = people!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SuggestionGenre {
  int? id;
  String? name;
  String? slug;

  SuggestionGenre({this.id, this.name, this.slug});

  SuggestionGenre.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}

class SuggestionPerson {
  int? id;
  String? name;
  String? photo;

  SuggestionPerson({this.id, this.name, this.photo});

  SuggestionPerson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photo': photo};
  }
}
