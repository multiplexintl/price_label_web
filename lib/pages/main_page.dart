import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_label_web/controllers/pdf_controller.dart';
import 'package:price_label_web/routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Label Maker"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (kDebugMode)
                  Buttonwidget(
                    title: "Test",
                    onPressed: () {
                      Get.toNamed(RouteLinks.test);
                    },
                  ),
                Buttonwidget(
                  onPressed: () {
                    Get.toNamed(RouteLinks.priceLabelPromo);
                  },
                  title: "Price Label - Promotion",
                ),
                Buttonwidget(
                  onPressed: () {
                    Get.toNamed(RouteLinks.priceLabelNoPromo);
                  },
                  title: "Price Label - No Promotion",
                ),
                Buttonwidget(
                  onPressed: () {
                    Get.toNamed(RouteLinks.accessoriesPromo);
                  },
                  title: "Accessory Label - Promotion",
                ),
                Buttonwidget(
                  onPressed: () {
                    Get.toNamed(RouteLinks.accessoriesNoPromo);
                  },
                  title: "Accessory Label - No Promotion",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Buttonwidget extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const Buttonwidget({
    super.key,
    this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 50),
          elevation: 15,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}
