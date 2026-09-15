import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ottapp/Screens/HomeScreen.dart';
import 'package:ottapp/Screens/ProfileScreen.dart';
import 'package:ottapp/Screens/LiveVideoScreen.dart';
import 'package:ottapp/Screens/SearchScreen.dart';

import 'package:ottapp/Controllers/HomeController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

class MainWrapperController extends GetxController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;
  final RxBool isLiveVideoActive = false.obs;
  Timer? _liveVideoTimer;
  bool _isChecking = false;

  bool get isGuest => UserPreference.getValue(key: PrefKeys.skipUser) == true;

  List<Widget> get screens {
    final List<Widget> screens = [const HomeScreen()];

    if (isLiveVideoActive.value) {
      screens.add(const LiveVideoScreen());
    }

    screens.add(const SearchScreen());

    if (!isGuest) {
      screens.add(const ProfileScreen());
    }

    return screens;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkLiveVideo();
    _startPolling();
  }

  void _startPolling() {
    // Check every 60 seconds
    _liveVideoTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkLiveVideo();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLiveVideo();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveVideoTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkLiveVideo() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final homeService =
          AppChopperClient().getChopperService<HomeChopperService>();
      final response = await homeService.getLiveVideoAPI();
      if (response.isSuccessful && response.body != null) {
        if (response.body?.data?.isActive == true) {
          isLiveVideoActive.value = true;
        } else {
          isLiveVideoActive.value = false;
          if (currentIndex.value >= screens.length) {
            currentIndex.value = screens.length - 1;
          }
        }
      }
    } catch (e) {
      isLiveVideoActive.value = false;
      debugPrint("Error checking live video status: $e");
    } finally {
      _isChecking = false;
    }
  }

  void changePage(int index) {
    if (index == 0) {
      try {
        final homeController = Get.find<HomeController>();
        if (homeController.selectedPageSlug.value != 'home') {
          // Reset to default home content whether coming from same tab or another tab
          homeController.getHomeData(slug: 'home');
        } else if (currentIndex.value == 0) {
          // Already on default home and we were already on home tab, scroll to top
          if (homeController.scrollController.hasClients) {
            homeController.scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      } catch (e) {
        // Safe fallback if HomeController isn't initialized
      }
    }
    currentIndex.value = index;
  }
}
