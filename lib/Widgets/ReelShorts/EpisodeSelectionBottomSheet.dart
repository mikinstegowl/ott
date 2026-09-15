import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Models/ShortDramaModel.dart';
import 'package:ottapp/Const/AppColors.dart';

/// Episode Selection Bottom Sheet with dynamic episodes, accurate lock states, and responsive tabs
class EpisodeSelectionBottomSheet extends StatefulWidget {
  final String dramaTitle;
  final String? posterUrl;
  final int totalEpisodes;
  final int currentEpisode;
  final Set<int> unlockedEpisodes;
  final List<ShortEpisodeItem>? episodes;
  final int userCoins;
  final ValueChanged<int> onSelectEpisode;
  final Function(int episodeNumber, int updatedCoins) onEpisodeUnlocked;

  const EpisodeSelectionBottomSheet({
    super.key,
    required this.dramaTitle,
    this.posterUrl,
    required this.totalEpisodes,
    required this.currentEpisode,
    required this.unlockedEpisodes,
    this.episodes,
    required this.userCoins,
    required this.onSelectEpisode,
    required this.onEpisodeUnlocked,
  });

  static void show({
    required BuildContext context,
    required String dramaTitle,
    String? posterUrl,
    required int totalEpisodes,
    required int currentEpisode,
    required Set<int> unlockedEpisodes,
    List<ShortEpisodeItem>? episodes,
    required int userCoins,
    required ValueChanged<int> onSelectEpisode,
    required Function(int episodeNumber, int updatedCoins) onEpisodeUnlocked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EpisodeSelectionBottomSheet(
        dramaTitle: dramaTitle,
        posterUrl: posterUrl,
        totalEpisodes: totalEpisodes,
        currentEpisode: currentEpisode,
        unlockedEpisodes: unlockedEpisodes,
        episodes: episodes,
        userCoins: userCoins,
        onSelectEpisode: onSelectEpisode,
        onEpisodeUnlocked: onEpisodeUnlocked,
      ),
    );
  }

  @override
  State<EpisodeSelectionBottomSheet> createState() =>
      _EpisodeSelectionBottomSheetState();
}

class _EpisodeSelectionBottomSheetState
    extends State<EpisodeSelectionBottomSheet>
    with SingleTickerProviderStateMixin {
  int _selectedTabRangeIndex = 0;
  late Set<int> _unlocked;
  late int _current;
  late AnimationController _equalizerController;

  int get effectiveTotalEpisodes {
    final epCount = widget.episodes?.length ?? 0;
    if (widget.totalEpisodes > 0) {
      return math.max(widget.totalEpisodes, epCount);
    }
    return epCount > 0 ? epCount : 1;
  }

  int get totalTabs => (effectiveTotalEpisodes / 30).ceil().clamp(1, 999);

  @override
  void initState() {
    super.initState();
    _unlocked = Set<int>.from(widget.unlockedEpisodes);
    _current = widget.currentEpisode;

    if (_current > 30) {
      _selectedTabRangeIndex = ((_current - 1) / 30).floor().clamp(0, totalTabs - 1);
    }

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _equalizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int total = effectiveTotalEpisodes;
    final int rangeStart = _selectedTabRangeIndex * 30 + 1;
    final int rangeEnd = math.min((_selectedTabRangeIndex + 1) * 30, total);
    final List<int> episodesInRange = List.generate(
      math.max(0, rangeEnd - rangeStart + 1),
      (index) => rangeStart + index,
    );

    return Container(
      height: 0.72.sh,
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
          // Top Drag Handle
          SizedBox(height: 8.h),
          Container(
            width: 38.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 10.h),

          // Header: Drama Poster + Title + Episode Count + Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    width: 42.w,
                    height: 52.h,
                    color: const Color(0xFF2C243B),
                    child: (widget.posterUrl != null &&
                            (widget.posterUrl?.isNotEmpty ?? false))
                        ? Image.network(
                            widget.posterUrl ?? "",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.movie_rounded,
                              color: Colors.amber,
                              size: 24.sp,
                            ),
                          )
                        : Icon(
                            Icons.movie_rounded,
                            color: Colors.amber,
                            size: 24.sp,
                          ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(
                        text: widget.dramaTitle,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        maxLines: 1,
                      ),
                      SizedBox(height: 3.h),
                      AppTextWidget(
                        text: total <= 1
                            ? "1 Episode • Complete"
                            : "Episodes 1 - $total • Ongoing",
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Range Tabs (Shown only if total episodes > 30)
          if (totalTabs > 1) ...[
            SizedBox(height: 14.h),
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: totalTabs,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, tabIndex) {
                  final start = tabIndex * 30 + 1;
                  final end = math.min((tabIndex + 1) * 30, total);
                  final isSelected = tabIndex == _selectedTabRangeIndex;

                  return _buildRangeTab(
                    title: "$start-$end",
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedTabRangeIndex = tabIndex),
                  );
                },
              ),
            ),
          ],

          SizedBox(height: 12.h),
          const Divider(color: Colors.white12, height: 1),

          // Episode Grid Matrix (Only shows actual episodes in range)
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.r),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 1.0,
              ),
              itemCount: episodesInRange.length,
              itemBuilder: (context, index) {
                final epNumber = episodesInRange[index];

                // Find matching episode data item from API response if available
                ShortEpisodeItem? epItem;
                if (widget.episodes != null) {
                  for (final e in (widget.episodes ?? <ShortEpisodeItem>[])) {
                    if (e.episodeNumber == epNumber) {
                      epItem = e;
                      break;
                    }
                  }
                }

                final bool isCurrent = epNumber == _current;
                final bool isFree = epItem?.isFree ?? (epNumber == 1);
                final bool isLocked = epItem?.isLocked ?? !_unlocked.contains(epNumber);
                final bool isUnlocked = isFree || !isLocked || _unlocked.contains(epNumber);

                return _buildEpisodeGridTile(
                  episodeNumber: epNumber,
                  isCurrent: isCurrent,
                  isUnlocked: isUnlocked,
                  isFree: isFree,
                  onTap: () {
                    setState(() => _current = epNumber);
                    Navigator.of(context).pop();
                    widget.onSelectEpisode(epNumber);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildRangeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appColors
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: AppTextWidget(
            text: title,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeGridTile({
    required int episodeNumber,
    required bool isCurrent,
    required bool isUnlocked,
    required bool isFree,
    required VoidCallback onTap,
  }) {
    if (isCurrent) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.appColors, Color(0xFF048A17)],
            ),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.appColors.withValues(alpha: 0.45),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTextWidget(
                text: "$episodeNumber",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              SizedBox(height: 3.h),
              AnimatedBuilder(
                animation: _equalizerController,
                builder: (context, _) {
                  final val = _equalizerController.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEqualizerBar(5.h + val * 5.h),
                      SizedBox(width: 2.w),
                      _buildEqualizerBar(9.h - val * 4.h),
                      SizedBox(width: 2.w),
                      _buildEqualizerBar(4.h + val * 6.h),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    if (isUnlocked) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF262629),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: AppTextWidget(
                  text: "$episodeNumber",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isFree)
              Positioned(
                top: 3.h,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: AppColors.appColors,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: const AppTextWidget(
                    text: "FREE",
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Locked Episode Tile
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF19191C),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextWidget(
              text: "$episodeNumber",
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            SizedBox(height: 2.h),
            Icon(
              Icons.lock_rounded,
              size: 13.sp,
              color: const Color(0xFFFFB300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualizerBar(double height) {
    return Container(
      width: 2.5.w,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }


}
