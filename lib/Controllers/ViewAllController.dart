import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/SectionPaginationModel.dart';
import 'package:ottapp/Models/HomeModel.dart';

class ViewAllController extends BaseController {
  final HomeChopperService _homeChopperService;

  ViewAllController({required HomeChopperService homeChopperService})
      : _homeChopperService = homeChopperService;

  final Rx<SectionData?> sectionData = Rx<SectionData?>(null);
  final RxList<Items> items = <Items>[].obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = false.obs;
  final RxBool isLoadingMore = false.obs;

  late String pageSlug;
  late String sectionSlug;
  late String title;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    pageSlug = args['pageSlug'] ?? 'home';
    sectionSlug = args['sectionSlug'] ?? '';
    title = args['title'] ?? '';
    getSectionData();
  }

  Future<void> getSectionData() async {
    showLoader(true);
    items.clear();
    currentPage.value = 1;
    try {
      final response = await _homeChopperService.sectionPaginationAPI(
        pageSlug,
        sectionSlug,
        currentPage.value,
        20,
      );

      if (response.isSuccessful && response.body != null) {
        sectionData.value = response.body!.data;
        if (sectionData.value?.items != null) {
          items.addAll(sectionData.value!.items!);
        }
        hasMore.value = sectionData.value?.pagination?.hasMore ?? false;
      } else {
        Utility.showSnackBar('Failed to load section data', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  Future<void> loadMoreItems() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final response = await _homeChopperService.sectionPaginationAPI(
        pageSlug,
        sectionSlug,
        nextPage,
        20,
      );

      if (response.isSuccessful && response.body != null) {
        final newSectionData = response.body!.data;
        if (newSectionData?.items != null && newSectionData!.items!.isNotEmpty) {
          items.addAll(newSectionData.items!);
          currentPage.value = nextPage;
          hasMore.value = newSectionData.pagination?.hasMore ?? false;
        }
      }
    } catch (e) {
      print("Error loading more items for $sectionSlug: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }
}
