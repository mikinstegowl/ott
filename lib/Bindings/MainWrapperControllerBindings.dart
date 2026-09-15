import 'package:get/get.dart';
import 'package:ottapp/Controllers/MainWrapperController.dart';

class MainWrapperControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainWrapperController>(() => MainWrapperController());
  }
}
