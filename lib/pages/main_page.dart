import 'dart:developer';
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
        actions: [
          // Show What's New and What's Coming in AppBar for narrow screens
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            padding: const EdgeInsets.only(right: 20),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1400;
            log("Width: ${constraints.maxWidth}");
            log("Height: ${constraints.maxHeight}");
            log("isWide: $isWide");

            return isWide
                ? _buildWideLayout(settingCon, context)
                : _buildNarrowLayout(settingCon, context);
          },
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 500,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Release Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // What's New Section
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.deepOrange, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "What's New",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.black,
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text("- v1.0.3",
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 3),
                                const Text(
                                    "- load from excel accessory regular",
                                    style: TextStyle(fontSize: 12)),
                                const Text(
                                    "- load from excel accessory promotional",
                                    style: TextStyle(fontSize: 12)),
                                const Text(
                                    "- download template excel for accessory regular & promotion",
                                    style: TextStyle(fontSize: 12)),
                                const Text(
                                    "- load from excel DPH & Cosmetics regular",
                                    style: TextStyle(fontSize: 12)),
                                const Text(
                                    "- load from excel DPH & Cosmetics promotional",
                                    style: TextStyle(fontSize: 12)),
                                const Text(
                                    "- download template excel for DPH & Cosmetics regular & promotion",
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // What's Coming Section
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.deepPurpleAccent, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "What's Coming",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text("Coming soon...",
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(SettingsController settingCon, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // What's New Container
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                  const Text("- load from excel DPH & Cosmetics promotional"),
                  const Text(
                      "- download template excel for DPH & Cosmetics regular & promotion"),
                ],
              ),
            ),

            // Center buttons
            _buildButtonColumn(settingCon, isWide: true),

            // What's Coming Container
            Container(
              height: 300,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurpleAccent, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "What's Coming",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }

  Widget _buildNarrowLayout(
      SettingsController settingCon, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Info notice for narrow screens
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tap the info icon in the app bar to see release notes",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Buttons section
          _buildButtonColumn(settingCon, isWide: false),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildButtonColumn(SettingsController settingCon,
      {required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (kDebugMode)
          ResponsiveButtonWidget(
            title: "Test",
            isWide: isWide,
            onPressed: () {
              Get.toNamed(RouteLinks.test);
            },
          ),
        // Debug checkbox
        if (kDebugMode)
          Obx(
            () => SizedBox(
              width: isWide ? 300 : double.infinity,
              height: 50,
              child: CheckboxListTile.adaptive(
                value: settingCon.isDemoOn.value,
                onChanged: (val) {
                  settingCon.isDemoOn.toggle();
                },
                title: Text(
                  "Demo Values",
                  style: TextStyle(
                    fontSize: isWide ? 14 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
        const SizedBox(height: 20),
        ResponsiveButtonWidget(
          onPressed: () {
            Get.toNamed(RouteLinks.priceLabelPromo);
          },
          title: "DPH & Perfumes Label - Promotion (8 x 4)",
          isWide: isWide,
        ),
        ResponsiveButtonWidget(
          onPressed: () {
            Get.toNamed(RouteLinks.priceLabelNoPromo);
          },
          title: "DPH & Perfumes Label - Regular (8 x 4)",
          isWide: isWide,
        ),
        ResponsiveButtonWidget(
          onPressed: () {
            Get.toNamed(RouteLinks.accessoriesPromo);
          },
          title: "Accessory Label - Promotion (6 x 4)",
          isWide: isWide,
        ),
        ResponsiveButtonWidget(
          onPressed: () {
            Get.toNamed(RouteLinks.accessoriesNoPromo);
          },
          title: "Accessory Label - Regular (6 x 4)",
          isWide: isWide,
        ),
      ],
    );
  }
}

class ResponsiveButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final bool isWide;

  const ResponsiveButtonWidget({
    super.key,
    this.onPressed,
    required this.title,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isWide ? 30 : 15),
      child: SizedBox(
        width: isWide ? 320 : double.infinity,
        height: isWide ? 50 : 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: isWide ? 15 : 8,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: TextStyle(
              fontSize: isWide ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:price_label_web/controllers/settings_controller.dart';
// import 'package:price_label_web/routes.dart';

// class MainPage extends StatelessWidget {
//   const MainPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var settingCon = Get.put(SettingsController());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Price Label Maker"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 300,
//                   width: 400,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.deepOrange, width: 0.5),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.all(15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "What's New",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headlineSmall
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.underline,
//                                 decorationColor: Colors.black,
//                                 decorationStyle: TextDecorationStyle.solid,
//                               ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text("- v1.0.3"),
//                       const SizedBox(height: 5),
//                       const Text("- load from excel accessory regular"),
//                       const Text("- load from excel accessory promotional"),
//                       const Text(
//                           "- download template excel for accessory regular & promotion"),
//                       const Text("- load from excel DPH & Cosmetics regular"),
//                       const Text(
//                           "- load from excel DPH & Cosmetics promotional"),
//                       const Text(
//                           "- download template excel for DPH & Cosmetics regular & promotion"),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (kDebugMode)
//                       Buttonwidget(
//                         title: "Test",
//                         onPressed: () {
//                           Get.toNamed(RouteLinks.test);
//                         },
//                       ),
//                     // check box for Demo
//                     if (kDebugMode)
//                       Obx(
//                         () => SizedBox(
//                           width: 300,
//                           height: 50,
//                           child: CheckboxListTile.adaptive(
//                             value: settingCon.isDemoOn.value,
//                             onChanged: (val) {
//                               settingCon.isDemoOn.toggle();
//                             },
//                             title: const Text(
//                               "Demo Values",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             controlAffinity: ListTileControlAffinity.leading,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     Buttonwidget(
//                       onPressed: () {
//                         Get.toNamed(RouteLinks.priceLabelPromo);
//                       },
//                       title: "DPH & Perfumes Label - Promotion (8 x 4)",
//                     ),
//                     Buttonwidget(
//                       onPressed: () {
//                         Get.toNamed(RouteLinks.priceLabelNoPromo);
//                       },
//                       title: "DPH & Perfumes Label - Regular (8 x 4)",
//                     ),
//                     Buttonwidget(
//                       onPressed: () {
//                         Get.toNamed(RouteLinks.accessoriesPromo);
//                       },
//                       title: "Accessory Label - Promotion (6 x 4)",
//                     ),
//                     Buttonwidget(
//                       onPressed: () {
//                         Get.toNamed(RouteLinks.accessoriesNoPromo);
//                       },
//                       title: "Accessory Label - Regular (6 x 4)",
//                     ),
//                   ],
//                 ),
//                 Container(
//                   height: 300,
//                   width: 400,
//                   decoration: BoxDecoration(
//                     border:
//                         Border.all(color: Colors.deepPurpleAccent, width: 0.5),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.all(15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "What's Coming",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headlineSmall
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.underline,
//                                 decorationColor: Colors.black,
//                                 decorationStyle: TextDecorationStyle.solid,
//                               ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // const Text("- upload excel in DPH & Cosmetics labels"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Buttonwidget extends StatelessWidget {
//   final void Function()? onPressed;
//   final String title;
//   const Buttonwidget({
//     super.key,
//     this.onPressed,
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 30),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           fixedSize: const Size(320, 50),
//           elevation: 15,
//           shape: BeveledRectangleBorder(
//             borderRadius: BorderRadius.circular(5),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(title),
//       ),
//     );
//   }
// }
