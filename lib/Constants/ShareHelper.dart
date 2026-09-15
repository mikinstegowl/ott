import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:url_launcher/url_launcher.dart';

class ShareHelper {
  /// Opens native OS system share sheet (Photo 2)
  /// Attaches poster photo if available, displaying '1 Photo Selected' on iOS
  /// and opening target apps (such as WhatsApp) with the image and share text.
  static Future<void> shareNative({
    Share? shareData,
    String? title,
    String? description,
    String? url,
    String? imageUrl,
  }) async {
    final finalTitle = title ?? shareData?.title ?? '';
    final finalDesc = description ?? shareData?.description ?? '';
    final finalUrl = url ?? shareData?.url ?? '';
    final finalImageUrl = imageUrl ?? shareData?.image;

    final List<String> textParts = [];
    if (finalTitle.isNotEmpty) textParts.add(finalTitle);
    if (finalDesc.isNotEmpty) textParts.add(finalDesc);
    if (finalUrl.isNotEmpty) textParts.add(finalUrl);
    final shareText = textParts.join('\n\n');

    File? imageFile;
    if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
      imageFile = await _downloadImageToTemp(finalImageUrl);
    }

    try {
      if (imageFile != null && await imageFile.exists()) {
        await share_plus.SharePlus.instance.share(
          share_plus.ShareParams(
            text: shareText,
            files: [share_plus.XFile(imageFile.path)],
            subject: finalTitle,
          ),
        );
      } else {
        await share_plus.SharePlus.instance.share(
          share_plus.ShareParams(
            text: shareText,
            subject: finalTitle,
          ),
        );
      }
    } catch (e) {
      debugPrint("ShareHelper.shareNative error: $e");
      try {
        await share_plus.SharePlus.instance.share(
          share_plus.ShareParams(
            text: shareText,
            subject: finalTitle,
          ),
        );
      } catch (err) {
        debugPrint("ShareHelper fallback share error: $err");
      }
    }
  }

  /// Opens WhatsApp directly with pre-filled text and link
  static Future<bool> openWhatsApp({
    required String text,
    required String url,
  }) async {
    final combined = text.isNotEmpty ? "$text\n$url" : url;
    final encoded = Uri.encodeComponent(combined);

    // 1. Try whatsapp:// scheme
    final schemeUri = Uri.parse("whatsapp://send?text=$encoded");
    try {
      if (await canLaunchUrl(schemeUri)) {
        return await launchUrl(schemeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // 2. Try api.whatsapp.com web endpoint
    final apiUri = Uri.parse("https://api.whatsapp.com/send?text=$encoded");
    try {
      if (await canLaunchUrl(apiUri)) {
        return await launchUrl(apiUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // 3. Try wa.me
    final waUri = Uri.parse("https://wa.me/?text=$encoded");
    try {
      if (await canLaunchUrl(waUri)) {
        return await launchUrl(waUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    return false;
  }

  static Future<File?> _downloadImageToTemp(String url) async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
        if (bytes.isEmpty) return null;

        final tempDir = Directory.systemTemp;
        String ext = '.jpg';
        final lower = uri.path.toLowerCase();
        if (lower.endsWith('.png')) {
          ext = '.png';
        } else if (lower.endsWith('.webp')) {
          ext = '.webp';
        }
        final file = File('${tempDir.path}/share_poster_${DateTime.now().millisecondsSinceEpoch}$ext');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      debugPrint("ShareHelper._downloadImageToTemp error: $e");
    }
    return null;
  }
}
