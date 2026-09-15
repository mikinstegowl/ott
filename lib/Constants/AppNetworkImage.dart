import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ottapp/Const/AppConstants.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final String placeholderAsset;
  final double? height;
  final double? width;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholderAsset = 'assets/image/backgroundlogo.png',
    this.height,
    this.width,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl.startsWith('http') ? imageUrl : AppConstants.s3BaseUrl + imageUrl,
      fit: fit,
      height: height,
      width: width,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => Image.asset(
        placeholderAsset,
        fit: fit,
        height: height,
        width: width,
      ),
      errorWidget: (context, url, error) => Image.asset(
        placeholderAsset,
        fit: fit,
        height: height,
        width: width,
      ),
    );
  }
}