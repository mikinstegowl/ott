import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/InfoController.dart';

class InfoControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InfoController(homeChopperService: Get.find<HomeChopperService>()),fenix: true);
  }
}
