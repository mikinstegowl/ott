import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/SplashController.dart';

/// The first screen: what is on now, and who is watching.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          Expanded(child: _Promo(controller: controller)),
          _ProfilePicker(controller: controller),
        ],
      ),
    );
  }
}

/// The rotating artwork. Fades into the page so the profile below feels part
/// of the same screen rather than a panel stuck underneath.
class _Promo extends StatelessWidget {
  const _Promo({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.slides.isEmpty) {
        return const SizedBox.expand();
      }

      final slide = controller.slides[controller.index.value];

      return Stack(
        fit: StackFit.expand,
        children: [
          // One slide dissolves into the next while drifting slowly closer.
          // A slide-across reads as a carousel the viewer is meant to operate;
          // this reads as a backdrop, which is what it is.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: _KenBurns(
              key: ValueKey(slide.id),
              imageUrl: slide.image,
              // Match the drift to how long the slide is up, so the movement
              // never stops early and sits still.
              duration: Duration(
                milliseconds: controller.durationFor(slide) + 1400,
              ),
            ),
          ),

          // Reads over any artwork, bright or dark.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.black],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 26.h,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (slide.hasText) ...[
                    if (slide.headline?.isNotEmpty ?? false)
                      Text(
                        slide.headline!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    if (slide.subheadline?.isNotEmpty ?? false)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          slide.subheadline!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// One slide, drifting slowly closer while it is on screen.
class _KenBurns extends StatefulWidget {
  const _KenBurns({
    super.key,
    required this.imageUrl,
    required this.duration,
  });

  final String imageUrl;
  final Duration duration;

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.08,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.linear));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        errorWidget: (_, __, ___) => const SizedBox.expand(),
        placeholder: (_, __) => const SizedBox.expand(),
      ),
    );
  }
}

/// One profile, because one account is one person here.
///
/// There is no heading: "choose your profile" asks a question that has only
/// one answer. The tile is the whole invitation.
class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    final rise = 54.h;

    return SizedBox(
      height: 300.h,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SheetPainter(rise: rise))),

          // Centred in the panel below the curve, not pinned under it.
          Positioned(
            left: 0,
            right: 0,
            top: rise,
            bottom: 0,
            child: Center(
              child: Obx(
                () => _ProfileTile(
                  name: controller.profileName,
                  initial: controller.profileInitial,
                  avatar: controller.profileAvatar,
                  onTap: controller.enter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The panel's curved top.
///
/// A border radius cannot do this: an elliptical corner wide enough to span
/// the screen still meets the sides at an angle, which shows as a kink at both
/// ends. A curve that starts on the edge and leans into the middle meets the
/// sides smoothly, which is what the reference does.
class _SheetPainter extends CustomPainter {
  const _SheetPainter({required this.rise});

  /// How far the middle of the curve sits above its ends.
  final double rise;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, rise)
      ..quadraticBezierTo(size.width / 2, -rise * 0.15, size.width, rise)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Starts at the artwork's black and lifts to the sheet colour, so the join
    // reads as the panel rising out of the picture.
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF151517), Color(0xFF2E2E33)],
        stops: [0.0, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SheetPainter old) => old.rise != rise;
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.initial,
    required this.avatar,
    required this.onTap,
  });

  final String name;
  final String initial;
  final String? avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final side = 80.w;
    final radius = 16.r;

    return Semantics(
      button: true,
      label: 'Continue as $name',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  color: AppColors.appColors,
                  borderRadius: BorderRadius.circular(radius),
                  image: (avatar != null && avatar!.isNotEmpty)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: (avatar == null || avatar!.isEmpty)
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: side + 40.w,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
