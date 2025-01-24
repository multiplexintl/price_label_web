import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_to_pdf/capture_wrapper.dart';
import 'package:flutter_to_pdf/export_frame.dart';
import 'package:get/get.dart';
import 'package:price_label_web/controllers/pdf_controller.dart';
import 'package:price_label_web/models/price_label_promo.dart';

import '../controllers/price_label_promo_controller.dart';

class PriceLabelPromoViewTest extends StatelessWidget {
  const PriceLabelPromoViewTest({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PriceLabelPromoController());
    Get.put(PDFController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Label Promo"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEditAndListSection(constraints),
                      const SizedBox(width: 16),
                      _buildPreviewSection2(context),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildEditAndListSection(constraints),
                        const SizedBox(height: 16),
                        // _buildPreviewSection2(context),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewSection2(BuildContext context) {
    var con = Get.find<PriceLabelPromoController>();

    return GetBuilder<PriceLabelPromoController>(
      builder: (controller) {
        const itemsPerPage = 8; // Number of items per page

        if (controller.data.isEmpty) {
          return Container(
            color: Colors.white,
            width: 794, // A4 width in pixels
            height: 1123, // A4 height in pixels
            alignment: Alignment.center,
            child: const Text(
              "No items found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        // Calculate total pages dynamically
        final totalPages = (controller.data.length / itemsPerPage).ceil();
        controller.totalPages.value = totalPages;

        List<Widget> allPages = [];
        for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
          // Calculate data for each page
          final startIndex = pageIndex * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage > controller.data.length)
              ? controller.data.length
              : startIndex + itemsPerPage;
          final pageData = controller.data.sublist(startIndex, endIndex);

          allPages.add(
            Container(
              color: Colors.white,
              width: 794, // A4 width in pixels
              height: 1123, // A4 height in pixels
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              margin: const EdgeInsets.only(bottom: 10), // Add spacing
              alignment: Alignment.topCenter,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 105.0,
                  mainAxisSpacing: 50,
                  childAspectRatio: 302.36 / 219.21,
                ),
                itemCount: pageData.length,
                itemBuilder: (context, index) {
                  final item = pageData[index];
                  return Obx(() => PriceLabelPromoWidget(
                        promo: item,
                        vatText: con.smallText.value,
                        isRed: con.isRedColor.value,
                      ));
                },
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "Page ${controller.currentPage.value} of ${controller.totalPages.value}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (controller.currentPage.value > 1) {
                            controller.currentPage.value--;
                            ScrollController().animateTo(
                              (controller.currentPage.value - 1) * 1123.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text("Previous"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // var pdfCon = Get.fsind<PDFController>();
                          con.generatePdf();
                        },
                        child: const Text("Print"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Continuous Scrolling Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: allPages,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditAndListSection(BoxConstraints constraints) {
    var con = Get.find<PriceLabelPromoController>();
    return SingleChildScrollView(
      child: SizedBox(
        width: 550,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: SizedBox(
                height: 30,
                width: 270,
                child: TextFormFieldWidget2(
                  controller: con.fileNameController,
                  title: "File Name",
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Edit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                // borderRadius: const BorderRadius.only(
                //     bottomLeft: Radius.circular(16),
                //     bottomRight: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(height: 20),
                      const Text("Discount: "),
                      SizedBox(
                        height: 30,
                        width: 250,
                        child: Obx(() => TextFormFieldWidget2(
                              controller: con.percentageController.value,
                              enabled: con.isEnabledPerc.value,
                              title: "Offer Percentage",
                              enforced: true,
                              formatter: FilteringTextInputFormatter.allow(RegExp(
                                  r'^\d*\.?\d{0,2}$')), // Allows digits, optional decimal, and up to 2 decimal places,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: con.controllers.length, // Dynamic rows
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("${index + 1}: "), // Row number
                                SizedBox(
                                  height: 30,
                                  width: 250,
                                  child: TextFormFieldWidget2(
                                    controller: con.controllers[index]
                                        ["description"],
                                    title: "Description",
                                    enabled: con.isEnabled.value,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  width: 100,
                                  child: TextFormFieldWidget2(
                                    controller: con.controllers[index]
                                        ["wasPrice"],
                                    title: "Was Price",
                                    enforced: true,
                                    formatter: FilteringTextInputFormatter
                                        .allow(RegExp(
                                            r'^\d*\.?\d{0,2}$')), // Allows digits, optional decimal, and up to 2 decimal places,
                                    enabled: con.isEnabled.value,
                                    onChanged: (value) {
                                      con.onWasPriceChanged(index, value);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  width: 100,
                                  child: TextFormFieldWidget2(
                                    controller: con.controllers[index]
                                        ["nowPrice"],
                                    title: "Now Price",
                                    formatter:
                                        FilteringTextInputFormatter.digitsOnly,
                                    enforced: true,
                                    readOnly: true,
                                    enabled: con.isEnabled.value,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    con.clearRow(index);
                                  },
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          con.clearAllRows();
                        },
                        child: const Text("Clear"),
                      ),
                      Obx(() => ElevatedButton(
                            onPressed: () {
                              con.saveOrUpdatePriceLabelPromo();
                            },
                            child:
                                Text(con.isEditMode.value ? "Update" : "Save"),
                          )),
                      ElevatedButton(
                        onPressed: () async {
                          await con.generatePdf(isDownload: true);
                        },
                        child: const Text("Export"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // List View Section
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                // borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Header Row
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Items",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            con.clearAllData();
                          },
                          child: Container(
                            height: 30,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Clear all",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Data List
                  Expanded(
                    child: Obx(() => ListView.builder(
                          itemCount: con.data.length,
                          itemBuilder: (context, index) {
                            var item = con.data[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Colors.grey.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      // 1. Sl No
                                      Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: index.isOdd
                                              ? Colors.grey.withOpacity(0.5)
                                              : Colors.white.withOpacity(0.9),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${index + 1}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                      // 2. Items (Takes remaining space between Sl No and Actions)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Percentage
                                              Text(
                                                "Percentage : ${item.percentage}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Headings Row
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Sl No Heading
                                                          SizedBox(
                                                            width:
                                                                25, // Match width of item Sl No
                                                            child: Text(
                                                              "No.",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          // Item Name Heading
                                                          Expanded(
                                                            child: Text(
                                                              "Item Name",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          // Old Price Heading
                                                          SizedBox(
                                                            width:
                                                                60, // Match width of Old Price
                                                            child: Text(
                                                              "Old\nPrice",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          // New Price Heading
                                                          SizedBox(
                                                            width:
                                                                60, // Match width of New Price
                                                            child: Text(
                                                              "New Price",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // List of Items
                                                    ...item.items
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int itemIndex = entry.key;
                                                      var promo = entry.value;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Item Sl No
                                                            SizedBox(
                                                              width:
                                                                  20, // Match width of heading
                                                              child: Text(
                                                                "${itemIndex + 1}.",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium,
                                                              ),
                                                            ),
                                                            // Item Name
                                                            Expanded(
                                                              child: Text(
                                                                promo.name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            // Old Price
                                                            SizedBox(
                                                              width:
                                                                  60, // Match width of heading
                                                              child: Text(
                                                                promo.oldPrice
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            // New Price
                                                            SizedBox(
                                                              width:
                                                                  60, // Match width of heading
                                                              child: Text(
                                                                promo.newPrice
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 3. Actions
                                      Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: index.isOdd
                                              ? Colors.grey.withOpacity(0.5)
                                              : Colors.white.withOpacity(0.9),
                                          borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                con.editPriceLabelPromo(index);
                                              },
                                              icon: const Icon(Icons.edit),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                con.removeDataByIndex(index);
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // preferences
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                // borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Preferences",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox.adaptive(
                          value: con.isRedColor.value,
                          onChanged: (val) {
                            con.isRedColor.toggle();
                          },
                        ),
                      ),
                      const Text("Red Color")
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Text: "),
                      SizedBox(
                        height: 50,
                        width: 250,
                        child: TextFormField(
                          onChanged: con.updateText,
                          initialValue: con.smallText.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    var con = Get.find<PriceLabelPromoController>();

    return GetBuilder<PriceLabelPromoController>(
      builder: (controller) {
        const itemsPerPage = 8; // Number of items per page

        if (controller.data.isEmpty) {
          return Container(
            color: Colors.white,
            width: 794, // A4 width in pixels
            height: 1123, // A4 height in pixels
            alignment: Alignment.center,
            child: const Text(
              "No items found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        // Calculate total pages dynamically
        final totalPages = (controller.data.length / itemsPerPage).ceil();
        controller.totalPages.value = totalPages;

        // Dynamically adjust the repaintKeys list to match the number of pages
        while (controller.repaintKeys.length < totalPages) {
          controller.repaintKeys.add(GlobalKey());
        }

        while (controller.repaintKeys.length > totalPages) {
          controller.repaintKeys.removeLast();
        }

        // Scroll Controller
        final ScrollController scrollController = ScrollController();

        // Listen to Scroll Events
        scrollController.addListener(() {
          final scrollOffset =
              scrollController.offset; // Current scroll position
          const pageHeight = 1123.0; // Fixed height of each A4 page
          final currentPage = (scrollOffset / pageHeight).floor() + 1;

          if (controller.currentPage.value != currentPage) {
            controller.currentPage.value = currentPage.clamp(1, totalPages);
          }
        });

        // Generate content for all pages
        List<Widget> allPages = [];
        for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
          // Calculate data for each page
          final startIndex = pageIndex * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage > controller.data.length)
              ? controller.data.length
              : startIndex + itemsPerPage;
          final pageData = controller.data.sublist(startIndex, endIndex);

          allPages.add(
            RepaintBoundary(
              key: controller.repaintKeys[pageIndex],
              child: Container(
                color: Colors.white,
                width: 794, // A4 width in pixels
                height: 1123, // A4 height in pixels
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                margin: const EdgeInsets.only(
                    bottom: 10), // Add spacing between pages
                alignment: Alignment.topCenter,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 105.0,
                    mainAxisSpacing: 50,
                    childAspectRatio: 302.36 / 219.21,
                  ),
                  itemCount: pageData.length,
                  itemBuilder: (context, index) {
                    final item = pageData[index];
                    return Obx(() => PriceLabelPromoWidget(
                          promo: item,
                          vatText: con.smallText.value,
                          isRed: con.isRedColor.value,
                        ));
                  },
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "Page ${controller.currentPage.value} of ${controller.totalPages.value}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (controller.currentPage.value > 1) {
                            controller.currentPage.value--;
                            scrollController.animateTo(
                              (controller.currentPage.value - 1) * 1123.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text("Previous"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.currentPage.value < totalPages) {
                            controller.currentPage.value++;
                            scrollController.animateTo(
                              (controller.currentPage.value - 1) * 1123.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text("Next"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // con.generatePdf;
                        },
                        child: const Text("Print"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Continuous Scrolling Section
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: allPages,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TextFormFieldWidget2 extends StatelessWidget {
  final String title;
  final bool enforced;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextInputFormatter? formatter;
  final TextEditingController? controller;
  final bool? enabled;
  final bool readOnly;

  const TextFormFieldWidget2({
    super.key,
    required this.title,
    this.enforced = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.formatter,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.black,
        fontFamily: 'Myriad Pro',
        fontSize: 10,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        formatter ?? FilteringTextInputFormatter.singleLineFormatter,
        LengthLimitingTextInputFormatter(
          7, // Set max length for the input
          maxLengthEnforcement: enforced
              ? MaxLengthEnforcement.enforced
              : MaxLengthEnforcement.none,
        ),
      ],
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: 10,
          top: 2,
          bottom: 2,
        ),
        border: const OutlineInputBorder(),
        labelText: title,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'Myriad Pro',
          fontSize: 10,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}

class PriceLabelPromoWidget extends StatelessWidget {
  final PriceLabelPromo promo;
  final String? vatText;
  final bool? isRed;
  const PriceLabelPromoWidget({
    super.key,
    required this.promo,
    this.vatText,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height for each item
    const totalHeight = 167.0; // Total available height for the container
    final itemCount = promo.items.length;
    final itemHeight =
        itemCount > 0 ? totalHeight / itemCount : 0; // Maximum 4 items
    return Container(
      height: 219.21,
      width: 302.36,
      // 302.36 / 188.98,
      decoration: BoxDecoration(
        // color: Colors.amber,
        border: Border.all(
          color: isRed == true ? Colors.red : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 30,
            width: 302.36,
            decoration: BoxDecoration(
                // color: Colors.amber,
                border: Border(
                    bottom: BorderSide(
              color: isRed == true ? Colors.red : Colors.black,
              width: 2,
            ))),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 155,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        // color: Colors.blue,
                        border: Border(
                            right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ))),
                    child: const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                  Container(
                    width: 48.5,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(
                          color: isRed == true ? Colors.red : Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "WAS",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      border: Border(
                        right: BorderSide(
                          color: isRed == true ? Colors.red : Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Discount",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        // color: Colors.blue,
                        ),
                    child: const Text(
                      "NOW",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              // description
              Container(
                width: 155,
                height: totalHeight,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  border: Border(
                    right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: itemCount < 4
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: List.generate(itemCount, (index) {
                    return Container(
                      height:
                          itemHeight.toDouble(), // Dynamic height for each item
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < itemCount - 1
                                ? isRed == true
                                    ? Colors.red
                                    : Colors.black
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        promo.items[index].name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // was
              Container(
                width: 48.5,
                height: 167,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  border: Border(
                    right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: itemCount < 4
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: List.generate(itemCount, (index) {
                    return Container(
                      height:
                          itemHeight.toDouble(), // Dynamic height for each item
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < itemCount - 1
                                ? isRed == true
                                    ? Colors.red
                                    : Colors.black
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        promo.items[index].oldPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                          decoration: TextDecoration.lineThrough,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationThickness: 2,
                          decorationColor:
                              isRed == true ? Colors.red : Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // discount
              Container(
                width: 48,
                height: 167,
                decoration: BoxDecoration(
                  // color: Colors.amber,
                  border: Border(
                    right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "  ${promo.percentage}%",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                        fontWeight: FontWeight.bold,
                        height: 0.4,
                      ),
                    ),
                    const Text(
                      "OFF",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Now Price Container
              Container(
                width: 48.5,
                height: totalHeight,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: itemCount < 4
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: List.generate(itemCount, (index) {
                    return Container(
                      height:
                          itemHeight.toDouble(), // Dynamic height for each item
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < itemCount - 1
                                ? isRed == true
                                    ? Colors.red
                                    : Colors.black
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        promo.items[index].newPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 19,
            width: 302.36,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 10, left: 5),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: isRed == true ? Colors.red : Colors.black,
                    width: 1,
                  ),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "* All prices are in AED",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Myriad Pro',
                    color: isRed == true ? Colors.red : Colors.black,
                  ),
                ),
                Text(
                  vatText ?? "* All Prices Inclusive of VAT",
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Myriad Pro',
                    color: isRed == true ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
