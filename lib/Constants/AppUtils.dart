class AppUtils {
  /// Removes HTML tags from a string and returns plain text.
  static String stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return "";
    
    // Pattern to match any HTML tag
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    
    // Replace &nbsp; and other common entities if needed
    String decoded = htmlString
      .replaceAll("&nbsp;", " ")
      .replaceAll("&amp;", "&")
      .replaceAll("&quot;", "\"")
      .replaceAll("&lt;", "<")
      .replaceAll("&gt;", ">");
      
    return decoded.replaceAll(exp, '').trim();
  }
}
