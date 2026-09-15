import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Controllers/RegisterController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class RegisterControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => RegisterController(
        authChopperService:
            AppChopperClient().getChopperService<AuthChopperService>(),
      ),
      fenix: true,
    );
  }
}
