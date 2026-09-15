import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Controllers/ProfileController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class ProfileControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppChopperClient().getChopperService<AuthChopperService>());
    Get.lazyPut(
      () => ProfileController(
        authChopperService: Get.find<AuthChopperService>(),
      ),
    );
  }
}
