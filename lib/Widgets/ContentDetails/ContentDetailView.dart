import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Widgets/ContentDetails/ContentVideoHeader.dart';
import 'package:ottapp/Widgets/ContentDetails/ContentDescription.dart';
import 'package:ottapp/Widgets/ContentDetails/ContentMetadata.dart';
import 'package:ottapp/Widgets/ContentDetails/ContentActionButtons.dart';

import 'package:ottapp/Constants/AppUtils.dart';

class ContentDetailView extends StatelessWidget {
  final Data? data;
  final bool isLoading;
  final bool showVideo;
  final bool isDescriptionExpanded;
  final String? trailerUrl;
  final VoidCallback onToggleDescription;
  final String playText;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final Widget? extraSection;
  final bool isLoadingWatchlist;
  final bool isPlayLoading;

  const ContentDetailView({
    super.key,
    this.data,
    this.isLoading = false,
    this.showVideo = false,
    this.isDescriptionExpanded = false,
    this.trailerUrl,
    required this.onToggleDescription,
    this.playText = "Watch Now",
    this.onPlay,
    this.onFavorite,
    this.onShare,
    this.extraSection,
    this.isLoadingWatchlist = false,
    this.isPlayLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return Center(
        child: AppTextWidget(
          text: "Content not found",
          color: AppColors.white,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentVideoHeader(
            imageUrl: data?.poster,
            showVideo: showVideo,
            trailerUrl: trailerUrl,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentDescription(
                  title: data?.title ?? "",
                  description: AppUtils.stripHtml(data?.description ?? data?.shortDescription ?? ""),
                  isExpanded: isDescriptionExpanded,
                  onToggle: onToggleDescription,
                ),
                SizedBox(height: 10.h),
                ContentMetadata(
                  releaseYear: data?.releaseYear,
                  durationMinutes: data?.durationMinutes,
                  viewCount: data?.viewCount,
                  imdbRating: data?.imdbRating,
                  genres: data?.genres?.map((g) => g.name ?? "").toList(),
                  language: data?.language?.name,
                ),
                ContentActionButtons(
                  onPlay: onPlay,
                  playText: playText,
                  isInWatchlist: data?.inWatchlist ?? false,
                  onFavorite: onFavorite,
                  onShare: onShare,
                  isLoading: isLoadingWatchlist,
                  isPlayLoading: isPlayLoading,
                ),
                if (extraSection != null) extraSection!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
