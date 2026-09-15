import 'package:ottapp/Models/HomeModel.dart';

class SearchResponseModel {
  bool? success;
  SearchData? data;

  SearchResponseModel({this.success, this.data});

  SearchResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SearchData.fromJson(json['data']) : null;
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

class SearchData {
  List<Items>? items;
  List<Items>? shorts;
  SectionPagination? pagination;

  SearchData({this.items, this.shorts, this.pagination});

  SearchData.fromJson(Map<String, dynamic> json) {
    items = <Items>[];
    if (json['items'] != null && json['items'] is List) {
      for (var v in json['items']) {
        items!.add(Items.fromJson(v));
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
        // Also add to items list so existing grid renders it seamlessly
        items!.add(shortItem);
      }
    }
    pagination = json['pagination'] != null
        ? SectionPagination.fromJson(json['pagination'])
        : json['section_pagination'] != null 
            ? SectionPagination.fromJson(json['section_pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (shorts != null) {
      data['shorts'] = shorts!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}
