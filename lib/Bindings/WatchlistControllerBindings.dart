import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/HomeChopperService.dart';
import 'package:ottapp/Controllers/WatchlistController.dart';
import 'package:ottapp/Network/AppChopperClient.dart';

class WatchlistControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchlistController>(
      () => WatchlistController(
        homeChopperService: AppChopperClient().getChopperService<HomeChopperService>(),
      ),
    );
  }
}
