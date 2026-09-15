import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Models/MyWatchListModel.dart' hide Data;
import 'package:ottapp/Models/ShortsListModel.dart';
import 'package:ottapp/Router/RouterName.dart';

class WatchlistController extends GetxController {
  final HomeChopperService homeChopperService;
  WatchlistController({required this.homeChopperService});

  final RxInt selectedTab = 0.obs;
  final RxList<Items> watchlistItems = <Items>[].obs;
  final RxList<Data> shortsWatchlistItems = <Data>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<Pagination?> pagination = Rxn<Pagination>();
  
  final ScrollController scrollController = ScrollController();
  final ScrollController shortsScrollController = ScrollController();
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchWatchlist();
    
    // Setup pagination listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && (pagination.value?.hasMore ?? false)) {
          fetchMoreWatchlist();
        }
      }
    });
  }

  Future<void> fetchWatchlist() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      final response = await homeChopperService.getWatchListAPI(_currentPage, 20);
      
      if (response.isSuccessful && response.body?.data != null) {
        watchlistItems.value = response.body?.data?.items ?? [];
        pagination.value = response.body?.data?.pagination;
      }
    } catch (e) {
      print("Error fetching watchlist: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchShortlist() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      final response = await homeChopperService.getShortsListAPI();

      if (response.isSuccessful && response.body?.data != null) {
        shortsWatchlistItems.value = response.body?.data ?? [];

      }
    } catch (e) {
      print("Error fetching watchlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreWatchlist() async {
    try {
      isLoadingMore.value = true;
      _currentPage++;
      final response = await homeChopperService.getWatchListAPI(_currentPage, 20);
      
      if (response.isSuccessful && response.body?.data?.items != null) {
        watchlistItems.addAll(response.body!.data!.items!);
        pagination.value = response.body!.data!.pagination;
      }
    } catch (e) {
      print("Error fetching more watchlist: $e");
      _currentPage--; // Revert page on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void goToDetails(Items item) {
    if (item.content?.uuid != null) {
      Get.toNamed(RoutesName.infoScreen, arguments: item.content!.uuid);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    shortsScrollController.dispose();
    super.onClose();
  }
}
