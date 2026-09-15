import 'package:ottapp/Models/HomeModel.dart';

class SectionPaginationModel {
  bool? success;
  SectionData? data;

  SectionPaginationModel({this.success, this.data});

  SectionPaginationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SectionData.fromJson(json['data']) : null;
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

class SectionData {
  int? sectionId;
  String? title;
  String? layoutType;
  List<Items>? items;
  Pagination? pagination;

  SectionData(
      {this.sectionId, this.title, this.layoutType, this.items, this.pagination});

  SectionData.fromJson(Map<String, dynamic> json) {
    sectionId = json['section_id'];
    title = json['title'];
    layoutType = json['layout_type'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['section_id'] = sectionId;
    data['title'] = title;
    data['layout_type'] = layoutType;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  bool? hasMore;

  Pagination(
      {this.currentPage, this.perPage, this.total, this.lastPage, this.hasMore});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    total = json['total'];
    lastPage = json['last_page'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['last_page'] = lastPage;
    data['has_more'] = hasMore;
    return data;
  }
}
