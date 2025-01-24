import 'package:get/get.dart';
import 'package:price_label_web/routes.dart';

class SplashController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 5));
    Get.offNamed(RouteLinks.main);
    isLoading.value = false;
    super.onInit();
  }
}
