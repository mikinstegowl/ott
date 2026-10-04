// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'HomeChopperService.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$HomeChopperService extends HomeChopperService {
  _$HomeChopperService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = HomeChopperService;

  @override
  Future<Response<dynamic>> appProducts(String platform) {
    final Uri $url = Uri.parse('app/products');
    final Map<String, dynamic> $params = <String, dynamic>{
      'platform': platform,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> verifyAppPurchase(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('app/purchase/verify');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> restoreAppPurchases(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('app/purchase/restore');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<WatchHistoryResponse>> syncWatchHistory(
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('watch-history/sync');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<WatchHistoryResponse, WatchHistoryResponse>($request);
  }

  @override
  Future<Response<FcmModel>> fcmTokenAPI(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('device-tokens');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<FcmModel, FcmModel>($request);
  }

  @override
  Future<Response<MagicLinkModel>> magicLinkAPI(String platform) {
    final Uri $url = Uri.parse('auth/magic-link');
    final Map<String, String> $headers = {'X-Platform': platform};
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<MagicLinkModel, MagicLinkModel>($request);
  }

  @override
  Future<Response<MagicLinkModel>> supportMagicLinkAPI(
    String platform,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('auth/magic-link');
    final Map<String, String> $headers = {'X-Platform': platform};
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<MagicLinkModel, MagicLinkModel>($request);
  }

  @override
  Future<Response<HomeModel>> getPageDataAPI(
    String pageSlug,
    int sectionPage,
    int sectionPerPage,
  ) {
    final Uri $url = Uri.parse('pages/${pageSlug}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'section_page': sectionPage,
      'section_per_page': sectionPerPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<HomeModel, HomeModel>($request);
  }

  @override
  Future<Response<GetAllGenreModel>> getAllGenreAPI() {
    final Uri $url = Uri.parse('genres');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<GetAllGenreModel, GetAllGenreModel>($request);
  }

  @override
  Future<Response<InfoModel>> contentDetailAPI(String uuid) {
    final Uri $url = Uri.parse('contents/${uuid}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<InfoModel, InfoModel>($request);
  }

  @override
  Future<Response<RecommendedModel>> contentRelatedAPI(String uuid) {
    final Uri $url = Uri.parse('contents/${uuid}/related');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<RecommendedModel, RecommendedModel>($request);
  }

  @override
  Future<Response<SectionPaginationModel>> sectionPaginationAPI(
    String pageSlug,
    String sectionSlug,
    int page,
    int perPage,
  ) {
    final Uri $url = Uri.parse('pages/${pageSlug}/sections/${sectionSlug}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SectionPaginationModel, SectionPaginationModel>(
      $request,
    );
  }

  @override
  Future<Response<EpisodeModel>> getEpisodesAPI(String uuid, int seasonNumber) {
    final Uri $url = Uri.parse(
      'contents/${uuid}/seasons/${seasonNumber}/episodes',
    );
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<EpisodeModel, EpisodeModel>($request);
  }

  @override
  Future<Response<PlayResponseModel>> playContentAPI(String uuid) {
    final Uri $url = Uri.parse('contents/${uuid}/play');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<PlayResponseModel, PlayResponseModel>($request);
  }

  @override
  Future<Response<PlayResponseModel>> playEpisodeAPI(String uuid) {
    final Uri $url = Uri.parse('episodes/${uuid}/play');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<PlayResponseModel, PlayResponseModel>($request);
  }

  @override
  Future<Response<List<MenuModel>>> getHeaderMenusAPI(String placement) {
    final Uri $url = Uri.parse('menus');
    final Map<String, dynamic> $params = <String, dynamic>{
      'placement': placement,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<MenuModel>, MenuModel>($request);
  }

  @override
  Future<Response<LiveVideoModel>> getLiveVideoAPI() {
    final Uri $url = Uri.parse('live-video');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<LiveVideoModel, LiveVideoModel>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> addToWatchlist(int id) {
    final Uri $url = Uri.parse('watchlist/${id}');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> removeFromWatchlist(int id) {
    final Uri $url = Uri.parse('watchlist/${id}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<MyWatchListModel>> getWatchListAPI(int page, int perPage) {
    final Uri $url = Uri.parse('watchlist');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<MyWatchListModel, MyWatchListModel>($request);
  }

  @override
  Future<Response<ShortsListModel>> getShortsListAPI() {
    final Uri $url = Uri.parse('shorts/saved');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<ShortsListModel, ShortsListModel>($request);
  }

  @override
  Future<Response<ContentTypeModel>> getContentTypesAPI() {
    final Uri $url = Uri.parse('content-types');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<ContentTypeModel, ContentTypeModel>($request);
  }

  @override
  Future<Response<SearchResponseModel>> searchContentAPI(
    String? query,
    String? contentType,
    String? genreSlug,
    String? sort,
    int page,
    int perPage,
  ) {
    final Uri $url = Uri.parse('search');
    final Map<String, dynamic> $params = <String, dynamic>{
      'q': query,
      'type': contentType,
      'genre': genreSlug,
      'sort': sort,
      'page': page,
      'per_page': perPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SearchResponseModel, SearchResponseModel>($request);
  }

  @override
  Future<Response<SuggestionResponseModel>> getSearchSuggestionsAPI(
    String query,
  ) {
    final Uri $url = Uri.parse('search/suggestions');
    final Map<String, dynamic> $params = <String, dynamic>{'q': query};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SuggestionResponseModel, SuggestionResponseModel>(
      $request,
    );
  }

  @override
  Future<Response<SubscriptionModel>> getSubscriptionAPI() {
    final Uri $url = Uri.parse('subscription');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<SubscriptionModel, SubscriptionModel>($request);
  }

  @override
  Future<Response<ShortDramaModel>> getShortDramaDetailAPI(String slug) {
    final Uri $url = Uri.parse('shorts/${slug}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<ShortDramaModel, ShortDramaModel>($request);
  }

  @override
  Future<Response<PlayResponseModel>> playShortEpisodeAPI(String uuid) {
    final Uri $url = Uri.parse('shorts/episodes/${uuid}/play');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<PlayResponseModel, PlayResponseModel>($request);
  }

  @override
  Future<Response<ShortsProgressResponseModel>> syncShortProgress(
    ShortsProgressRequestModel body,
  ) {
    final Uri $url = Uri.parse('shorts/progress');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<ShortsProgressResponseModel, ShortsProgressResponseModel>(
          $request,
        );
  }

  @override
  Future<Response<ShortActionResponseModel>> likeShortEpisodeAPI(String uuid) {
    final Uri $url = Uri.parse('shorts/episodes/${uuid}/like');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<ShortActionResponseModel, ShortActionResponseModel>(
      $request,
    );
  }

  @override
  Future<Response<ShortActionResponseModel>> unlikeShortEpisodeAPI(
    String uuid,
  ) {
    final Uri $url = Uri.parse('shorts/episodes/${uuid}/like');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<ShortActionResponseModel, ShortActionResponseModel>(
      $request,
    );
  }

  @override
  Future<Response<ShortActionResponseModel>> bookmarkShortAPI(String slug) {
    final Uri $url = Uri.parse('shorts/${slug}/bookmark');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<ShortActionResponseModel, ShortActionResponseModel>(
      $request,
    );
  }

  @override
  Future<Response<ShortActionResponseModel>> unbookmarkShortAPI(String slug) {
    final Uri $url = Uri.parse('shorts/${slug}/bookmark');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<ShortActionResponseModel, ShortActionResponseModel>(
      $request,
    );
  }
}
