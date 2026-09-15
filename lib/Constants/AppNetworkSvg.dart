import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:http/http.dart' as http;

final Map<String, String> _svgCache = {};
final Map<String, bool> _svgErrorCache = {};

class AppNetworkSvg extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const AppNetworkSvg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.amberOpacity20,
        borderRadius: BorderRadius.circular(4),
      ),
      child: AppTextWidget(
        text: "IMDb",
        fontSize: (height != null && height! < 15) ? 8 : 10,
        fontWeight: FontWeight.bold,
        color: AppColors.amber,
      ),
    );
  }

  Future<String> _fetchSvg() async {
    if (_svgCache.containsKey(url)) return _svgCache[url]!;
    if (_svgErrorCache.containsKey(url)) throw Exception("Cached Error");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final content = response.body;
        // Validate if it actually contains SVG
        if (content.contains('<svg') || content.contains('<?xml')) {
          _svgCache[url] = content;
          return content;
        }
      }
      _svgErrorCache[url] = true;
      throw Exception("Invalid SVG content");
    } catch (e) {
      _svgErrorCache[url] = true;
      throw Exception("Network Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || _svgErrorCache.containsKey(url)) {
      return _buildErrorWidget();
    }

    if (_svgCache.containsKey(url)) {
      return SvgPicture.string(
        _svgCache[url]!,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }

    return FutureBuilder<String>(
      future: _fetchSvg(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height ?? 20,
            width: width ?? 20,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget();
        }
        return SvgPicture.string(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        );
      },
    );
  }
}