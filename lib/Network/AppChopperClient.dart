import 'package:chopper/chopper.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Models/FcmModel.dart';
import 'package:ottapp/Models/GeneralErrorModel.dart';
import 'package:ottapp/Models/GetAllGenreModel.dart';
import 'package:ottapp/Models/HomeModel.dart';
import 'package:ottapp/Models/InfoModel.dart';
import 'package:ottapp/Models/IsActiveLiveVideoModel.dart';
import 'package:ottapp/Models/LoginModel.dart';
import 'package:ottapp/Models/MagicLinkModel.dart';
import 'package:ottapp/Models/MyWatchListModel.dart';
import 'package:ottapp/Models/RecommendedModel.dart';
import 'package:ottapp/Models/RegisterModel.dart';
import 'package:ottapp/Models/SectionPaginationModel.dart';
import 'package:ottapp/Models/EpisodeModel.dart';
import 'package:ottapp/Models/ProfileModel.dart';
import 'package:ottapp/Models/PlayResponseModel.dart';
import 'package:ottapp/Models/MenuModel.dart';
import 'package:ottapp/Models/ShortsListModel.dart';
import 'package:ottapp/Models/WatchHistoryModel.dart';
import 'package:ottapp/Models/LiveVideoModel.dart';
import 'package:ottapp/Models/ContentTypeModel.dart';
import 'package:ottapp/Models/SearchResponseModel.dart';
import 'package:ottapp/Models/SuggestionResponseModel.dart';
import 'package:ottapp/Models/SubscriptionModel.dart';
import 'package:ottapp/Models/ShortDramaModel.dart';
import 'package:ottapp/Models/ShortsProgressModel.dart';
import 'package:ottapp/Models/ShortActionResponseModel.dart';

import 'Utils/Convertors/JsonToTypeConverter.dart';
import 'Utils/Interceptors/ApplyHeaderInterceptor.dart';
import 'Utils/Interceptors/RequestLogger.dart';
import 'Utils/Interceptors/ResponseLogger.dart';

class AppChopperClient {
  static final AppChopperClient _singleton = AppChopperClient._internal();

  factory AppChopperClient() {
    return _singleton;
  }

  AppChopperClient._internal() {
    createChopperClient();
  }

  ChopperClient? _client;

  T getChopperService<T extends ChopperService>() {
    return _client!.getService<T>();
  }

  void createChopperClient() {
    if (_client != null) {
      return;
    }
    _client = ChopperClient(
      baseUrl: Uri.parse('https://trebolplus.com/api/v1/'),
      services: [AuthChopperService.create(), HomeChopperService.create()],
      interceptors: [
        RequestLogger(),
        ResponseLogger(),
        ApplyHeaderInterceptor(),
      ],
      converter: JsonToTypeConverter(
        jsonConvertorMap: {
          GeneralErrorModel: GeneralErrorModel.fromJson,
          RegisterModel: RegisterModel.fromJson,
          LoginModel: LoginModel.fromJson,
          HomeModel: HomeModel.fromJson,
          InfoModel: InfoModel.fromJson,
          RecommendedModel: RecommendedModel.fromJson,
          SectionPaginationModel: SectionPaginationModel.fromJson,
          GetAllGenreModel: GetAllGenreModel.fromJson,
          EpisodeModel: EpisodeModel.fromJson,
          ProfileModel: ProfileModel.fromJson,
          PlayResponseModel: PlayResponseModel.fromJson,
          MenuModel: MenuModel.fromJson,
          WatchHistoryResponse: WatchHistoryResponse.fromJson,
          LiveVideoModel: LiveVideoModel.fromJson,
          MyWatchListModel: MyWatchListModel.fromJson,
          MagicLinkModel: MagicLinkModel.fromJson,
          FcmModel: FcmModel.fromJson,
          ContentTypeModel: (json) => ContentTypeModel.fromJson(json),
          SearchResponseModel: (json) => SearchResponseModel.fromJson(json),
          SuggestionResponseModel:
              (json) => SuggestionResponseModel.fromJson(json),
          SubscriptionModel: SubscriptionModel.fromJson,
          IsActiveLiveVideoModel: IsActiveLiveVideoModel.fromJson,
          ShortDramaModel: ShortDramaModel.fromJson,
          ShortsProgressResponseModel: ShortsProgressResponseModel.fromJson,
          ShortActionResponseModel: ShortActionResponseModel.fromJson,
          ShortsListModel: ShortsListModel.fromJson,
        },
      ),
      errorConverter: JsonToTypeConverter(
        jsonConvertorMap: {GeneralErrorModel: GeneralErrorModel.fromJson},
      ),
    );
  }
}

// flutter packages pub run build_runner build --delete-conflicting-outputs
