import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Controllers/LoginController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class LoginControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        authChopperService:
            AppChopperClient().getChopperService<AuthChopperService>(),
      ),
      fenix: true,
    );
  }
}
