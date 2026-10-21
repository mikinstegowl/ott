import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:url_launcher/url_launcher.dart';

/// The sponsor strip for one title.
///
/// Sponsors are sold per title, so this shows only what is attached to the
/// one being viewed. It draws nothing at all when there is no slider, rather
/// than leaving an empty heading behind.
class SponsorRail extends StatelessWidget {
  const SponsorRail({super.key, required this.slider});

  final SponsorSlider? slider;

  @override
  Widget build(BuildContext context) {
    final s = slider;
    if (s == null || !s.hasItems) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((s.title ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                s.title!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),

          // A single sponsor should not stretch to fill the row, so the strip
          // scrolls rather than distributing whatever is there.
          SizedBox(
            height: 54.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: s.items.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) => _SponsorBanner(item: s.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorBanner extends StatelessWidget {
  const _SponsorBanner({required this.item});

  final SponsorItem item;

  Future<void> _open() async {
    final url = item.url;
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sponsor artwork is supplied at 1400×170, so keep that shape and let the
    // height decide the width.
    return Semantics(
      label: item.altText ?? 'Sponsor',
      button: item.url != null && item.url!.isNotEmpty,
      child: GestureDetector(
        onTap: _open,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: AspectRatio(
            aspectRatio: 1400 / 170,
            child: CachedNetworkImage(
              imageUrl: item.image,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
              placeholder: (_, __) => Container(color: Colors.white10),
            ),
          ),
        ),
      ),
    );
  }
}
