import 'package:chopper/chopper.dart';
import 'package:ottapp/Models/FcmModel.dart';
import 'package:ottapp/Models/GetAllGenreModel.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Models/MagicLinkModel.dart';
import 'package:ottapp/Models/RecommendedModel.dart';
import 'package:ottapp/Models/SectionPaginationModel.dart';
import 'package:ottapp/Models/EpisodeModel.dart';
import 'package:ottapp/Models/PlayResponseModel.dart';
import 'package:ottapp/Models/MenuModel.dart';
import 'package:ottapp/Models/ShortsListModel.dart';
import 'package:ottapp/Models/SubscriptionModel.dart';
import 'package:ottapp/Models/WatchHistoryModel.dart';
import 'package:ottapp/Models/LiveVideoModel.dart';
import 'package:ottapp/Models/MyWatchListModel.dart';
import 'package:ottapp/Models/ContentTypeModel.dart';
import 'package:ottapp/Models/SearchResponseModel.dart';
import 'package:ottapp/Models/SuggestionResponseModel.dart';
import 'package:ottapp/Models/ShortDramaModel.dart';
import 'package:ottapp/Models/ShortsProgressModel.dart';
import 'package:ottapp/Models/ShortActionResponseModel.dart';

part 'HomeChopperService.chopper.dart';

@ChopperApi()
abstract class HomeChopperService extends ChopperService {
  static HomeChopperService create({ChopperClient? client}) {
    return _$HomeChopperService(client);
  }

  // ── In-app purchases ──
  // The store bills the viewer; the server decides what that unlocks. The
  // app never grants access on its own, so a tampered client gets nothing.

  /// Which store products to offer, and their ids. Served by the backend so a
  /// price or product change needs no app release.
  @Get(path: 'app/products')
  Future<Response<dynamic>> appProducts(
    @Query('platform') String platform,
  );

  /// Hand the store's receipt to the server, which verifies it with Apple or
  /// Google and grants the subscription or ticket.
  @Post(path: 'app/purchase/verify')
  Future<Response<dynamic>> verifyAppPurchase(
    @Body() Map<String, dynamic> body,
  );

  /// Replay every receipt the device holds ("Restore purchases").
  @Post(path: 'app/purchase/restore')
  Future<Response<dynamic>> restoreAppPurchases(
    @Body() Map<String, dynamic> body,
  );

  @Post(path: 'watch-history/sync')
  Future<Response<WatchHistoryResponse>> syncWatchHistory(
    @Body() Map<String, dynamic> body,
  );


  @Post(path: 'device-tokens')
  Future<Response<FcmModel>> fcmTokenAPI(
    @Body() Map<String, dynamic> body,
  );
  @Post(path: 'auth/magic-link')
  Future<Response<MagicLinkModel>> magicLinkAPI(
    @Header('X-Platform') String platform,
  );

  @Post(path: 'auth/magic-link')
  Future<Response<MagicLinkModel>> supportMagicLinkAPI(
    @Header('X-Platform') String platform,
    @Body() Map<String, dynamic> body,
  );

  @GET(path: 'pages/{page_slug}')
  Future<Response<HomeModel>> getPageDataAPI(
    @Path('page_slug') String pageSlug,
    @Query('section_page') int sectionPage,
    @Query('section_per_page') int sectionPerPage,
  );

  @GET(path: 'genres')
  Future<Response<GetAllGenreModel>> getAllGenreAPI();

  @GET(path: 'contents/{uuid}')
  Future<Response<InfoModel>> contentDetailAPI(@Path('uuid') String uuid);

  @GET(path: 'contents/{uuid}/related')
  Future<Response<RecommendedModel>> contentRelatedAPI(
    @Path('uuid') String uuid,
  );

  @GET(path: 'pages/{page_slug}/sections/{section_slug}')
  Future<Response<SectionPaginationModel>> sectionPaginationAPI(
    @Path('page_slug') String pageSlug,
    @Path('section_slug') String sectionSlug,
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @GET(path: 'contents/{uuid}/seasons/{season_number}/episodes')
  Future<Response<EpisodeModel>> getEpisodesAPI(
    @Path('uuid') String uuid,
    @Path('season_number') int seasonNumber,
  );

  @GET(path: 'contents/{uuid}/play')
  Future<Response<PlayResponseModel>> playContentAPI(@Path('uuid') String uuid);

  @GET(path: 'episodes/{uuid}/play')
  Future<Response<PlayResponseModel>> playEpisodeAPI(@Path('uuid') String uuid);

  @GET(path: 'menus')
  Future<Response<List<MenuModel>>> getHeaderMenusAPI(
    @Query('placement') String placement,
  );

  @GET(path: 'live-video')
  Future<Response<LiveVideoModel>> getLiveVideoAPI();

  @Post(path: 'watchlist/{id}')
  Future<Response<Map<String, dynamic>>> addToWatchlist(@Path('id') int id);

  @Delete(path: 'watchlist/{id}')
  Future<Response<Map<String, dynamic>>> removeFromWatchlist(@Path('id') int id);

  @GET(path: 'watchlist')
  Future<Response<MyWatchListModel>> getWatchListAPI(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @GET(path: 'shorts/saved')
  Future<Response<ShortsListModel>> getShortsListAPI();
  
  @GET(path: 'content-types')
  Future<Response<ContentTypeModel>> getContentTypesAPI();

  @GET(path: 'search')
  Future<Response<SearchResponseModel>> searchContentAPI(
    @Query('q') String? query,
    @Query('type') String? contentType,
    @Query('genre') String? genreSlug,
    @Query('sort') String? sort,
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @GET(path: 'search/suggestions')
  Future<Response<SuggestionResponseModel>> getSearchSuggestionsAPI(
    @Query('q') String query,
  );

  @GET(path: 'subscription')
  Future<Response<SubscriptionModel>> getSubscriptionAPI();

  @GET(path: 'shorts/{slug}')
  Future<Response<ShortDramaModel>> getShortDramaDetailAPI(
    @Path('slug') String slug,
  );

  @GET(path: 'shorts/episodes/{uuid}/play')
  Future<Response<PlayResponseModel>> playShortEpisodeAPI(
    @Path('uuid') String uuid,
  );

  @POST(path: 'shorts/progress')
  Future<Response<ShortsProgressResponseModel>> syncShortProgress(
    @Body() ShortsProgressRequestModel body,
  );

  @POST(path: 'shorts/episodes/{uuid}/like')
  Future<Response<ShortActionResponseModel>> likeShortEpisodeAPI(
    @Path('uuid') String uuid,
  );

  @DELETE(path: 'shorts/episodes/{uuid}/like')
  Future<Response<ShortActionResponseModel>> unlikeShortEpisodeAPI(
    @Path('uuid') String uuid,
  );

  @POST(path: 'shorts/{slug}/bookmark')
  Future<Response<ShortActionResponseModel>> bookmarkShortAPI(
    @Path('slug') String slug,
  );

  @DELETE(path: 'shorts/{slug}/bookmark')
  Future<Response<ShortActionResponseModel>> unbookmarkShortAPI(
    @Path('slug') String slug,
  );
}
