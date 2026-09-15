import 'dart:async';
import 'dart:developer';
import 'package:chopper/chopper.dart';

// class RequestLogger implements RequestInterceptor {
//   @override
//   FutureOr<Request> onRequest(Request request) {
//     log("=====================================${request.method} REQUEST=====================================",
//         name: "Request");
//
//     log("==> ${request.url.toString()}", name: "Request URL");
//     log("==> ${request.body.toString()}", name: "Request parameters");
//     log("===========================================================================================",
//         name: "Request");
//        
//     return request;
//   }
// }

class RequestLogger implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    {
      log("=====================================${chain.request.method} REQUEST=====================================",
          name: "Request");

      log("==> ${chain.request.url.toString()}", name: "Request URL");
      log("==> ${chain.request.body.toString()}", name: "Request parameters");
      log("===========================================================================================",
          name: "Request");

      return chain.proceed(chain.request);
    }
   
  }
}
