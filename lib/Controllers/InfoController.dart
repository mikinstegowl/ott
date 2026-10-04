import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Controllers/InAppPurchaseController.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Models/MagicLinkModel.dart';
import 'package:ottapp/Models/RecommendedModel.dart';
import 'package:ottapp/Models/EpisodeModel.dart';
import 'package:ottapp/Const/AppConstants.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Constants/ShareHelper.dart';
import 'package:ottapp/Widgets/InAppPurchase/InAppPurchaseBottomSheet.dart';

class InfoController extends BaseController {
  final HomeChopperService homeChopperService;
  InfoController({required this.homeChopperService});

  final Rx<InfoModel?> contentData = InfoModel().obs;
  final Rx<RecommendedModel?> recommendedData = RecommendedModel().obs;
  final RxBool showVideo = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxList<Episodes> episodes = <Episodes>[].obs;
  final Rx<Seasons?> selectedSeason = Rx<Seasons?>(null);
  final RxBool isLoadingEpisodes = false.obs;
  final RxString watchNowText = "Watch Now".obs;
  final RxBool isTogglingWatchlist = false.obs;
  final RxBool isPlayingContent = false.obs;

  final RxString fullTrailerUrl = "".obs;
  Timer? _timer;
  String? contentUuid;

  @override
  void onInit() {
    super.onInit();
    contentUuid = Get.arguments as String?;

    // Listen to global subscription changes to update UI
    ever(BaseController.isSubscribed, (_) => _updateWatchNowText());

    if (contentUuid != null) {
      fetchContentDetail(contentUuid!);
      fetchRecommendedContent(contentUuid!);
    } else {
      showLoader(false);
    }
  }

  /// The server's decision for this viewer: what they may do and what they
  /// can buy. Falls back to the old is_free logic when an older API response
  /// carries no access block.
  Access? get access => contentData.value?.data?.access;

  /// Rent / buy buttons to draw. Empty once the viewer can already play.
  List<Offer> get ppvOffers =>
      (access?.canPlay ?? false) ? const [] : (access?.ppvOffers ?? const []);

  /// "Purchased" / "Rented · 36 h left", or null when they own nothing.
  String? get ownershipLabel {
    final p = access?.purchase;
    if (p == null || access?.canPlay != true || access?.mode != 'purchase') {
      return null;
    }
    if (p.type == 'buy') return 'Purchased';
    if (p.startsAt == null) return 'Rented — not started yet';
    final hours = ((p.secondsRemaining ?? 0) / 3600).round();
    return 'Rented · \${hours}h left';
  }

  void _updateWatchNowText() {
    final a = access;

    if (a != null) {
      if (a.canPlay == true) {
        watchNowText.value = "Watch Now";
      } else if (a.hasSubscribe) {
        watchNowText.value = "Subscribe To Watch";
      } else {
        // Pay-per-view only — subscribing would not unlock it, so the primary
        // button must not promise that.
        watchNowText.value = "Rent or Buy To Watch";
      }
      return;
    }

    if (contentData.value?.data?.isFree == false &&
        !BaseController.isSubscribed.value) {
      watchNowText.value = "Subscribe To Watch";
    } else {
      watchNowText.value = "Watch Now";
    }
  }

  /// A rent or buy button was tapped: open the paywall with ONLY that title's
  /// tickets, and remember which title the purchase is for so the server can
  /// attach it to the right content.
  void offerAction(Offer offer) {
    if (isGuest) {
      showLoginDialog();
      return;
    }

    final iap = Get.put(InAppPurchaseController());
    iap.pendingContentUuid = contentUuid;
    iap.pendingLiveUuid = null;

    final ids = ppvOffers
        .map((o) => Platform.isIOS ? o.appleProductId : o.googleProductId)
        .whereType<String>()
        .toList();

    if (ids.isEmpty) {
      Utility.showSnackBar(
        'This title is not available for purchase in the app yet.',
        isError: true,
      );
      return;
    }

    if (Get.context != null && Get.context!.mounted) {
      InAppPurchaseBottomSheet.show(
        Get.context!,
        offerProductIds: ids,
        title: contentData.value?.data?.title,
      );
    }
  }

  Future<void> fetchContentDetail(String uuid) async {
    try {
      showLoader(true);
      final response = await homeChopperService.contentDetailAPI(uuid);
      if (response.isSuccessful && response.body?.data != null) {
        contentData.value = response.body;

        // Update Watch Now text based on subscription and is_free
        _updateWatchNowText();

        if (contentData.value?.data?.trailerUrl != null &&
            (contentData.value?.data?.trailerUrl?.isNotEmpty ?? false)) {
          _startVideoTimer();
        }
        if (contentData.value?.data?.contentType == 'series' &&
            (contentData.value?.data?.seasons?.isNotEmpty ?? false)) {
          selectedSeason.value = contentData.value!.data!.seasons!.first;
          if (contentUuid != null &&
              selectedSeason.value?.seasonNumber != null) {
            fetchEpisodes(contentUuid!, selectedSeason.value!.seasonNumber!);
          }
        }
      }
    } catch (e) {
      Utility.showSnackBar("Failed to load content details", isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  Future<void> fetchRecommendedContent(String uuid) async {
    try {
      final response = await homeChopperService.contentRelatedAPI(uuid);
      if (response.isSuccessful && response.body != null) {
        recommendedData.value = response.body;
      }
    } catch (e) {
      print("Error fetching recommended content: $e");
    }
  }

  Future<void> fetchEpisodes(String uuid, int seasonNumber) async {
    try {
      isLoadingEpisodes.value = true;
      final response = await homeChopperService.getEpisodesAPI(
        uuid,
        seasonNumber,
      );
      if (response.isSuccessful && response.body?.data?.episodes != null) {
        episodes.value = response.body!.data!.episodes!;
      }
    } catch (e) {
      print("Error fetching episodes: $e");
    } finally {
      isLoadingEpisodes.value = false;
    }
  }

  void _stopTrailer() {
    _timer?.cancel();
    _timer = null;
    showVideo.value = false;
    fullTrailerUrl.value = "";
  }

  void onSeasonChanged(Seasons season) {
    if (selectedSeason.value?.id == season.id) return;
    selectedSeason.value = season;
    if (contentUuid != null && season.seasonNumber != null) {
      fetchEpisodes(contentUuid!, season.seasonNumber!);
    }
  }

  MagicLinkModel? magicLinkModel = MagicLinkModel();
  Future<void> magicLinkAPi() async {
    try {
      final response = await homeChopperService.magicLinkAPI(
        Platform.isIOS ? 'ios' : 'android',
      );
      if (response.isSuccessful == true) {
        magicLinkModel = response.body;
      }
    } catch (e) {
      Utility.showSnackBar("Unable to play content", isError: true, response: e);
    }
  }

  Future<void> watchNowAction() async {
    if (contentUuid == null) return;

    if (isGuest) {
      showLoginDialog();
      return;
    }

    // If it's paid, verify subscription status from API
    if (contentData.value?.data?.isFree == false) {
      try {
        isPlayingContent.value = true;
        final subResponse = await homeChopperService.getSubscriptionAPI();
        
        if (subResponse.isSuccessful && subResponse.body != null) {
          final subData = subResponse.body!;
          
          if (subData.hasSubscription == false) {
            if (Get.context != null && Get.context!.mounted) {
              InAppPurchaseBottomSheet.show(Get.context!);
            }
            return;
          }
        }
      } catch (e) {
        print("Error checking subscription: $e");
      } finally {
        isPlayingContent.value = false;
      }
    }

    _stopTrailer(); // Stop trailer before going to full player

    try {
      isPlayingContent.value = true;
      final response = await homeChopperService.playContentAPI(contentUuid!);
      if (response.isSuccessful && response.body != null) {
        if (response.body!.success == true) {
          // Success - proceed to player
          Get.toNamed(
            RoutesName.playerScreen,
            arguments: {'uuid': contentUuid, 'type': 'movie'},
          );
        } else if (response.body!.code == "SUBSCRIPTION_REQUIRED") {
          if (Get.context != null && Get.context!.mounted) {
            InAppPurchaseBottomSheet.show(Get.context!);
          }
        }
      } else {
        Utility.showSnackBar("Unable to play content", isError: true, response: response);
      }
    } catch (e, s) {
      print("Error in playAction: $e");
      print(s);
    } finally {
      isPlayingContent.value = false;
    }
  }

  void playEpisode(Episodes episode) async {
    if (episode.uuid == null) return;

    if (isGuest) {
      showLoginDialog();
      return;
    }

    _stopTrailer(); // Stop trailer before going to full player

    // Check if free or has subscription
    // Assuming episodes also have isFree flag? If not provided, we check play API
    try {
      isPlayingContent.value = true;
      final response = await homeChopperService.playEpisodeAPI(episode.uuid!);
      if (response.isSuccessful && response.body != null) {
        if (response.body!.success == true) {
          // Success - proceed to dedicated player screen
          Get.toNamed(
            RoutesName.playerScreen,
            arguments: {'uuid': episode.uuid, 'type': 'episode'},
          );
        } else if (response.body!.code == "SUBSCRIPTION_REQUIRED") {
          if (Get.context != null && Get.context!.mounted) {
            InAppPurchaseBottomSheet.show(Get.context!);
          }
        }
      } else {
        Utility.showSnackBar("Unable to play episode", isError: true, response: response);
      }
    } catch (e) {
      print("Error in playEpisode: $e");
      Utility.showSnackBar("Unable to play episode", isError: true, response: e);
    } finally {
      isPlayingContent.value = false;
    }
  }

  void _startVideoTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      if (contentData.value?.data?.trailerUrl != null) {
        _initializeVideoPlayer(contentData.value?.data?.trailerUrl ?? '');
      }
    });
  }

  Future<void> _initializeVideoPlayer(String url) async {
    try {
      // The API might return full URLs or relative paths.
      final fullUrl =
          url.startsWith('http') ? url : AppConstants.s3BaseUrl + url;

      fullTrailerUrl.value = fullUrl;
      showVideo.value = true;
      update();
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }
  // Future<void> loadMoreItems(Data section ) async {
  //   if (section.slug == null || section.hasMore == false) return;
  //   if (loadingSections.contains(section.slug)) return;
  //
  //   final currentPage = sectionPages[section.slug!] ?? 1;
  //   final nextPage = currentPage + 1;
  //   final pageSlug = homeModel.value?.data?.page?.slug ?? 'home';
  //
  //   loadingSections.add(section.slug!);
  //   try {
  //     final response = await _homeChopperService.sectionPaginationAPI(
  //       pageSlug,
  //       section.slug??'',
  //       nextPage,
  //       20,
  //     );
  //
  //     if (response.isSuccessful && response.body != null) {
  //       final newSectionData = response.body!.data;
  //       if (newSectionData?.items != null && newSectionData!.items!.isNotEmpty) {
  //         // Find the section in homeModel and add items
  //         final sections = homeModel.value?.data?.sections;
  //         if (sections != null) {
  //           final index = sections.indexWhere((s) => s.slug == section.slug);
  //           if (index != -1) {
  //             if (sections[index].items == null) {
  //               sections[index].items = [];
  //             }
  //             sections[index].items?.addAll(newSectionData.items??[]);
  //             sections[index].hasMore = newSectionData.pagination?.hasMore;
  //             sectionPages[section.slug??''] = nextPage;
  //             homeModel.refresh();
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading more items for ${section.slug}: $e");
  //   } finally {
  //     loadingSections.remove(section.slug);
  //   }
  // }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  Future<void> toggleWatchlist() async {
    final data = contentData.value?.data;
    if (data == null || data.id == null) return;

    if (isGuest) {
      showLoginDialog();
      return;
    }

    final id = data.id!;
    final isAlreadyInWatchlist = data.inWatchlist ?? false;

    try {
      isTogglingWatchlist.value = true;
      final response =
          isAlreadyInWatchlist
              ? await homeChopperService.removeFromWatchlist(id)
              : await homeChopperService.addToWatchlist(id);

      if (response.isSuccessful && response.body != null) {
        final success = response.body!['success'] == true;
        if (success) {
          // Update local state
          contentData.value?.data?.inWatchlist = !isAlreadyInWatchlist;
          contentData.refresh(); // Trigger Obx updates

          Utility.showSnackBar(
            isAlreadyInWatchlist ? "Removed from watchlist" : "Added to watchlist",
            response: response,
          );
        } else {
          Utility.showSnackBar(
            "Action failed",
            isError: true,
            response: response,
          );
        }
      } else {
        Utility.showSnackBar(
          "Something went wrong. Please try again.",
          isError: true,
          response: response,
        );
      }
    } catch (e) {
      print("Error toggling watchlist: $e");
      Utility.showSnackBar(
        "Connection error. Please check your internet.",
        isError: true,
        response: e,
      );
    } finally {
      isTogglingWatchlist.value = false;
    }
  }

  void shareContent() {
    final shareData = contentData.value?.data?.share;
    if (shareData != null && shareData.url != null) {
      ShareHelper.shareNative(shareData: shareData);
    } else {
      Utility.showSnackBar("Share link not available", isError: true);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
