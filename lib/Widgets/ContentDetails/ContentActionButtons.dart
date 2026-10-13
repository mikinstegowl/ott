import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';

class ContentActionButtons extends StatelessWidget {
  final String playText;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isInWatchlist;
  final bool isLoading;
  final bool isPlayLoading;

  /// Rent / buy, shown beside the main button rather than under it so the
  /// ways to watch stay on one line.
  final List<Offer> offers;
  final void Function(Offer)? onOffer;

  const ContentActionButtons({
    super.key,
    this.playText = "Watch Now",
    this.onPlay,
    this.onFavorite,
    this.onShare,
    this.isInWatchlist = false,
    this.isLoading = false,
    this.isPlayLoading = false,
    this.offers = const [],
    this.onOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The main button keeps half the width and the pay-per-view options
          // share the rest, so a title that can be subscribed to *or* bought
          // offers both without pushing either below the fold.
          Row(
            children: [
              Expanded(
                flex: offers.isEmpty ? 1 : 2,
                child: AppPrimaryButton(
                  text: playText,
                  onTap: onPlay ?? () {},
                  icon: Icons.play_arrow,
                  isLoading: isPlayLoading,
                ),
              ),
              ...offers.map(
                (offer) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: _buildOfferButton(offer),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildIconButton(
                isInWatchlist ? Icons.favorite : Icons.favorite_border, 
                onFavorite,
                iconColor: isInWatchlist ? AppColors.appColors : AppColors.white,
                isLoading: isLoading,
                text: "Watchlist",
              ),
              SizedBox(width: 30.w),
              _buildIconButton(
                Icons.share,
                onShare,
                iconColor: AppColors.white,
                text: "Share",
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact on purpose: at a quarter of the width there is room for the
  /// word and the price, and nothing else. The rental window is left to the
  /// sheet that opens on tap.
  Widget _buildOfferButton(Offer offer) {
    return SizedBox(
      height: 48.h,
      child: OutlinedButton(
        onPressed: onOffer == null ? null : () => onOffer!(offer),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offer.type == 'rent'
                    ? Icons.schedule
                    : Icons.shopping_bag_outlined,
                size: 14.sp,
                color: AppColors.white,
              ),
              SizedBox(width: 5.w),
              Text(
                offer.label,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap, {Color? iconColor, bool isLoading = false, String? text}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white10,
              shape: BoxShape.circle,
            ),
            child: isLoading 
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.appColors,
                  ),
                )
              : Icon(icon, color: iconColor ?? AppColors.white, size: 20.sp),
          ),
          if (text != null) ...[
            SizedBox(height: 5.h),
            Text(
              text,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

