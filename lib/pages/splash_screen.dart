import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_label_web/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var con = Get.put(SplashController());
    return Scaffold(
      body: Center(
          child: Obx(
        () => con.isLoading.value
            ? const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator.adaptive(),
              )
            : const SizedBox.shrink(),
      )),
    );
  }
}
