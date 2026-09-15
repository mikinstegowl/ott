import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/ViewAllController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class ViewAllControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppChopperClient().getChopperService<HomeChopperService>());
    Get.lazyPut<ViewAllController>(
      () => ViewAllController(
        homeChopperService: Get.find<HomeChopperService>(),
      ),
    );
  }
}
