/// The section types the server sends on the home page payload.
///
/// These are identifiers matched against API responses, not words anyone
/// reads. They lived in AppText alongside the button labels, which meant a
/// translation pass over that file would have quietly renamed them and left
/// the home page unable to match a single section.
class SectionTypes {
  static const hero_banner = 'hero_banner';
  static const horizontal_rail = 'horizontal_rail';
  static const banner_card = 'banner_card';
  static const top_10_rail = 'top_10_rail';
  static const vertical_rail = 'vertical_rail';
  static const landscape_rail = 'landscape_rail';
  static const portrait_rail = 'portrait_rail';
  static const genre_tabs = 'genre_tabs';
  static const vertical_grid = 'vertical_grid';
  static const shorts_grid = 'shorts_grid';
  static const shorts_rail = 'shorts_rail';
  static const single_spotlight = 'single_spotlight';
  static const sponsor_rail = 'sponsor_rail';

  /// Marks an item in a mixed list as a short rather than a full title.
  static const item_type = 'short';
}
