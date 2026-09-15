import 'dart:async';
import 'dart:developer';
import 'package:chopper/chopper.dart';

// class ResponseLogger implements ResponseInterceptor {
//   @override
//   FutureOr<Response> onResponse(Response response) {
//     if (response.isSuccessful) {
//       log("=====================================RESPONSE=====================================",
//           name: "");
//       log("==> ${response.statusCode.toString()}", name: "Response code");
//       log("==> ${response.bodyString}", name: "Response body ");
//       log(
//         "====================================================================================",
//       );
//     } else {
//       log("",error: "=====================================ERROR=====================================",name: "Error");
//       log("",error: "${response.base.request?.method.toString()} ==>  ${response.base.request?.url.toString()}", name: "Requested URL");
//       log("", name: "Error", error: "==> ${response.bodyString}");
//       log("", name: "status Code", error: "==> ${response.statusCode}");
//       log(
//         "======================================================================================",
//       );
//       // if (response.statusCode.toString() == '403') {
//
//       //   gt.Get.offAllNamed(AppRouterName.loginScreen);
//       // }
//     }
//     return response;
//   }
// }

class ResponseLogger implements Interceptor {
  FutureOr<Response> onResponse(Response response) {
    if (response.isSuccessful) {
      log("=====================================RESPONSE=====================================",
          name: "");
      log("==> ${response.statusCode.toString()}", name: "Response code");
      log("==> ${response.bodyString}", name: "Response body ");
      log(
        "====================================================================================",
      );
    } else {
      log("",error: "=====================================ERROR=====================================",name: "Error");
      log("",error: "${response.base.request?.method.toString()} ==>  ${response.base.request?.url.toString()}", name: "Requested URL");
      log("", name: "Error", error: "==> ${response.bodyString}");
      log("", name: "status Code", error: "==> ${response.statusCode}");
      log(
        "======================================================================================",
      );
      // if (response.statusCode.toString() == '403') {

      //   gt.Get.offAllNamed(AppRouterName.loginScreen);
      // }
    }
    return response;
  }

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain)async{
    final Response<BodyType> response = await chain.proceed(chain.request);
    if (response.isSuccessful) {
      log("=====================================RESPONSE=====================================",
          name: "");
      log("==> ${response.statusCode.toString()}", name: "Response code");
      log("==> ${response.bodyString}", name: "Response body ");
      log(
        "====================================================================================",
      );
    } else {
      log("",error: "=====================================ERROR=====================================",name: "Error");
      log("",error: "${response.base.request?.method.toString()} ==>  ${response.base.request?.url.toString()}", name: "Requested URL");
      log("", name: "Error", error: "==> ${response.bodyString}");
      log("", name: "status Code", error: "==> ${response.statusCode}");
      log(
        "======================================================================================",
      );
      // if (response.statusCode.toString() == '403') {

      //   gt.Get.offAllNamed(AppRouterName.loginScreen);
      // }
    }
    return response;
  }
}
