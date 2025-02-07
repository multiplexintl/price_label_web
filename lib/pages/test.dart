// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:price_label_web/models/cosmetics_label_promo.dart';
// import '../controllers/cosmetics_label_promo_controller.dart';
// import 'cosmetics_label_promo.dart';

// class PriceLabelPromoViewTest extends StatelessWidget {
//   const PriceLabelPromoViewTest({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(PriceLabelPromoController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Price Label Promo"),
//         automaticallyImplyLeading: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isMobile = constraints.maxWidth < 600;
//             final isTablet = constraints.maxWidth < 1000;

//             return Flex(
//               direction: isMobile ? Axis.vertical : Axis.horizontal,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!isMobile)
//                   Flexible(
//                     flex: 2,
//                     child: _buildEditAndListSection(constraints),
//                   ),
//                 if (!isMobile) const SizedBox(width: 16),
//                 Flexible(
//                   flex: 3,
//                   child: _buildPreviewSection(),
//                 ),
//                 if (isMobile) _buildEditAndListSection(constraints),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEditAndListSection(BoxConstraints constraints) {
//     var con = Get.find<PriceLabelPromoController>();
//     final isMobile = constraints.maxWidth < 600;

//     return SingleChildScrollView(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: isMobile ? constraints.maxWidth : 550,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: isMobile ? 8.0 : 0),
//               child: _buildResponsiveTextField(
//                 controller: con.fileNameController,
//                 title: "File Name",
//                 isMobile: isMobile,
//                 width: isMobile ? double.infinity : 270,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.amber.shade100,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const SizedBox(height: 20),
//                       const Text("Discount: "),
//                       _buildResponsiveTextField(
//                         controller: con.percentageController.value,
//                         title: "Offer Percentage",
//                         isMobile: isMobile,
//                         width: isMobile ? 150 : 250,
//                         enabled: con.isEnabledPerc.value,
//                         formatter: FilteringTextInputFormatter.allow(
//                           RegExp(r'^\d*\.?\d{0,2}$'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   _buildDynamicFormFields(con, isMobile),
//                   const SizedBox(height: 10),
//                   _buildActionButtons(con, isMobile),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             _buildItemListSection(con, isMobile),
//             const SizedBox(height: 10),
//             _buildPreferencesSection(con, isMobile),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDynamicFormFields(PriceLabelPromoController con, bool isMobile) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: con.controllers.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: EdgeInsets.symmetric(
//             vertical: 4.0,
//             horizontal: isMobile ? 4.0 : 8.0,
//           ),
//           child: Obx(() => Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Text("${index + 1}: "),
//                   _buildResponsiveTextField(
//                     controller: con.controllers[index]["description"]!,
//                     title: "Description",
//                     isMobile: isMobile,
//                     width: isMobile ? 120 : 250,
//                     enabled: con.isEnabled.value,
//                   ),
//                   _buildResponsiveTextField(
//                     controller: con.controllers[index]["wasPrice"]!,
//                     title: "Was Price",
//                     isMobile: isMobile,
//                     width: isMobile ? 80 : 100,
//                     enforced: true,
//                     formatter: FilteringTextInputFormatter.allow(
//                       RegExp(r'^\d*\.?\d{0,2}$'),
//                     ),
//                     onChanged: (value) => con.onWasPriceChanged(index, value),
//                   ),
//                   _buildResponsiveTextField(
//                     controller: con.controllers[index]["nowPrice"]!,
//                     title: "Now Price",
//                     isMobile: isMobile,
//                     width: isMobile ? 80 : 100,
//                     enforced: true,
//                     readOnly: true,
//                     formatter: FilteringTextInputFormatter.digitsOnly,
//                   ),
//                   InkWell(
//                     onTap: () => con.clearRow(index),
//                     child: Container(
//                       height: 28,
//                       width: 28,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                       child: const Icon(Icons.close, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               )),
//         );
//       },
//     );
//   }

//   Widget _buildActionButtons(PriceLabelPromoController con, bool isMobile) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       alignment: WrapAlignment.center,
//       children: [
//         ElevatedButton(
//           onPressed: con.clearAllRows,
//           child: const Text("Clear"),
//         ),
//         Obx(() => ElevatedButton(
//               onPressed: con.saveOrUpdatePriceLabelPromo,
//               child: Text(con.isEditMode.value ? "Update" : "Save"),
//             )),
//         ElevatedButton(
//           onPressed: () async => {},
//           child: const Text("Export"),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemListSection(PriceLabelPromoController con, bool isMobile) {
//     return Container(
//       width: double.infinity,
//       height: isMobile ? 300 : 400,
//       decoration: BoxDecoration(
//         color: Colors.lightBlueAccent.shade100,
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(8.0),
//             decoration: const BoxDecoration(color: Colors.blueGrey),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Items", style: TextStyle(color: Colors.white)),
//                 InkWell(
//                   onTap: con.clearAllData,
//                   child: Container(
//                     height: 30,
//                     width: 70,
//                     decoration: BoxDecoration(
//                       color: Colors.deepOrangeAccent,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text("Clear all",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             child: Obx(() => ListView.builder(
//                   itemCount: con.data.length,
//                   itemBuilder: (context, index) =>
//                       _buildListItem(context, con, index),
//                 )),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListItem(
//       BuildContext context, PriceLabelPromoController con, int index) {
//     final item = con.data[index];
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       child: Container(
//         decoration: BoxDecoration(
//           color: index.isEven
//               ? Colors.grey.withOpacity(0.5)
//               : Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 decoration: BoxDecoration(
//                   color: index.isOdd
//                       ? Colors.grey.withOpacity(0.5)
//                       : Colors.white.withOpacity(0.9),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(10),
//                     topLeft: Radius.circular(10),
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text("${index + 1}",
//                     style: Theme.of(context).textTheme.titleLarge),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Percentage : ${item.percentage}",
//                           style:
//                               Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   )),
//                       const SizedBox(height: 10),
//                       ..._buildItemDetails(context, item),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 40,
//                 decoration: BoxDecoration(
//                   color: index.isOdd
//                       ? Colors.grey.withOpacity(0.5)
//                       : Colors.white.withOpacity(0.9),
//                   borderRadius: const BorderRadius.only(
//                     bottomRight: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () => con.editPriceLabelPromo(index),
//                       icon: const Icon(Icons.edit),
//                     ),
//                     IconButton(
//                       onPressed: () => con.removeDataByIndex(index),
//                       icon: const Icon(Icons.delete),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildItemDetails(BuildContext context, CosmeticsLabelPromo item) {
//     return [
//       const Padding(
//         padding: EdgeInsets.only(bottom: 8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//                 width: 25,
//                 child:
//                     Text("No.", style: TextStyle(fontWeight: FontWeight.bold))),
//             Expanded(
//                 child: Text("Item Name",
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             SizedBox(width: 10),
//             SizedBox(
//                 width: 60,
//                 child: Text("Old\nPrice",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//             SizedBox(width: 10),
//             SizedBox(
//                 width: 60,
//                 child: Text("New Price",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold))),
//           ],
//         ),
//       ),
//       ...item.items
//           .asMap()
//           .entries
//           .map((entry) => _buildItemRow(context, entry)),
//     ];
//   }

//   Widget _buildItemRow(BuildContext context, MapEntry<int, dynamic> entry) {
//     final promo = entry.value;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(width: 20, child: Text("${entry.key + 1}.")),
//           Expanded(child: Text(promo.name, overflow: TextOverflow.ellipsis)),
//           const SizedBox(width: 10),
//           SizedBox(
//               width: 60,
//               child:
//                   Text(promo.oldPrice.toString(), textAlign: TextAlign.center)),
//           const SizedBox(width: 10),
//           SizedBox(
//               width: 60,
//               child:
//                   Text(promo.newPrice.toString(), textAlign: TextAlign.center)),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreferencesSection(
//       PriceLabelPromoController con, bool isMobile) {
//     return Container(
//       width: double.infinity,
//       height: isMobile ? 200 : 300,
//       decoration: BoxDecoration(color: Colors.blueGrey.shade100),
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text("Preferences",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//           ),
//           Row(
//             children: [
//               Obx(() => Checkbox.adaptive(
//                     value: con.isRedColor.value,
//                     onChanged: (val) => con.isRedColor.toggle(),
//                   )),
//               const Text("Red Color")
//             ],
//           ),
//           Row(
//             children: [
//               const Text("Text: "),
//               SizedBox(
//                 height: 50,
//                 width: isMobile ? 200 : 250,
//                 child: TextFormField(
//                   onChanged: con.updateText,
//                   initialValue: con.smallText.value,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: const BorderSide(color: Colors.blue),
//                     ),
//                     fillColor: Colors.white,
//                     filled: true,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResponsiveTextField({
//     required TextEditingController controller,
//     required String title,
//     required bool isMobile,
//     double? width,
//     bool enabled = true,
//     bool enforced = false,
//     bool readOnly = false,
//     TextInputFormatter? formatter,
//     void Function(String)? onChanged,
//   }) {
//     return SizedBox(
//       height: isMobile ? 40 : 30,
//       width: width,
//       child: TextFormFieldWidget2(
//         controller: controller,
//         title: title,
//         enforced: enforced,
//         enabled: enabled,
//         readOnly: readOnly,
//         formatter: formatter,
//         onChanged: onChanged,
//         // style: TextStyle(
//         //   fontSize: isMobile ? 12 : 10,
//         //   fontFamily: 'Myriad Pro',
//         // ),
//       ),
//     );
//   }

//   // Widget _buildPreviewSection() {
//   //   return LayoutBuilder(
//   //     builder: (context, constraints) {
//   //       final isMobile = constraints.maxWidth < 600;

//   //       return GetBuilder<PriceLabelPromoController>(
//   //         builder: (controller) {
//   //           // ... [Keep existing preview section logic] ...
//   //           // Update grid delegate for responsiveness
//   //           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//   //             maxCrossAxisExtent: isMobile ? 300 : 400,
//   //             crossAxisSpacing: isMobile ? 20 : 105.0,
//   //             mainAxisSpacing: isMobile ? 20 : 50,
//   //             childAspectRatio: isMobile ? 0.8 : 302.36 / 219.21,
//   //           ),
//   //           // ... [Rest of preview section code] ...
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   Widget _buildPreviewSection() {
//     var con = Get.find<PriceLabelPromoController>();

//     return LayoutBuilder(builder: (context, constraints) {
//       final isMobile = constraints.maxWidth < 600;
//       return GetBuilder<PriceLabelPromoController>(
//         builder: (controller) {
//           const itemsPerPage = 8; // Number of items per page

//           if (controller.data.isEmpty) {
//             return Container(
//               color: Colors.white,
//               width: 794, // A4 width in pixels
//               height: 1123, // A4 height in pixels
//               alignment: Alignment.center,
//               child: const Text(
//                 "No items found",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//             );
//           }

//           // Calculate total pages dynamically
//           final totalPages = (controller.data.length / itemsPerPage).ceil();
//           controller.totalPages.value = totalPages;

//           // Dynamically adjust the repaintKeys list to match the number of pages
//           while (controller.repaintKeys.length < totalPages) {
//             controller.repaintKeys.add(GlobalKey());
//           }

//           while (controller.repaintKeys.length > totalPages) {
//             controller.repaintKeys.removeLast();
//           }

//           // Scroll Controller
//           final ScrollController scrollController = ScrollController();

//           // Listen to Scroll Events
//           scrollController.addListener(() {
//             final scrollOffset =
//                 scrollController.offset; // Current scroll position
//             const pageHeight = 1123.0; // Fixed height of each A4 page
//             final currentPage = (scrollOffset / pageHeight).floor() + 1;

//             if (controller.currentPage.value != currentPage) {
//               controller.currentPage.value = currentPage.clamp(1, totalPages);
//             }
//           });

//           // Generate content for all pages
//           List<Widget> allPages = [];
//           for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
//             // Calculate data for each page
//             final startIndex = pageIndex * itemsPerPage;
//             final endIndex =
//                 (startIndex + itemsPerPage > controller.data.length)
//                     ? controller.data.length
//                     : startIndex + itemsPerPage;
//             final pageData = controller.data.sublist(startIndex, endIndex);

//             allPages.add(
//               RepaintBoundary(
//                 key: controller.repaintKeys[pageIndex],
//                 child: Container(
//                   color: Colors.white,
//                   width: 794, // A4 width in pixels
//                   height: 1123, // A4 height in pixels
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//                   margin: const EdgeInsets.only(
//                       bottom: 10), // Add spacing between pages
//                   alignment: Alignment.topCenter,
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                       maxCrossAxisExtent: isMobile ? 300 : 400,
//                       crossAxisSpacing: isMobile ? 20 : 105.0,
//                       mainAxisSpacing: isMobile ? 20 : 50,
//                       childAspectRatio: isMobile ? 0.8 : 302.36 / 219.21,
//                     ),
//                     itemCount: pageData.length,
//                     itemBuilder: (context, index) {
//                       final item = pageData[index];
//                       return Obx(() => PriceLabelPromoWidget(
//                             promo: item,
//                             vatText: con.smallText.value,
//                             isRed: con.isRedColor.value,
//                           ));
//                     },
//                   ),
//                 ),
//               ),
//             );
//           }

//           return Column(
//             children: [
//               // Header Section
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Obx(() => Text(
//                           "Page ${controller.currentPage.value} of ${controller.totalPages.value}",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         )),
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             if (controller.currentPage.value > 1) {
//                               controller.currentPage.value--;
//                               scrollController.animateTo(
//                                 (controller.currentPage.value - 1) * 1123.0,
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             }
//                           },
//                           child: const Text("Previous"),
//                         ),
//                         const SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (controller.currentPage.value < totalPages) {
//                               controller.currentPage.value++;
//                               scrollController.animateTo(
//                                 (controller.currentPage.value - 1) * 1123.0,
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             }
//                           },
//                           child: const Text("Next"),
//                         ),
//                         const SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             // con.generatePdf;
//                           },
//                           child: const Text("Print"),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Continuous Scrolling Section
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   child: Column(
//                     children: allPages,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
// }

// // Keep your existing TextFormFieldWidget2 and PriceLabelPromoWidget classes
