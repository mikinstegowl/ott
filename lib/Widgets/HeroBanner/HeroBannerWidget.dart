import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppConstants.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'dart:async';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/HeroBanner/BannerContentWidget.dart';
import 'package:ottapp/Widgets/Player/CommonNativePlayer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Controllers/BaseController.dart';

class HeroBannerWidget extends StatefulWidget {
  final Sections section;
  final VoidCallback? onLoadMore;
  const HeroBannerWidget({super.key, required this.section, this.onLoadMore});

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget> {
  static const int _infiniteBannerMultiplier = 1000;
  late final PageController _bannerPageController;
  double _bannerPage = 0;
  int _lastLogicalIndex = -1;
  
  // Video Controllers and Timer
  // VideoPlayerController? _videoPlayerController; // Removed in favor of CommonNativePlayer
  YoutubePlayerController? _youtubeController;
  Timer? _timer;
  StreamSubscription? _tabSub;
  bool _showVideo = false;
  String? _videoUrl;
  bool _isVisible = true;

  int get _bannerCount => widget.section.items?.length ?? 0;

  double get _logicalPage {
    if (_bannerCount == 0) return 0;
    final p = _bannerPage % _bannerCount;
    return p < 0 ? p + _bannerCount : p;
  }

  @override
  void initState() {
    super.initState();
    final n = _bannerCount;
    _bannerPageController = PageController(
      initialPage: _infiniteBannerMultiplier * n,
    );
    _bannerPage = _infiniteBannerMultiplier * n.toDouble();
    _bannerPageController.addListener(() {
      setState(() => _bannerPage = _bannerPageController.page ?? 0);

      // Trigger pagination when near the end of the physical list
      final n = _bannerCount;
      if (n > 0) {
        final currentLogicalIndex = _logicalPage.round() % n;
        
        // If the page has changed, reset the trailer timer and stop current video
        if (currentLogicalIndex != _lastLogicalIndex) {
          _lastLogicalIndex = currentLogicalIndex;
          _resetTrailer();
          _startTrailerTimer();
        }

        if (currentLogicalIndex >= n - 2 && widget.section.hasMore == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // widget.onLoadMore?.call();
          });
        }
      }
    });

    // Start timer for initial banner
    if (n > 0) {
      _lastLogicalIndex = _logicalPage.round() % n;
      _startTrailerTimer();
    }

    // Visibility detection handles scroll & navigation automatically
  }

  void _startTrailerTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      final currentItem = widget.section.items![_lastLogicalIndex];
      if (currentItem.trailer != null) {
        _initializeVideoPlayer(currentItem.trailer!);
      }
    });
  }

  void _resetTrailer() {
    _timer?.cancel();
    _timer = null;
    _videoUrl = null;
    
    // _videoPlayerController?.pause();
    // _videoPlayerController?.dispose();
    // _videoPlayerController = null;
    
    _youtubeController?.dispose();
    _youtubeController = null;
    
    if (_showVideo) {
      _showVideo = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _initializeVideoPlayer(Trailer trailer) async {
    try {
      if (trailer.type == 'mp4' && (trailer.url?.isNotEmpty ?? false)) {
        final String trailerUrl = trailer.url!;
        _videoUrl = trailerUrl.startsWith('http') 
            ? trailerUrl 
            : AppConstants.s3BaseUrl + trailerUrl;
        
        if (mounted) {
          setState(() {
            _showVideo = true;
          });
        }
      } else if (trailer.type == 'youtube' && (trailer.embedId?.isNotEmpty ?? false)) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: trailer.embedId!,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: true,
            loop: true,
            controlsVisibleAtStart: false,
            disableDragSeek: true,
            hideControls: true,
            showLiveFullscreenButton: false,
          ),
        );
        
        if (mounted) {
          setState(() {
            _showVideo = true;
          });
        }
      }
    } catch (e) {
      // Intentionally silent
    }
  }

  @override
  void dispose() {
    _tabSub?.cancel();
    _bannerPageController.dispose();
    _resetTrailer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerCount == 0) return const SizedBox.shrink();

    return VisibilityDetector(
      key: Key('hero-banner-${widget.section.id}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        final visibleFraction = info.visibleFraction;
        
        if (visibleFraction < 0.2) { // Dropped below 20% visibility
          if (_isVisible) {
            _isVisible = false;
            _resetTrailer();
          }
        } else if (visibleFraction > 0.8) { // Visible again at 80%
          if (!_isVisible) {
            _isVisible = true;
            _startTrailerTimer();
          }
        }
      },
      child: SizedBox(
        height: 450.h,
        child: Stack(
        fit: StackFit.expand,
        children: [
          ...List.generate(_bannerCount, (index) {
            final n = _bannerCount.toDouble();
            double d = (_logicalPage - index).abs();
            if (d > n / 2) d = n - d;
            final opacity = (1 - d).clamp(0.0, 1.0);
            final item = widget.section.items![index];
            final isActive = _lastLogicalIndex == index;
            return IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: isActive && _showVideo
                      ? KeyedSubtree(
                          key: const ValueKey('video'),
                          child: _buildVideoPlayer(),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('image'),
                          child: AppNetworkImage(
                            imageUrl: item.backgroundImage ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
            );
          }),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.blackOpacity70, Colors.transparent], // Replaced Colors.black   .withAlpha(178)
              ),
            ),
          ),
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _infiniteBannerMultiplier * _bannerCount * 2,
            itemBuilder: (context, index) => const SizedBox.expand(),
          ),
          Positioned(
            left: 10.w,
            right: 20.w,
            bottom: 60.h,
            child: Builder(
              builder: (context) {
                final n = _bannerCount;
                if (n == 0) return const SizedBox.shrink();
                
                final frac = _logicalPage - _logicalPage.floor();
                const slidePx = 40.0;
                final currentIndex = _logicalPage.floor() % n;
                final nextIndex = (currentIndex + 1) % n;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Current Item (fades out and slides left)
                    IgnorePointer(
                      ignoring: frac > 0.5,
                      child: Opacity(
                        opacity: (1 - frac).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(-slidePx * frac, 0),
                          child: BannerContentWidget(
                            item:
                                widget.section.items?[currentIndex] ?? Items(),
                            onPlay: () {
                              if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
                                Get.find<BaseController>().showLoginDialog();
                              } else {
                                if(widget.section.items![currentIndex].item_type == AppText.item_type ){
                                  final item = widget.section.items![currentIndex];
                                  Get.toNamed(
                                    RoutesName.reelShortsScreen,
                                    arguments: {
                                      'uuid': item.contentUuid ?? item.uuid,
                                      'slug': item.slug,
                                      'dramaTitle': item.title,
                                      'item': item,
                                    },
                                  );
                                }else{
                                  final item = widget.section.items![currentIndex];
                                  Get.toNamed(
                                    RoutesName.infoScreen,
                                    arguments: item.contentUuid ?? item.uuid,
                                  );
                                }

                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    // Next Item (fades in and slides in from right)
                    IgnorePointer(
                      ignoring: frac <= 0.5,
                      child: Opacity(
                        opacity: frac.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(slidePx * (1 - frac), 0),
                          child: BannerContentWidget(
                            item: widget.section.items?[nextIndex] ?? Items(),
                            onPlay: () {
                              if (UserPreference.getValue(key: PrefKeys.logInToken) == null) {
                                Get.find<BaseController>().showLoginDialog();
                              } else {
                                final item = widget.section.items![nextIndex];
                                Get.toNamed(
                                  RoutesName.infoScreen,
                                  arguments: item.contentUuid ?? item.uuid,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerCount, (index) {
                final n = _bannerCount;
                final isActive = n > 0 && (_logicalPage.round() % n == index);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 8.h,
                  width: 8.w,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.appColors
                            : AppColors.appColors .withValues(alpha: 89), // Replaced withOpacity(0.35)
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildVideoPlayer() {
    if (_videoUrl != null) {
      return CommonNativePlayer(
        url: _videoUrl!,
        autoPlay: true,
        muted: true,
        looping: true,
      );
    } else if (_youtubeController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 1600,
            height: 900,
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: false,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
