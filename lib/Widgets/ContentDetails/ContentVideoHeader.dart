import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ottapp/Widgets/Player/CommonNativePlayer.dart';
import 'package:ottapp/Constants/AppNetworkImage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContentVideoHeader extends StatefulWidget {
  final String? imageUrl;
  final String? trailerUrl;
  final bool showVideo;
  final double? height;

  const ContentVideoHeader({
    super.key,
    this.imageUrl,
    this.trailerUrl,
    required this.showVideo,
    this.height,
  });

  @override
  State<ContentVideoHeader> createState() => _ContentVideoHeaderState();
}

class _ContentVideoHeaderState extends State<ContentVideoHeader> {
  YoutubePlayerController? _youtubeController;
  String? _youtubeId;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _checkYoutube();
  }

  @override
  void didUpdateWidget(ContentVideoHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trailerUrl != widget.trailerUrl ||
        oldWidget.showVideo != widget.showVideo) {
      _checkYoutube();
    }
  }

  void _checkYoutube() {
    if (widget.showVideo &&
        widget.trailerUrl != null &&
        (widget.trailerUrl!.contains('youtube.com') ||
            widget.trailerUrl!.contains('youtu.be'))) {
      final id = YoutubePlayer.convertUrlToId(widget.trailerUrl!);
      if (id != null) {
        setState(() {
          _youtubeId = id;
          _youtubeController = YoutubePlayerController(
            initialVideoId: id,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              loop: true,
              controlsVisibleAtStart: false,
              hideControls: true,
              disableDragSeek: true,
              showLiveFullscreenButton: false,
            ),
          );
        });
      }
    } else {
      setState(() {
        _youtubeId = null;
        _youtubeController?.dispose();
        _youtubeController = null;
      });
    }
  }

  void _stopPlayback() {
    _youtubeController?.pause();
    // For native players, we might need a controller reference if we were using one here.
    // However, CommonNativePlayer currently handles its own state.
    // We pass 'showVideo' which effectively controls its build.
    if (mounted) setState(() => _isVisible = false);
  }

  void _resumePlayback() {
    if (mounted) setState(() => _isVisible = true);
    _youtubeController?.play();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('info-header-${widget.trailerUrl}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction < 0.1) {
          _stopPlayback();
        } else if (info.visibleFraction > 0.8) {
          _resumePlayback();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height:  widget.height ?? 250.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.showVideo && widget.trailerUrl != null && _isVisible)
              _youtubeId != null && _youtubeController != null
                  ? YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: false,
                    )
                  : CommonNativePlayer(
                      url: widget.trailerUrl ?? '',
                      autoPlay: true,
                      muted: false,
                      looping: true,
                    )
            else
              Hero(
                tag: 'player-hero',
                child: AppNetworkImage(
                  imageUrl: widget.imageUrl ?? '',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            // Bottom Gradient for better transition and legibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
