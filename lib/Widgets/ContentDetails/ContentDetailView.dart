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

  /// Rent / buy buttons for a pay-per-view title. Empty when the title is
  /// free, subscription-only, or already owned — the server decides, and the
  /// app draws whatever it is handed.
  final List<Offer> offers;

  /// Called with the chosen offer ('rent' or 'buy').
  final void Function(Offer offer)? onOffer;

  /// "Rented · 36 h left" when this viewer already holds the title.
  final String? ownershipLabel;

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
    this.offers = const [],
    this.onOffer,
    this.ownershipLabel,
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
                if (ownershipLabel != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16.sp, color: const Color(0xFF7EE2A8)),
                        SizedBox(width: 6.w),
                        AppTextWidget(
                          text: ownershipLabel!,
                          color: const Color(0xFF7EE2A8),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                // Rent / buy. A pay-per-view title has no subscribe route, so
                // without these the viewer has no way to watch at all.
                if (offers.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: offers.map((offer) {
                        return OutlinedButton.icon(
                          onPressed: onOffer == null ? null : () => onOffer!(offer),
                          icon: Icon(
                            offer.type == 'rent' ? Icons.schedule : Icons.shopping_bag_outlined,
                            size: 18.sp,
                            color: AppColors.white,
                          ),
                          label: AppTextWidget(
                            text: offer.type == 'rent' && offer.watchHours != null
                                ? '${offer.label} · ${offer.watchHours}h'
                                : offer.label,
                            color: AppColors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
