import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/PlayerController.dart';
import 'package:ottapp/Widgets/Player/AppVideoPlayerView.dart';

class PlayerScreen extends GetView<PlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use PopScope to handle the system back button smoothly
    return PopScope(
      canPop: false, // We handle the pop manually via exitPlayer
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        controller.exitPlayer();
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: AppVideoPlayerView(
          controller: controller,
        ),
      ),
    );
  }
}
