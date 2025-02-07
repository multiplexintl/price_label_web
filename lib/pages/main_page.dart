import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_label_web/controllers/settings_controller.dart';
import 'package:price_label_web/routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var settingCon = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Label Maker"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 300,
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrange, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "What's New",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("- v1.0.3"),
                      const SizedBox(height: 5),
                      const Text("- load from excel accessory regular"),
                      const Text("- load from excel accessory promotional"),
                      const Text(
                          "- download template excel for accessory regular & promotion"),
                      const Text("- load from excel DPH & Cosmetics regular"),
                      const Text(
                          "- load from excel DPH & Cosmetics promotional"),
                      const Text(
                          "- download template excel for DPH & Cosmetics regular & promotion"),
                    ],
                  ),
                ),
                Column(
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
                    // check box for Demo
                    if (kDebugMode)
                      Obx(
                        () => SizedBox(
                          width: 300,
                          height: 50,
                          child: CheckboxListTile.adaptive(
                            value: settingCon.isDemoOn.value,
                            onChanged: (val) {
                              settingCon.isDemoOn.toggle();
                            },
                            title: const Text(
                              "Demo Values",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Buttonwidget(
                      onPressed: () {
                        Get.toNamed(RouteLinks.priceLabelPromo);
                      },
                      title: "DPH & Perfumes Label - Promotion (8 x 4)",
                    ),
                    Buttonwidget(
                      onPressed: () {
                        Get.toNamed(RouteLinks.priceLabelNoPromo);
                      },
                      title: "DPH & Perfumes Label - Regular (8 x 4)",
                    ),
                    Buttonwidget(
                      onPressed: () {
                        Get.toNamed(RouteLinks.accessoriesPromo);
                      },
                      title: "Accessory Label - Promotion (6 x 4)",
                    ),
                    Buttonwidget(
                      onPressed: () {
                        Get.toNamed(RouteLinks.accessoriesNoPromo);
                      },
                      title: "Accessory Label - Regular (6 x 4)",
                    ),
                  ],
                ),
                Container(
                  height: 300,
                  width: 400,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.deepPurpleAccent, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "What's Coming",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // const Text("- upload excel in DPH & Cosmetics labels"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
          fixedSize: const Size(320, 50),
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
