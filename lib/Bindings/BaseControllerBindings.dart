import 'package:get/get.dart';
import 'package:ottapp/Controllers/BaseController.dart';


class BaseControllerBindings implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=> BaseController(),fenix: true);
    // TODO: implement dependencies
  }

}