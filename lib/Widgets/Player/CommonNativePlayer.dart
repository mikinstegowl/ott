import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CommonNativePlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final bool muted;
  final BoxFit fit;
  final VoidCallback? onReady;

  const CommonNativePlayer({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.looping = true,
    this.muted = true,
    this.fit = BoxFit.cover,
    this.onReady,
  });

  @override
  State<CommonNativePlayer> createState() => _CommonNativePlayerState();
}

class _CommonNativePlayerState extends State<CommonNativePlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Referer': 'https://tr3bolplus.com/',
        },
      );

      await _controller!.initialize();
      
      if (mounted) {
        _controller!.setVolume(widget.muted ? 0.0 : 1.0);
        _controller!.setLooping(widget.looping);
        if (widget.autoPlay) {
          await _controller!.play();
        }
        
        setState(() {
          _isInitialized = true;
        });
        widget.onReady?.call();
      }
    } catch (e) {
      debugPrint("CommonNativePlayer (VideoPlayer) Error: $e");
    }
  }

  @override
  void didUpdateWidget(CommonNativePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
