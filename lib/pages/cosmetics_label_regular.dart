import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:price_label_web/models/cosmetics_label_regular.dart';

import '../controllers/cosmetics_label_regular_controller.dart';

class PriceLabelNonPromoView extends StatelessWidget {
  const PriceLabelNonPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PriceLabelNoPromoController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cosmetics Label Regular"),
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
    var con = Get.find<PriceLabelNoPromoController>();
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
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            con.pickExcelFile(Get.context!);
                          },
                          child: const Text("Upload"),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () {
                            con.downloadTemplate();
                          },
                          child: const Text("Download Template"),
                        ),
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
                                  width: 300,
                                  child: TextFormFieldWidget2(
                                    controller: con.controllers[index]
                                        ["description"],
                                    title: "Description",
                                  ),
                                ),

                                SizedBox(
                                  height: 30,
                                  width: 100,
                                  child: TextFormFieldWidget2(
                                    controller: con.controllers[index]["price"],
                                    title: "Price",
                                    formatter:
                                        FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$'),
                                    ),
                                    enforced: true,
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
                              con.saveOrUpdatePriceLabelNoPromo();
                            },
                            child:
                                Text(con.isEditMode.value ? "Update" : "Save"),
                          )),
                      ElevatedButton(
                        onPressed: () async {
                          con.downloadPDF(isDownload: true);
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
                          onDoubleTap: () {
                            con.generatePriceLabelNoPromoData();
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
                                                          // New Price Heading
                                                          SizedBox(
                                                            width:
                                                                60, // Match width of New Price
                                                            child: Text(
                                                              "Price",
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
                                                                promo.price
                                                                    .toStringAsFixed(
                                                                        2),
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
                                                con.editPriceLabelNoPromo(
                                                    index);
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
                  // Row(
                  //   children: [
                  //     Obx(
                  //       () => Checkbox.adaptive(
                  //         value: con.isRedColor.value,
                  //         onChanged: (val) {
                  //           con.isRedColor.toggle();
                  //         },
                  //       ),
                  //     ),
                  //     const Text("Red Color")
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 90,
                        child: Text("VAT Text: "),
                      ),
                      SizedBox(
                        height: 30,
                        width: 250,
                        child: TextFormFieldWidget2(
                          title: "VAT Text",
                          controller: con.vatTextController.value,
                          enforced: false,
                          enabled: true,
                          readOnly: false,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          con.vatTextController.value.text =
                              "* All prices are inclusive of VAT";
                        },
                        child: const Text("Default"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 90,
                        child: Text("Optional Text: "),
                      ),
                      SizedBox(
                        height: 30,
                        width: 250,
                        child: TextFormFieldWidget2(
                          title: "Optional Text",
                          controller: con.optionalTextController.value,
                          enforced: false,
                          enabled: true,
                          readOnly: false,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          con.optionalTextController.value.clear();
                        },
                        child: const Text("Clear"),
                      ),
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
    final con = Get.find<PriceLabelNoPromoController>();
    const itemsPerPage = 8;

    return GetBuilder<PriceLabelNoPromoController>(
      builder: (controller) {
        if (controller.data.isEmpty) {
          return Container(
            width: 794,
            height: 1123,
            alignment: Alignment.center,
            child: const Text("No items found"),
          );
        }

        final totalPages = (controller.data.length / itemsPerPage).ceil();
        final scrollController = ScrollController();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "Page ${controller.currentPage.value} of $totalPages",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(width: 25),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.currentPage.value > 1
                            ? controller.currentPage.value--
                            : null,
                        child: const Text("Previous"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            controller.currentPage.value < totalPages
                                ? controller.currentPage.value++
                                : null,
                        child: const Text("Next"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => con.downloadPDF(isDownload: false),
                        child: const Text("Print"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          width: 794,
                          height: 1123,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          color: Colors.white,
                          child: Obx(() => GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 105.0,
                                  mainAxisSpacing: 50.0,
                                  childAspectRatio: 302.36 / 219.21,
                                ),
                                children: [
                                  for (int i = 0; i < itemsPerPage; i++)
                                    if (pageIndex * itemsPerPage + i <
                                        controller.data.length)
                                      PriceLabelPromoWidget(
                                        promo: controller
                                            .data[pageIndex * itemsPerPage + i],
                                        con: con,
                                        // isRed: con.isRedColor.value,
                                      )
                                    else
                                      const SizedBox.shrink(),
                                ],
                              )),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PriceLabelPromoWidget extends StatelessWidget {
  final PriceLabelNoPromoController con;
  final CosmeticsLabelRegular promo;
  final bool? isRed;
  const PriceLabelPromoWidget({
    super.key,
    required this.promo,
    this.isRed = false,
    required this.con,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height for each item
    const totalHeight = 172.5; // Total available height for the container
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
            height: 25,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 210,
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
                    width: 90.5,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        // color: Colors.blue,
                        ),
                    child: const Text(
                      "Price",
                      textAlign: TextAlign.center,
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
                width: 210,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              // Now Price Container
              Container(
                width: 90.5,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "AED",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Myriad Pro',
                              height: 0.8,
                            ),
                          ),
                          Text(
                            promo.items[index].price.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Myriad Pro',
                            ),
                          ),
                        ],
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
                  con.optionalTextController.value.text,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'Myriad Pro',
                    color: isRed == true ? Colors.red : Colors.black,
                  ),
                ),
                Text(
                  con.vatTextController.value.text,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'Myriad Pro',
                    fontWeight: FontWeight.normal,
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
