import 'package:get/get.dart';
import 'package:ottapp/Controllers/ReelShortsController.dart';

class ReelShortsBindings implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=> ReelShortsController(),fenix: true);
    // TODO: implement dependencies
  }
}