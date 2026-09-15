import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Center Play/Pause button with frosted glass effect and optical centering
class ReelCenterPlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const ReelCenterPlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76.w,
        height: 76.h,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Padding(
            // Optical centering for the play triangle
            padding: EdgeInsets.only(left: isPlaying ? 0.0 : 4.w),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 44.sp,
            ),
          ),
        ),
      ),
    );
  }
}
