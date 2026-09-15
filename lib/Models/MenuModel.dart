class MenuModel {
  int? id;
  String? title;
  String? slug;
  String? pageType;
  int? genreId;

  MenuModel({this.id, this.title, this.slug, this.pageType, this.genreId});

  MenuModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    pageType = json['page_type'];
    genreId = json['genre_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['page_type'] = pageType;
    data['genre_id'] = genreId;
    return data;
  }
}
