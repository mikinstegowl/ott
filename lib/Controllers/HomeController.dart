import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/GetAllGenreModel.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Models/ProfileModel.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:ottapp/Models/MenuModel.dart';
import 'package:ottapp/Models/MagicLinkModel.dart';

import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Models/SubscriptionModel.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends BaseController with WidgetsBindingObserver {
  final HomeChopperService _homeChopperService;
  final AuthChopperService _authChopperService;

  HomeController({
    required HomeChopperService homeChopperService,
    required AuthChopperService authChopperService,
  }) : _homeChopperService = homeChopperService,
       _authChopperService = authChopperService;

  final Rx<HomeModel?> homeModel = Rx<HomeModel?>(null);
  final RxList<MenuModel> menus = <MenuModel>[].obs;
  final RxString selectedPageSlug = 'home'.obs;
  final Rx<GetAllGenreModel?> getAllGenreModel = GetAllGenreModel().obs;
  final Rx<ProfileModel?> planName = ProfileModel().obs;
  final Rx<SubscriptionModel?> subscriptionModel = Rx<SubscriptionModel?>(null);
  final RxMap<String, int> sectionPages = <String, int>{}.obs;
  final RxSet<String> loadingSections = <String>{}.obs;
  final RxInt currentSectionPage = 1.obs;
  final RxBool isMoreSectionsLoading = false.obs;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fcmAPI();
    getHeaderMenus();
    getHomeData();
    fetchUserProfile();
    fetchSubscription();
    scrollController.addListener(_scrollListener);
    print("user token${UserPreference.getValue(key: PrefKeys.logInToken)}");
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 1200) {
      loadMoreSections();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log("App Resumed: Refreshing subscription status and FCM token...");
      fetchSubscription();
      fcmAPI();
    }
  }

  Future<void> fetchSubscription() async {
    try {
      final response = await _authChopperService.getSubscriptionAPI();
      if (response.isSuccessful && response.body != null) {
        subscriptionModel.value = response.body;

        // Update global subscription status correctly
        final subscribed = subscriptionModel.value?.hasSubscription ?? false;
        BaseController.isSubscribed.value = subscribed;
        await UserPreference.setValue(
          key: PrefKeys.subscriptionStatus,
          value: subscribed,
        );
        update();

        log("Subscription status refreshed: $subscribed");
      }
    } catch (e) {
      log("Error fetching subscription: $e");
    }
  }

  @override
  Future<void> fetchUserProfile() async {
    if (isGuest) return;
    try {
      final response = await _authChopperService.getMeAPI();
      if (response.isSuccessful && response.body != null) {
        planName.value = response.body;
        profileData.value = response.body;
      } else {
        Utility.showSnackBar('Failed to load user profile', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    }
  }

  Future<void> fcmAPI({String? newToken}) async {
    try {
      String? token = newToken;

      if (token == null) {
        if (Platform.isIOS) {
          // On iOS, we must ensure APNS token is available before FCM token
          String? apnsToken;
          for (int i = 0; i < 10; i++) {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) break;
            await Future.delayed(const Duration(milliseconds: 500));
          }
          log("APNS Token: $apnsToken");
        }
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token == null) {
        log("FCM Token is null, skipping API call");
        return;
      }

      final param = {
        "token": token,
        "platform": Platform.isIOS ? 'ios' : 'android',
        "device_name": Platform.isIOS ? 'ios' : 'android',
      };

      log("Sending FCM Token to backend: $param");
      final response = await _homeChopperService.fcmTokenAPI(param);
      if (response.isSuccessful) {
        log("FCM Token registered successfully");
      } else {
        log("Failed to register FCM Token: ${response.error}");
      }
    } catch (e) {
      log('Error in fcmAPI: $e');
    }
  }

  final Rxn<MagicLinkModel> magicLinkModel = Rxn<MagicLinkModel>();
  Future<void> magicLinkAPi() async {
    try {
      final response = await _homeChopperService.magicLinkAPI(
        Platform.isIOS ? 'ios' : 'android',
      );
      if (response.isSuccessful == true) {
        magicLinkModel.value = response.body;
      }
    } catch (e) {
      Utility.showSnackBar("Unable to play content", isError: true);
    }
  }

  Future<void> supportAction() async {
    if (isGuest) {
      final Uri url = Uri.parse("https://trebolplus.com/contact-support");
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Utility.showSnackBar("Could not launch support page", isError: true);
      }
      return;
    }

    showLoader(true);
    try {
      final param = {"redirect": "/support"};
      final response = await _homeChopperService.supportMagicLinkAPI(
        Platform.isIOS ? 'ios' : 'android',
        param,
      );
      if (response.isSuccessful && response.body != null) {
        final magicUrl = response.body?.data?.magicUrl;
        if (magicUrl != null && magicUrl.isNotEmpty) {
          final Uri url = Uri.parse(magicUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            Utility.showSnackBar("Could not launch support page", isError: true);
          }
        } else {
          Utility.showSnackBar("Unable to get support link", isError: true);
        }
      } else {
        Utility.showSnackBar("Unable to get support link", isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar("Unable to get support link", isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  Future<void> getHeaderMenus() async {
    try {
      final response = await _homeChopperService.getHeaderMenusAPI('header');
      if (response.isSuccessful && response.body != null) {
        menus.assignAll(response.body!);
      }
    } catch (e) {
      print("Error fetching menus: $e");
    }
  }

  Future<void> getHomeData({String? slug}) async {
    if (slug != null) {
      selectedPageSlug.value = slug;
      // Reset sections pagination when page changes
      sectionPages.clear();
      homeModel.value = null;
    }
    showLoader(true);
    currentSectionPage.value = 1;
    try {
      final response = await _homeChopperService.getPageDataAPI(
        selectedPageSlug.value,
        1,
        10,
      );

      if (response.isSuccessful && response.body != null) {
        homeModel.value = response.body;
        getAllGenreAPI();
        // Initialize pages for sections
        if (homeModel.value?.data?.sections != null) {
          for (var section in homeModel.value!.data!.sections!) {
            if (section.slug != null) {
              sectionPages[section.slug ?? 'shorts'] = 1;
            }
          }
        }
        print(
          "user token ${UserPreference.getValue(key: PrefKeys.logInToken)}",
        );
      } else {
        Utility.showSnackBar('Failed to load home data', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  Future<void> loadMoreSections() async {
    if (isMoreSectionsLoading.value ||
        homeModel.value?.data?.sectionPagination?.hasMore == false) {
      return;
    }

    isMoreSectionsLoading.value = true;
    final nextPage = currentSectionPage.value + 1;

    try {
      final response = await _homeChopperService.getPageDataAPI(
        selectedPageSlug.value,
        nextPage,
        10,
      );

      if (response.isSuccessful && response.body != null) {
        final newHomeData = response.body!.data;
        if (newHomeData?.sections != null &&
            newHomeData!.sections!.isNotEmpty) {
          // Re-create sections list to avoid flickering/concurrency issues during scroll
          final List<Sections> updatedSections = [
            ...(homeModel.value?.data?.sections ?? []),
            ...newHomeData.sections!,
          ];
          homeModel.value?.data?.sections = updatedSections;
          homeModel.value?.data?.sectionPagination =
              newHomeData.sectionPagination;
          currentSectionPage.value = nextPage;

          // Initialize pages for new sections
          for (var section in newHomeData.sections!) {
            if (section.slug != null) {
              sectionPages[section.slug ?? ''] = 1;
            }
          }
          homeModel.refresh();
        }
      }
    } catch (e) {
      print("Error loading more sections: $e");
    } finally {
      isMoreSectionsLoading.value = false;
    }
  }

  Future<void> getAllGenreAPI() async {
    showLoader(true);
    try {
      final response = await _homeChopperService.getAllGenreAPI();

      if (response.isSuccessful && response.body != null) {
        getAllGenreModel.value = response.body;
        // Initialize pages for sections
        // if (getAllGenreModel.value?.data != null) {
        //   for (var section in getAllGenreModel.value?.data ?? []) {
        //     if (section.slug != null) {
        //       sectionPages[section.slug??''] = 1;
        //     }
        //   }
        // }
      } else {
        Utility.showSnackBar('Failed to load home data', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  Future<void> loadMoreItems(Sections section) async {
    if (section.slug == null || section.hasMore == false) return;
    if (loadingSections.contains(section.slug)) return;

    final currentPage = sectionPages[section.slug!] ?? 1;
    final nextPage = currentPage + 1;
    final pageSlug = homeModel.value?.data?.page?.slug ?? 'home';

    loadingSections.add(section.slug!);
    try {
      final response = await _homeChopperService.sectionPaginationAPI(
        pageSlug,
        section.slug ?? '',
        nextPage,
        20,
      );

      if (response.isSuccessful && response.body != null) {
        final newSectionData = response.body!.data;
        if (newSectionData?.items != null &&
            newSectionData!.items!.isNotEmpty) {
          // Find the section in homeModel and add items
          final sections = homeModel.value?.data?.sections;
          if (sections != null) {
            final index = sections.indexWhere((s) => s.slug == section.slug);
            if (index != -1) {
              if (sections[index].items == null) {
                sections[index].items = [];
              }
              sections[index].items?.addAll(newSectionData.items ?? []);
              sections[index].hasMore = newSectionData.pagination?.hasMore;
              sectionPages[section.slug ?? ''] = nextPage;
              homeModel.refresh();
            }
          }
        }
      }
    } catch (e) {
      print("Error loading more items for ${section.slug}: $e");
    } finally {
      loadingSections.remove(section.slug);
    }
  }
}
