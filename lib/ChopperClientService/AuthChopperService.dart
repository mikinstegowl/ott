import 'package:chopper/chopper.dart';
import 'package:ottapp/Models/LoginModel.dart';
import 'package:ottapp/Models/ProfileModel.dart';
import 'package:ottapp/Models/RegisterModel.dart';
import 'package:ottapp/Models/SubscriptionModel.dart';

part 'AuthChopperService.chopper.dart';

@ChopperApi()
abstract class AuthChopperService extends ChopperService {
  static AuthChopperService create({ChopperClient? client}) {
    return _$AuthChopperService(client);
  }

  @POST(path: 'auth/login')
  Future<Response<LoginModel>> loginAPI({
    @Body() required Map<String, dynamic> param,
  });

  @POST(path: 'auth/register')
  Future<Response<RegisterModel>> registerAPI({
    @Body() required Map<String, dynamic> param,
  });

  @GET(path: 'auth/me')
  Future<Response<ProfileModel>> getMeAPI();

  @PUT(path: 'auth/profile')
  Future<Response<ProfileModel>> updateProfileAPI({
    @Body() required Map<String, dynamic> param,
  });

  @GET(path: 'subscription')
  Future<Response<SubscriptionModel>> getSubscriptionAPI();
  
  @DELETE(path: 'auth/account')
  Future<Response<Map<String, dynamic>>> deleteAccountAPI({
    @Body() required Map<String, dynamic> param,
  });

  @PUT(path: 'auth/change-password')
  Future<Response<Map<String, dynamic>>> changePasswordAPI({
    @Body() required Map<String, dynamic> param,
  });
}
