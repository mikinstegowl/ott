import 'package:get/get.dart';
import 'package:ottapp/Controllers/SearchController.dart';

class SearchControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySearchController>(() => MySearchController());
  }
}
