import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/LiveVideoController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class LiveVideoControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveVideoController>(
      () => LiveVideoController(homeChopperService: AppChopperClient().getChopperService<HomeChopperService>()),fenix: true
    );
  }
}
