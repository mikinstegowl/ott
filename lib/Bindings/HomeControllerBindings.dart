import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
import 'package:ottapp/Controllers/HomeController.dart';

class HomeControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppChopperClient().getChopperService<HomeChopperService>());
    Get.lazyPut(() => AppChopperClient().getChopperService<AuthChopperService>());
    Get.lazyPut(
      () => HomeController(
        homeChopperService: Get.find<HomeChopperService>(),
        authChopperService: Get.find<AuthChopperService>(),
      ),
      fenix: true,
    );
  }
}