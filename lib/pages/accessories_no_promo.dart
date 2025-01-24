import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/accessory_label_no_promo_controller.dart';
import '../models/accessory_no_promo.dart';

class AccessoriesNoPromoView extends StatelessWidget {
  const AccessoriesNoPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccessoryLabelNoPromoController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accessory Label No Promotion"),
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
                      _buildPreviewSection(),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildEditAndListSection(constraints),
                        const SizedBox(height: 16),
                        _buildPreviewSection(),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildEditAndListSection(BoxConstraints constraints) {
    var con = Get.find<AccessoryLabelNoPromoController>();
    return SingleChildScrollView(
      child: SizedBox(
        width: 550,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
              width: 270,
              child: TextFormFieldWidget2(
                controller: con.fileNameController,
                title: "File Name",
              ),
            ),
            const SizedBox(height: 20),
            // Edit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 170,
                        child: TextFormFieldWidget2(
                          controller: con.brandNameController,
                          title: "Brand",
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 170,
                        child: TextFormFieldWidget2(
                          controller: con.barcodeController,
                          title: "Barcode",
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 100,
                        child: TextFormFieldWidget2(
                          controller: con.priceController,
                          title: "Price",
                          enforced: true,
                          formatter: FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
              ),
              padding: const EdgeInsets.only(bottom: 10),
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

                  // Content Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header Row
                          Container(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            decoration: const BoxDecoration(
                              color: Colors.blueGrey,
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Sl No",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Name & Barcode",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Price",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Actions",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Data List
                          Expanded(
                            child: Obx(() => ListView.builder(
                                  itemCount: con.data.length,
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 5,
                                    bottom: 10,
                                  ),
                                  itemBuilder: (context, index) {
                                    var item = con.data[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? Colors.white
                                              : Colors.blueGrey
                                                  .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            // Sl No
                                            Expanded(
                                              child: Text(
                                                "${index + 1}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Name
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.brandName
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    item.barcode.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Old Price
                                            Expanded(
                                              child: Text(
                                                item.price.toString(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Action Buttons
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.black),
                                                    onPressed: () {
                                                      con.editPriceLabelPromo(
                                                          index);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      con.removeDataByIndex(
                                                          index);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.copy,
                                                        color: Colors.black),
                                                    onPressed: () {
                                                      con.copyPriceLabelPromo(
                                                          index);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          ),
                        ],
                      ),
                    ),
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
    var con = Get.find<AccessoryLabelNoPromoController>();

    return GetBuilder<AccessoryLabelNoPromoController>(
      builder: (controller) {
        const itemsPerPage = 18; // Number of items per page

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
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 25,
                    childAspectRatio: 226.77 / 151.18,
                  ),
                  itemCount: pageData.length,
                  itemBuilder: (context, index) {
                    final item = pageData[index];
                    return Obx(() => AccessoriesPromoWidget(
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
                        onPressed: con.generatePdf,
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

class AccessoriesPromoWidget extends StatelessWidget {
  final AccessoryNoPromo promo;
  final String? vatText;
  final bool? isRed;
  const AccessoriesPromoWidget({
    super.key,
    required this.promo,
    this.vatText,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 151.18,
      width: 226.77,
      // 226.77 / 188.98,
      decoration: BoxDecoration(
        // color: Colors.amber,
        border: Border.all(
          color: isRed == true ? Colors.red : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // heading
          Container(
            width: 227,
            height: 30,
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
                    width: 160,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        // color: Colors.blue,
                        border: Border(
                            right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ))),
                    child: Text(
                      promo.brandName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Myriad Pro',
                        fontWeight: FontWeight.bold,
                        height: 1.7,
                      ),
                    ),
                  ),
                  Container(
                    width: 65.69,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        // color: Colors.blue,
                        ),
                    child: const Text(
                      "PRICE",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // items
          Row(
            children: [
              // brand
              Container(
                width: 160.07,
                height: 105,
                decoration: BoxDecoration(
                  // color: Colors.green,
                  border: Border(
                    right: BorderSide(
                      color: isRed == true ? Colors.red : Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  promo.barcode.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Myriad Pro',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // price
              Container(
                width: 65,
                height: 105,
                alignment: Alignment.center,
                child: Text(
                  promo.price.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Myriad Pro',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          // text
          Container(
            height: 15,
            decoration: BoxDecoration(
              // color: Colors.amber,
              border: Border(
                top: BorderSide(
                  color: isRed == true ? Colors.red : Colors.black,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "* All prices are in AED",
                    style: TextStyle(
                      fontSize: 8,
                      fontFamily: 'Myriad Pro',
                      color: isRed == true ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    vatText ?? "* All Prices Inclusive of VAT",
                    style: TextStyle(
                      fontSize: 8,
                      fontFamily: 'Myriad Pro',
                      color: isRed == true ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
