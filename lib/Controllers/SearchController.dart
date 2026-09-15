import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/ContentTypeModel.dart';
import 'package:ottapp/Models/GetAllGenreModel.dart' as genre_model;
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Models/SearchResponseModel.dart';
import 'package:ottapp/Models/SuggestionResponseModel.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class MySearchController extends BaseController {
  final HomeChopperService _homeService = AppChopperClient().getChopperService<HomeChopperService>();

  // Search State
  final RxString searchQuery = "".obs;
  final RxList<ContentTypeData> contentTypes = <ContentTypeData>[].obs;
  final RxList<genre_model.Data> genres = <genre_model.Data>[].obs;
  
  // Filtering & Sorting
  final Rx<ContentTypeData?> selectedType = Rxn<ContentTypeData>();
  final Rx<genre_model.Data?> selectedGenre = Rxn<genre_model.Data>();
  final RxString currentSort = "popularity".obs;
  
  // Results & Suggestions
  final RxList<Items> searchResults = <Items>[].obs;
  final RxList<Items> suggestions = <Items>[].obs;
  final RxList<Items> contentSuggestions = <Items>[].obs;
  final RxList<Items> shortsSuggestions = <Items>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool showSuggestions = false.obs;
  final RxBool isSuggestionsLoading = false.obs;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  final RxBool isLoadingMore = false.obs;
  
  Timer? _debounceTimer;
  final TextEditingController searchFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    
    // Setup scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && _hasMore) {
          loadMoreResults();
        }
      }
    });
  }

  Future<void> fetchInitialData() async {
    showLoader(true);
    try {
      final responses = await Future.wait([
        _homeService.getContentTypesAPI(),
        _homeService.getAllGenreAPI(),
      ]);

      if (responses[0].isSuccessful && responses[0].body != null) {
        contentTypes.value = (responses[0].body as ContentTypeModel).data ?? [];
      }
      
      if (responses[1].isSuccessful && responses[1].body != null) {
        genres.value = (responses[1].body as genre_model.GetAllGenreModel).data ?? [];
      }
    } catch (e) {
      print("SearchController: Error fetching initial data: $e");
    } finally {
      showLoader(false);
    }
  }

  void onSearchTextChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      suggestions.clear();
      contentSuggestions.clear();
      shortsSuggestions.clear();
      showSuggestions.value = false;
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchSuggestions(query);
    });
  }

  Future<void> fetchSuggestions(String query) async {
    isSuggestionsLoading.value = true;
    print("SearchController: Fetching suggestions for: $query");
    try {
      final response = await _homeService.getSearchSuggestionsAPI(query);
      if (response.isSuccessful && response.body != null) {
        final suggestionModel = response.body as SuggestionResponseModel;
        final newSuggestions = suggestionModel.data ?? [];
        final newContents = suggestionModel.suggestionData?.contents ?? [];
        final newShorts = suggestionModel.suggestionData?.shorts ?? [];

        contentSuggestions.assignAll(newContents);
        shortsSuggestions.assignAll(newShorts);
        suggestions.assignAll(newSuggestions);

        print("SearchController: Found ${suggestions.length} suggestions (contents: ${newContents.length}, shorts: ${newShorts.length})");
        showSuggestions.value = suggestions.isNotEmpty;
      } else {
        print("SearchController: API Error ${response.statusCode}: ${response.error}");
      }
    } catch (e) {
      print("SearchController: Exception fetching suggestions: $e");
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

  void performSearch({bool isNewSearch = true}) async {
    if (isNewSearch) {
      _currentPage = 1;
      _hasMore = true;
      searchResults.clear();
      isSearching.value = true;
      showSuggestions.value = false;
      showLoader(true);
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await _homeService.searchContentAPI(
        searchQuery.value.isEmpty ? null : searchQuery.value,
        selectedType.value?.slug,
        selectedGenre.value?.slug,
        currentSort.value,
        _currentPage,
        20,
      );

      if (response.isSuccessful && response.body != null) {
        final data = (response.body as SearchResponseModel).data;
        if (data != null && data.items != null) {
          if (isNewSearch) {
            searchResults.value = data.items!;
          } else {
            searchResults.addAll(data.items!);
          }
          _hasMore = data.pagination?.hasMore ?? false;
          _currentPage++;
        }
      }
    } catch (e) {
      print("SearchController: Error performing search: $e");
    } finally {
      showLoader(false);
      isLoadingMore.value = false;
    }
  }

  void loadMoreResults() {
    performSearch(isNewSearch: false);
  }

  void onTypeSelected(ContentTypeData? type) {
    if (selectedType.value?.slug == type?.slug) return; // Already selected
    
    selectedType.value = type;
    selectedType.refresh(); // Force GetX to notify all listeners

    performSearch();
    update();
  }

  void onGenreSelected(genre_model.Data genre) {
    selectedGenre.value = genre;
    isSearching.value = true;
    performSearch();
  }

  void onSortChanged(String sort) {
    currentSort.value = sort;
    performSearch();
  }

  void clearFilters() {
    selectedType.value = null;
    selectedGenre.value = null;
    currentSort.value = "popularity";
    selectedType.refresh();
    
    if (searchQuery.value.isEmpty) {
      isSearching.value = false;
      fetchInitialData(); // This hits the /genres API as requested
    } else {
      performSearch();
    }
    update();
  }

  void clearSearch() {
    searchFieldController.clear();
    searchQuery.value = "";
    selectedType.value = null;
    selectedGenre.value = null;
    isSearching.value = false;
    showSuggestions.value = false;
    searchResults.clear();
    suggestions.clear();
    contentSuggestions.clear();
    shortsSuggestions.clear();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchFieldController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
