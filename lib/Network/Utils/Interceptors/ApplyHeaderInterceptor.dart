import 'dart:async';
import 'dart:developer';
import 'package:chopper/chopper.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:get/get.dart' as g;


// class ApplyHeaderInterceptor implements RequestInterceptor {
//   @override
//   FutureOr<Request> onRequest(Request request) async {
//     if (request.url.toString().contains("language")) {
//       log("url contains \"language\"", name: "from ApplyHeaderInterceptor");
//       return request;
//     }
//
//     var token;
//     SharedPreferences sharedPref = await SharedPreferences.getInstance();
//
//     token = UserPreference.getValue(key: PrefKeys.logInToken) ??
//         sharedPref.get("logInToken");
//     // await g.Get.find<MySecureStorage>().getStringValue(StorageKeys.token);
//
//     //'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQyMDI4NzUwLCJpYXQiOjE3MTA0OTI3NTAsImp0aSI6ImNiNzA0NjNiZmFiZTRjNDk4MTM0YTMyYzViNTFhZmI4IiwidXNlcl9pZCI6MTM2NSwidGltZXN0YW1wIjoxNzEwNDkyNzUwNDkzLCJlbWFpbCI6InZpc2hlc2hwYXRlbDI2MTBAZ21haWwuY29tIiwidXNlcklkIjoiZmNkMTE2OTktNzlhNS00MTU2LTlkYjEtMDBmNmIxODZmNWE1MTcxMDQ5Mjc1MDQ5MyJ9.yvqRaPV5hPugXBh3jadqKXQ5ro4mRwLpLgoJKgtlHIA';
//     // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQzNjU3Mzk1LCJpYXQiOjE3MTIxMjEzOTUsImp0aSI6ImI1ZjU1NmE5ZTM4NTRkZWJiM2FiNjNiMmU4YzI4MDI0IiwidXNlcl9pZCI6MTU5MCwidGltZXN0YW1wIjoxNzEyMTIxMzk1MjY2LCJlbWFpbCI6InZpc2hlc2gxOTk5LmN1bXVsYXRpdmVAZ21haWwuY29tIiwidXNlcklkIjoiOTQ0NGNmODEtYWY2YS00ZGYzLWEwNzMtMTkzNjkzOTI3Nzg1MTcxMjEyMTM5NTI2NiJ9.qQl0m3kJBRHakxmDSd_mxor5DHdldPfXrXzqZhK2Eoc";
//     // don't add token if null
//
//     print("1 ${token}");
//
//     if (token == null&&!UserPreference.getBool(key: PrefKeys.header)) {
//       return request;
//     }
//       log(token);
//       print("2 ${token}");
//       // return applyHeaders(request, {'x-access-token': token});
//       return applyHeaders(request, {'Authorization': 'Bearer $token'});
//
//   }
// }
// Make sure to import your PrefKeys

class ApplyHeaderInterceptor implements Interceptor {
  // Future<Request> onRequest(Request request) async {
  //   // Check if the URL contains "language"
  //   if (request.url.toString().contains("language")) {
  //     log("url contains \"language\"", name: "from ApplyHeaderInterceptor");
  //     return request; // Return the original request if the URL contains "language"
  //   }
  //
  //   // Retrieve the token from shared preferences
  //   SharedPreferences sharedPref = await SharedPreferences.getInstance();
  //   var token = UserPreference.getValue(key: PrefKeys.logInToken) ??
  //       sharedPref.getString("logInToken");
  //
  //   // Log the token for debugging
  //   print("Token: $token");
  //
  //   // If token is null and header preference is not set, return the request as is
  //   if (token == null && !UserPreference.getBool(key: PrefKeys.header)) {
  //   return request;
  //   }
  //
  //   // Log the token if it's not null
  //   if (token != null) {
  //   log("Applying token: $token");
  //   // Apply the authorization header
  //   return applyHeaders(request, {'Authorization': 'Bearer $token'});
  //   }
  //
  //   return request; // Return the original request if no token is applied
  // }

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final path = chain.request.url.path;
    if (path.contains('driver/login')) {
      return chain.proceed(chain.request);
    }

    await UserPreference.initSharedPrefs();
    final prefs = await SharedPreferences.getInstance();
    final token =
        (UserPreference.getValue(key: PrefKeys.logInToken) as String?) ??
            prefs.getString(PrefKeys.logInToken);

    if (token == null || token.isEmpty) {
      return chain.proceed(chain.request);
    }

    log('Applying headers', name: 'ApplyHeaderInterceptor');
    return chain.proceed(
      applyHeaders(chain.request, {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
  }
}
