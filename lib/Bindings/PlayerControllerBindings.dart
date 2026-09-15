import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/PlayerController.dart';

class PlayerControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlayerController(homeChopperService: Get.find<HomeChopperService>()));
  }
}
