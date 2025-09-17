import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:price_label_web/models/accessory_promo.dart';
import '../controllers/accessory_label_promo_controller.dart';
import '../widgets/diagonal_strike_paint.dart';

class AccessoriesPromoView extends StatelessWidget {
  const AccessoriesPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccessoryLabelPromoController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accessory Label Promotion"),
        automaticallyImplyLeading: true,
        actions: [
          // Always show preferences in AppBar
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPreferencesDialog(context),
            padding: const EdgeInsets.only(right: 20),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 25, right: 25),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1400;
            log("Width: ${constraints.maxWidth}");
            log("Height: ${constraints.maxHeight}");
            log("isWide: $isWide");

            return isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEditAndListSection(constraints),
                      const SizedBox(width: 16),
                      Expanded(
                          child:
                              _buildPreviewSection()), // Keep original preview
                    ],
                  )
                : Column(
                    children: [
                      // Top row: edit and view widgets side by side
                      SizedBox(
                        height:
                            constraints.maxHeight * 0.4, // 40% of screen height
                        child: Row(
                          children: [
                            Expanded(
                                child: _editDescriptionWidget(
                                    Get.find<AccessoryLabelPromoController>(),
                                    constraints)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _viewLabelsWidget(
                                    Get.find<AccessoryLabelPromoController>(),
                                    constraints)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bottom: Preview section (keep original)
                      Expanded(
                          child:
                              _buildPreviewSection()), // Keep original preview with Expanded
                    ],
                  );
          },
        ),
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    var con = Get.find<AccessoryLabelPromoController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 450,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Preferences",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Obx(() => Checkbox.adaptive(
                          value: con.isRedColor.value,
                          onChanged: (val) => con.isRedColor.toggle(),
                        )),
                    const Text("Red Color")
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Strike Through Options"),
                    const SizedBox(height: 5),
                    Obx(() => Row(
                          children: [
                            Row(
                              children: [
                                Radio<int>(
                                  value: 1,
                                  groupValue: con.selectedRadio.value,
                                  onChanged: (value) =>
                                      con.selectedRadio.value = value!,
                                ),
                                const Text("Diagonal"),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Radio<int>(
                                  value: 2,
                                  groupValue: con.selectedRadio.value,
                                  onChanged: (value) =>
                                      con.selectedRadio.value = value!,
                                ),
                                const Text("Horizontal"),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text("VAT Text: ")),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextFormFieldWidget2(
                          title: "VAT Text",
                          controller: con.vatTextController.value,
                          enforced: false,
                          enabled: true,
                          readOnly: false,
                        ),
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
                const SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text("Optional Text: ")),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextFormFieldWidget2(
                          title: "Optional Text",
                          controller: con.optionalTextController.value,
                          enforced: false,
                          enabled: true,
                          readOnly: false,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => con.optionalTextController.value.clear(),
                      child: const Text("Clear"),
                    ),
                  ],
                ),
                const Spacer(),
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

  Widget _buildEditAndListSection(BoxConstraints constraints) {
    var con = Get.find<AccessoryLabelPromoController>();
    return SizedBox(
      width: 550,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _editDescriptionWidget(con, constraints),
            const SizedBox(height: 10),
            _viewLabelsWidget(con, constraints),
            // Preferences removed - now in AppBar dialog
          ],
        ),
      ),
    );
  }

  Container _viewLabelsWidget(
      AccessoryLabelPromoController con, BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 1400;
    final containerHeight = isWide
        ? 400.0
        : double.infinity; // Let it take available height when narrow

    return Container(
      width: double.infinity,
      height:
          isWide ? containerHeight : null, // Only set height for wide screens
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
                const Text("Items", style: TextStyle(color: Colors.white)),
                InkWell(
                  onTap: () => con.clearAllData(),
                  onDoubleTap: () => con.generateAccessoryPromoData(),
                  child: Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: const Text("Clear all",
                        style: TextStyle(color: Colors.white)),
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
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("No",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isWide ? 14 : 12)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("Name & Barcode",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isWide ? 14 : 12)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("Old",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isWide ? 14 : 12)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("New",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isWide ? 14 : 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: isWide ? 30 : 15),
                            child: Text("Actions",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: isWide ? 14 : 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Data List
                  Expanded(
                    child: Obx(() => ListView.builder(
                          itemCount: con.data.length,
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 5,
                            bottom: 10,
                          ),
                          itemBuilder: (context, index) {
                            var item = con.data[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                height: isWide ? 50 : 40, // Responsive height
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Colors.white
                                      : Colors.blueGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    // Sl No
                                    Expanded(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: isWide ? 16 : 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Name
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.brandName.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: isWide ? 14 : 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item.barcode.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: isWide ? 14 : 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Old Price
                                    Expanded(
                                      child: Text(
                                        item.oldPrice.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: isWide ? 14 : 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // New Price
                                    Expanded(
                                      child: Text(
                                        item.newPrice.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: isWide ? 14 : 11,
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
                                          SizedBox(
                                            width: isWide ? 35 : 25,
                                            height: isWide ? 35 : 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.edit,
                                                  color: Colors.black,
                                                  size: isWide ? 18 : 14),
                                              onPressed: () => con
                                                  .editPriceLabelPromo(index),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isWide ? 35 : 25,
                                            height: isWide ? 35 : 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red,
                                                  size: isWide ? 18 : 14),
                                              onPressed: () =>
                                                  con.removeDataByIndex(index),
                                            ),
                                          ),
                                          SizedBox(
                                            width: isWide ? 35 : 25,
                                            height: isWide ? 35 : 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.copy,
                                                  color: Colors.black,
                                                  size: isWide ? 18 : 14),
                                              onPressed: () => con
                                                  .copyPriceLabelPromo(index),
                                            ),
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
    );
  }

  Widget _editDescriptionWidget(
      AccessoryLabelPromoController con, BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 1400;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File name field
          SizedBox(
            height: 30,
            width: isWide ? 270 : double.infinity,
            child: TextFormFieldWidget2(
              controller: con.fileNameController,
              title: "File Name",
            ),
          ),
          const SizedBox(height: 15),

          // Edit Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // First row: Discount percentage and buttons
                isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 130,
                            child: Obx(() => TextFormFieldWidget2(
                                  controller: con.percentageController.value,
                                  title: "Discount %",
                                  enabled: con.isEnabledPerc.value,
                                  enforced: true,
                                  formatter: FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$')),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => con.pickExcelFile(Get.context!),
                              child: const Text("Upload",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 140,
                            child: ElevatedButton(
                              onPressed: () => con.downloadTemplate(),
                              child: const Text("Template",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 25,
                            width: double.infinity,
                            child: Obx(() => TextFormFieldWidget2(
                                  controller: con.percentageController.value,
                                  title: "Discount %",
                                  enabled: con.isEnabledPerc.value,
                                  enforced: true,
                                  formatter: FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$')),
                                )),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        con.pickExcelFile(Get.context!),
                                    child: const Text("Upload",
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: ElevatedButton(
                                    onPressed: () => con.downloadTemplate(),
                                    child: const Text("Template",
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                const SizedBox(height: 10),

                // Second row: Product details
                Obx(() => isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 120,
                            child: TextFormFieldWidget2(
                              controller: con.brandNameController.value,
                              title: "Brand",
                              enabled: con.isEnabled.value,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 130,
                            child: TextFormFieldWidget2(
                              controller: con.barcodeController.value,
                              title: "Barcode",
                              enabled: con.isEnabled.value,
                              enforced: true,
                              formatter: FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z0-9]{0,13}$')),
                              maxLength: 13,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 80,
                            child: TextFormFieldWidget2(
                              controller: con.oldPriceController.value,
                              title: "Was Price",
                              enabled: con.isEnabled.value,
                              enforced: true,
                              formatter: FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}$')),
                              onChanged: con.onWasPriceChanged,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 80,
                            child: TextFormFieldWidget2(
                              controller: con.newPriceController.value,
                              title: "Now Price",
                              readOnly: true,
                              enabled: con.isEnabled.value,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextFormFieldWidget2(
                                    controller: con.brandNameController.value,
                                    title: "Brand",
                                    enabled: con.isEnabled.value,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextFormFieldWidget2(
                                    controller: con.barcodeController.value,
                                    title: "Barcode",
                                    enabled: con.isEnabled.value,
                                    enforced: true,
                                    formatter:
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^[a-zA-Z0-9]{0,13}$')),
                                    maxLength: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextFormFieldWidget2(
                                    controller: con.oldPriceController.value,
                                    title: "Was Price",
                                    enabled: con.isEnabled.value,
                                    enforced: true,
                                    formatter:
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}$')),
                                    onChanged: con.onWasPriceChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: TextFormFieldWidget2(
                                    controller: con.newPriceController.value,
                                    title: "Now Price",
                                    readOnly: true,
                                    enabled: con.isEnabled.value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),

                const SizedBox(height: 15),

                // Action buttons
                isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => con.clearAllRows(),
                            child: const Text("Clear"),
                          ),
                          Obx(() => ElevatedButton(
                                onPressed: () =>
                                    con.saveOrUpdatePriceLabelPromo(),
                                child: Text(
                                    con.isEditMode.value ? "Update" : "Save"),
                              )),
                          ElevatedButton(
                            onPressed: () async =>
                                con.downloadPDF(isDownload: true),
                            child: const Text("Export"),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: ElevatedButton(
                                    onPressed: () => con.clearAllRows(),
                                    child: const Text("Clear",
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 25,
                                  child: Obx(() => ElevatedButton(
                                        onPressed: () =>
                                            con.saveOrUpdatePriceLabelPromo(),
                                        child: Text(
                                            con.isEditMode.value
                                                ? "Update"
                                                : "Save",
                                            style: TextStyle(fontSize: 12)),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 25,
                            child: ElevatedButton(
                              onPressed: () async =>
                                  con.downloadPDF(isDownload: true),
                              child: const Text("Export",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ORIGINAL PREVIEW SECTION - UNCHANGED
  Widget _buildPreviewSection() {
    final con = Get.find<AccessoryLabelPromoController>();
    const itemsPerPage = 18;

    return GetBuilder<AccessoryLabelPromoController>(
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
                        padding: const EdgeInsets.only(bottom: 20),
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
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 25,
                                  childAspectRatio: 226.77 / 151.18,
                                ),
                                children: [
                                  for (int i = 0; i < itemsPerPage; i++)
                                    if (pageIndex * itemsPerPage + i <
                                        controller.data.length)
                                      AccessoriesPromoWidget(
                                        con: con,
                                        promo: controller
                                            .data[pageIndex * itemsPerPage + i],
                                        isRed: con.isRedColor.value,
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

// Keep existing widgets unchanged
class AccessoriesPromoWidget extends StatelessWidget {
  final AccessoryPromo promo;
  final String? vatText;
  final bool? isRed;
  final AccessoryLabelPromoController con;

  const AccessoriesPromoWidget({
    super.key,
    required this.promo,
    this.vatText,
    this.isRed = false,
    required this.con,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 151.18,
      width: 226.77,
      decoration: BoxDecoration(
        border: Border.all(
          color: isRed == true ? Colors.red : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 227,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: isRed == true ? Colors.red : Colors.black,
              width: 2,
            ))),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 113.38,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isRed == true ? Colors.red : Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "ITEM",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 56.69,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
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
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                  Container(
                    width: 56.69,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "NOW",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Myriad Pro',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 65,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Container(
                  width: 113.60,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isRed == true ? Colors.red : Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        promo.brandName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                          fontWeight: FontWeight.w900,
                          height: 0.8,
                        ),
                      ),
                      Text(
                        promo.barcode.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56.9,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isRed == true ? Colors.red : Colors.black,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: isRed == true ? Colors.red : Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IntrinsicHeight(
                        child: Obx(
                          () => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "AED",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Myriad Pro',
                                  fontWeight: FontWeight.w900,
                                  height: 0.8,
                                ),
                              ),
                              Text(
                                promo.oldPrice.toStringAsFixed(2),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Myriad Pro',
                                  fontWeight: FontWeight.w900,
                                  decoration: con.selectedRadio.value == 2
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationThickness: 3,
                                  decorationColor:
                                      isRed == true ? Colors.red : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(() => Visibility(
                            visible: con.selectedRadio.value == 1,
                            child: Positioned.fill(
                              child: CustomPaint(
                                painter: DiagonalStrikeThroughPainter(
                                  color:
                                      isRed == true ? Colors.red : Colors.black,
                                  strokeWidth: 2,
                                  horizontalPadding: 0,
                                  verticalPadding: 0,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 56.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isRed == true ? Colors.red : Colors.black,
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
                          fontWeight: FontWeight.w900,
                          height: 0.8,
                        ),
                      ),
                      Text(
                        promo.newPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Myriad Pro',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 35,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Container(
                  width: 113.60,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isRed == true ? Colors.red : Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 113.4,
                  alignment: Alignment.center,
                  child: Text(
                    "${promo.percentage}% OFF",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Myriad Pro',
                      fontWeight: FontWeight.w900,
                      decorationColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 15,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isRed == true ? Colors.red : Colors.black,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.only(right: 10, top: 5, left: 10),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      con.optionalTextController.value.text,
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'Myriad Pro',
                        color: isRed == true ? Colors.red : Colors.black,
                      ),
                    ),
                    Text(
                      con.vatTextController.value.text,
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'Myriad Pro',
                        color: isRed == true ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class TextFormFieldWidget2 extends StatelessWidget {
  final String title;
  final bool enforced;
  final int? maxLength;
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
    this.maxLength,
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
          maxLength ?? 7,
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:price_label_web/models/accessory_promo.dart';
// import 'package:price_label_web/pages/main_page.dart';
// import '../controllers/accessory_label_promo_controller.dart';
// import '../widgets/diagonal_strike_paint.dart';

// class AccessoriesPromoView extends StatelessWidget {
//   const AccessoriesPromoView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(AccessoryLabelPromoController());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Accessory Label Promotion"),
//         automaticallyImplyLeading: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isWide = constraints.maxWidth > 800;
//             return isWide
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildEditAndListSection(constraints),
//                       const SizedBox(width: 16),
//                       _buildPreviewSection(),
//                     ],
//                   )
//                 : SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         _buildEditAndListSection(constraints),
//                         const SizedBox(height: 16),
//                         _buildPreviewSection(),
//                       ],
//                     ),
//                   );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEditAndListSection(BoxConstraints constraints) {
//     var con = Get.find<AccessoryLabelPromoController>();
//     return SingleChildScrollView(
//       child: SizedBox(
//         width: 550,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20),
//               child: SizedBox(
//                 height: 30,
//                 width: 270,
//                 child: TextFormFieldWidget2(
//                   controller: con.fileNameController,
//                   title: "File Name",
//                 ),
//               ),
//             ),
//             // Edit Section
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.amber.shade100,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(
//                           height: 30,
//                           width: 150,
//                           child: Obx(() => TextFormFieldWidget2(
//                                 controller: con.percentageController.value,
//                                 title: "Discount Percentage",
//                                 enabled: con.isEnabledPerc.value,
//                                 enforced: true,
//                                 formatter: FilteringTextInputFormatter.allow(
//                                   RegExp(r'^\d*\.?\d{0,2}$'),
//                                 ),
//                               )),
//                         ),
//                         SizedBox(
//                           height: 30,
//                           width: 150,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               con.pickExcelFile(Get.context!);
//                             },
//                             child: const Text("Upload"),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 30,
//                           width: 180,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               con.downloadTemplate();
//                             },
//                             child: const Text("Download Template"),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Obx(() => Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           SizedBox(
//                             height: 30,
//                             width: 150,
//                             child: TextFormFieldWidget2(
//                               controller: con.brandNameController.value,
//                               title: "Brand",
//                               enabled: con.isEnabled.value,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: 170,
//                             child: TextFormFieldWidget2(
//                               controller: con.barcodeController.value,
//                               title: "Barcode",
//                               enabled: con.isEnabled.value,
//                               enforced: true,
//                               formatter: FilteringTextInputFormatter.allow(
//                                 RegExp(r'^[a-zA-Z0-9]{0,13}$'),
//                               ),
//                               maxLength: 13,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: 70,
//                             child: TextFormFieldWidget2(
//                               controller: con.oldPriceController.value,
//                               title: "Was Price",
//                               enabled: con.isEnabled.value,
//                               enforced: true,
//                               formatter: FilteringTextInputFormatter.allow(
//                                 RegExp(r'^\d*\.?\d{0,2}$'),
//                               ),
//                               onChanged: con.onWasPriceChanged,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 30,
//                             width: 70,
//                             child: TextFormFieldWidget2(
//                               controller: con.newPriceController.value,
//                               title: "Now Price",
//                               readOnly: true,
//                               enabled: con.isEnabled.value,
//                             ),
//                           ),
//                         ],
//                       )),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           con.clearAllRows();
//                         },
//                         child: const Text("Clear"),
//                       ),
//                       Obx(() => ElevatedButton(
//                             onPressed: () {
//                               con.saveOrUpdatePriceLabelPromo();
//                             },
//                             child:
//                                 Text(con.isEditMode.value ? "Update" : "Save"),
//                           )),
//                       ElevatedButton(
//                         onPressed: () async {
//                           con.downloadPDF(isDownload: true);
//                         },
//                         child: const Text("Export"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//             // List View Section
//             Container(
//               width: double.infinity,
//               height: 400,
//               decoration: BoxDecoration(
//                 color: Colors.lightBlueAccent.shade100,
//               ),
//               padding: const EdgeInsets.only(bottom: 10),
//               child: Column(
//                 children: [
//                   // Header Row
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(8.0),
//                     decoration: const BoxDecoration(
//                       color: Colors.blueGrey,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Items",
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             con.clearAllData();
//                           },
//                           onDoubleTap: () {
//                             con.generateAccessoryPromoData();
//                           },
//                           child: Container(
//                             height: 30,
//                             width: 70,
//                             decoration: BoxDecoration(
//                               color: Colors.deepOrangeAccent,
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             alignment: Alignment.center,
//                             child: const Text(
//                               "Clear all",
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),

//                   // Content Section
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.lightBlueAccent.shade100,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         children: [
//                           // Header Row
//                           Container(
//                             padding: const EdgeInsets.only(left: 25, right: 25),
//                             decoration: const BoxDecoration(
//                               color: Colors.blueGrey,
//                             ),
//                             child: const Row(
//                               children: [
//                                 Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                     "Sl No",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text(
//                                     "Name & Barcode",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                     "Old",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                     "New",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Padding(
//                                     padding: EdgeInsets.only(left: 30),
//                                     child: Text(
//                                       "Actions",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Data List
//                           Expanded(
//                             child: Obx(() => ListView.builder(
//                                   itemCount: con.data.length,
//                                   padding: const EdgeInsets.only(
//                                     left: 15,
//                                     right: 15,
//                                     top: 5,
//                                     bottom: 10,
//                                   ),
//                                   itemBuilder: (context, index) {
//                                     var item = con.data[index];
//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Container(
//                                         height: 50,
//                                         decoration: BoxDecoration(
//                                           color: index.isEven
//                                               ? Colors.white
//                                               : Colors.blueGrey
//                                                   .withOpacity(0.5),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         padding: const EdgeInsets.only(left: 5),
//                                         child: Row(
//                                           children: [
//                                             // Sl No
//                                             Expanded(
//                                               child: Text(
//                                                 "${index + 1}",
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             // Name
//                                             Expanded(
//                                               flex: 3,
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     item.brandName
//                                                         .toUpperCase(),
//                                                     style: const TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                   Text(
//                                                     item.barcode.toUpperCase(),
//                                                     style: const TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // Old Price
//                                             Expanded(
//                                               child: Text(
//                                                 item.oldPrice
//                                                     .toStringAsFixed(2),
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             // New Price
//                                             Expanded(
//                                               child: Text(
//                                                 item.newPrice
//                                                     .toStringAsFixed(2),
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             // Action Buttons
//                                             Expanded(
//                                               flex: 2,
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 children: [
//                                                   IconButton(
//                                                     icon: const Icon(Icons.edit,
//                                                         color: Colors.black),
//                                                     onPressed: () {
//                                                       con.editPriceLabelPromo(
//                                                           index);
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: const Icon(
//                                                         Icons.delete,
//                                                         color: Colors.red),
//                                                     onPressed: () {
//                                                       con.removeDataByIndex(
//                                                           index);
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: const Icon(Icons.copy,
//                                                         color: Colors.black),
//                                                     onPressed: () {
//                                                       con.copyPriceLabelPromo(
//                                                           index);
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//             // preferences
//             Container(
//               width: double.infinity,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Colors.blueGrey.shade100,
//                 // borderRadius: BorderRadius.circular(16),
//               ),
//               padding: const EdgeInsets.only(left: 10, right: 10),
//               child: Column(
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       "Preferences",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Obx(
//                         () => Checkbox.adaptive(
//                           value: con.isRedColor.value,
//                           onChanged: (val) {
//                             con.isRedColor.toggle();
//                           },
//                         ),
//                       ),
//                       const Text("Red Color")
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // radio buttons for strike through modal
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("  Strike Through Options"),
//                       const SizedBox(height: 5),
//                       Obx(() => Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Radio<int>(
//                                     value: 1,
//                                     groupValue: con.selectedRadio.value,
//                                     onChanged: (value) {
//                                       con.selectedRadio.value = value!;
//                                     },
//                                   ),
//                                   const Text("Diagonal"),
//                                 ],
//                               ),
//                               const SizedBox(
//                                   width: 20), // Space between buttons
//                               Row(
//                                 children: [
//                                   Radio<int>(
//                                     value: 2,
//                                     groupValue: con.selectedRadio.value,
//                                     onChanged: (value) {
//                                       con.selectedRadio.value = value!;
//                                     },
//                                   ),
//                                   const Text("Horizontal"),
//                                 ],
//                               ),
//                             ],
//                           )),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       const SizedBox(
//                         width: 90,
//                         child: Text("VAT Text: "),
//                       ),
//                       SizedBox(
//                         height: 30,
//                         width: 250,
//                         child: TextFormFieldWidget2(
//                           title: "VAT Text",
//                           controller: con.vatTextController.value,
//                           enforced: false,
//                           enabled: true,
//                           readOnly: false,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           con.vatTextController.value.text =
//                               "* All prices are inclusive of VAT";
//                         },
//                         child: const Text("Default"),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       const SizedBox(
//                         width: 90,
//                         child: Text("Optional Text: "),
//                       ),
//                       SizedBox(
//                         height: 30,
//                         width: 250,
//                         child: TextFormFieldWidget2(
//                           title: "Optional Text",
//                           controller: con.optionalTextController.value,
//                           enforced: false,
//                           enabled: true,
//                           readOnly: false,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           con.optionalTextController.value.clear();
//                         },
//                         child: const Text("Clear"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviewSection() {
//     final con = Get.find<AccessoryLabelPromoController>();
//     const itemsPerPage = 18;

//     return GetBuilder<AccessoryLabelPromoController>(
//       builder: (controller) {
//         if (controller.data.isEmpty) {
//           return Container(
//             width: 794,
//             height: 1123,
//             alignment: Alignment.center,
//             child: const Text("No items found"),
//           );
//         }

//         final totalPages = (controller.data.length / itemsPerPage).ceil();
//         final scrollController = ScrollController();

//         return Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Obx(() => Text(
//                         "Page ${controller.currentPage.value} of $totalPages",
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => controller.currentPage.value > 1
//                             ? controller.currentPage.value--
//                             : null,
//                         child: const Text("Previous"),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: () =>
//                             controller.currentPage.value < totalPages
//                                 ? controller.currentPage.value++
//                                 : null,
//                         child: const Text("Next"),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: () => con.downloadPDF(isDownload: false),
//                         child: const Text("Print"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 controller: scrollController,
//                 child: Column(
//                   children: [
//                     for (int pageIndex = 0; pageIndex < totalPages; pageIndex++)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 20),
//                         child: Container(
//                           width: 794,
//                           height: 1123,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 20),
//                           color: Colors.white,
//                           child: Obx(() => GridView(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 3,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 25,
//                                   childAspectRatio: 226.77 / 151.18,
//                                 ),
//                                 children: [
//                                   for (int i = 0; i < itemsPerPage; i++)
//                                     if (pageIndex * itemsPerPage + i <
//                                         controller.data.length)
//                                       AccessoriesPromoWidget(
//                                         con: con,
//                                         promo: controller
//                                             .data[pageIndex * itemsPerPage + i],
//                                         isRed: con.isRedColor.value,
//                                       )
//                                     else
//                                       const SizedBox.shrink(),
//                                 ],
//                               )),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class AccessoriesPromoWidget extends StatelessWidget {
//   final AccessoryPromo promo;
//   final String? vatText;
//   final bool? isRed;
//   final AccessoryLabelPromoController con;
//   const AccessoriesPromoWidget({
//     super.key,
//     required this.promo,
//     this.vatText,
//     this.isRed = false,
//     required this.con,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 151.18,
//       width: 226.77,
//       // 226.77 / 188.98,
//       decoration: BoxDecoration(
//         // color: Colors.amber,
//         border: Border.all(
//           color: isRed == true ? Colors.red : Colors.black,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           // heading
//           Container(
//             width: 227,
//             height: 30,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//                 border: Border(
//                     bottom: BorderSide(
//               color: isRed == true ? Colors.red : Colors.black,
//               width: 2,
//             ))),
//             child: IntrinsicHeight(
//               child: Row(
//                 children: [
//                   Container(
//                     width: 113.38,
//                     height: 30,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       border: Border(
//                         right: BorderSide(
//                           color: isRed == true ? Colors.red : Colors.black,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: const Text(
//                       "ITEM",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Myriad Pro',
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 56.69,
//                     height: 30,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       // color: Colors.blue,
//                       border: Border(
//                         right: BorderSide(
//                           color: isRed == true ? Colors.red : Colors.black,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: const Text(
//                       "WAS",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Myriad Pro',
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 56.69,
//                     height: 50,
//                     alignment: Alignment.center,
//                     decoration: const BoxDecoration(
//                         // color: Colors.blue,
//                         ),
//                     child: const Text(
//                       "NOW",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Myriad Pro',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // items
//           Container(
//             height: 65,
//             decoration: const BoxDecoration(color: Colors.transparent),
//             child: Row(
//               children: [
//                 // barcode
//                 Container(
//                   width: 113.60,
//                   decoration: BoxDecoration(
//                     // color: Colors.green,
//                     border: Border(
//                       right: BorderSide(
//                         color: isRed == true ? Colors.red : Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   alignment: Alignment.center,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         promo.brandName.toUpperCase(),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'Myriad Pro',
//                           fontWeight: FontWeight.w900,
//                           height: 0.8,
//                         ),
//                       ),
//                       Text(
//                         promo.barcode.toUpperCase(),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'Myriad Pro',
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // was
//                 Container(
//                   width: 56.9,
//                   decoration: BoxDecoration(
//                     // color: Colors.green,
//                     border: Border(
//                       right: BorderSide(
//                         color: isRed == true ? Colors.red : Colors.black,
//                         width: 1,
//                       ),
//                       bottom: BorderSide(
//                         color: isRed == true ? Colors.red : Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   alignment: Alignment.center,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       IntrinsicHeight(
//                         child: Obx(
//                           () => Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text(
//                                 "AED",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontFamily: 'Myriad Pro',
//                                   fontWeight: FontWeight.w900,
//                                   height: 0.8,
//                                 ),
//                               ),
//                               Text(
//                                 promo.oldPrice.toStringAsFixed(2),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Myriad Pro',
//                                   fontWeight: FontWeight.w900,
//                                   decoration: con.selectedRadio.value == 2
//                                       ? TextDecoration.lineThrough
//                                       : TextDecoration.none,
//                                   decorationStyle: TextDecorationStyle.solid,
//                                   decorationThickness: 3,
//                                   decorationColor:
//                                       isRed == true ? Colors.red : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Obx(() => Visibility(
//                             visible: con.selectedRadio.value == 1,
//                             child: Positioned.fill(
//                               child: CustomPaint(
//                                 painter: DiagonalStrikeThroughPainter(
//                                   color:
//                                       isRed == true ? Colors.red : Colors.black,
//                                   strokeWidth: 2,
//                                   horizontalPadding: 0,
//                                   verticalPadding: 0,
//                                 ),
//                               ),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),
//                 // now
//                 Container(
//                   width: 56.5,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(
//                         color: isRed == true ? Colors.red : Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "AED",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontFamily: 'Myriad Pro',
//                           fontWeight: FontWeight.w900,
//                           height: 0.8,
//                         ),
//                       ),
//                       Text(
//                         promo.newPrice.toStringAsFixed(2),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'Myriad Pro',
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // precentage space
//           Container(
//             height: 35,
//             decoration: const BoxDecoration(color: Colors.transparent),
//             child: Row(
//               children: [
//                 // empty container
//                 Container(
//                   width: 113.60,
//                   decoration: BoxDecoration(
//                     // color: Colors.green,
//                     border: Border(
//                       right: BorderSide(
//                         color: isRed == true ? Colors.red : Colors.black,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // percentage
//                 Container(
//                   width: 113.4,
//                   alignment: Alignment.center,
//                   child: Text(
//                     "${promo.percentage}% OFF",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'Myriad Pro',
//                       fontWeight: FontWeight.w900,
//                       decorationColor: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // text
//           Container(
//             height: 15,
//             decoration: BoxDecoration(
//               // color: Colors.amber,
//               border: Border(
//                 top: BorderSide(
//                   color: isRed == true ? Colors.red : Colors.black,
//                   width: 1,
//                 ),
//               ),
//             ),
//             padding: const EdgeInsets.only(right: 10, top: 5, left: 10),
//             child: Obx(() => Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       con.optionalTextController.value.text,
//                       style: TextStyle(
//                         fontSize: 8,
//                         fontFamily: 'Myriad Pro',
//                         color: isRed == true ? Colors.red : Colors.black,
//                       ),
//                     ),
//                     Text(
//                       con.vatTextController.value.text,
//                       style: TextStyle(
//                         fontSize: 8,
//                         fontFamily: 'Myriad Pro',
//                         color: isRed == true ? Colors.red : Colors.black,
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TextFormFieldWidget2 extends StatelessWidget {
//   final String title;
//   final bool enforced;
//   final int? maxLength;
//   final String? Function(String?)? validator;
//   final void Function(String?)? onSaved;
//   final void Function(String)? onChanged;
//   final TextInputFormatter? formatter;
//   final TextEditingController? controller;
//   final bool? enabled;
//   final bool readOnly;

//   const TextFormFieldWidget2({
//     super.key,
//     required this.title,
//     this.enforced = false,
//     this.validator,
//     this.onSaved,
//     this.onChanged,
//     this.formatter,
//     this.controller,
//     this.enabled = true,
//     this.readOnly = false,
//     this.maxLength,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       style: const TextStyle(
//         color: Colors.black,
//         fontFamily: 'Myriad Pro',
//         fontSize: 10,
//       ),
//       keyboardType: TextInputType.number,
//       inputFormatters: [
//         formatter ?? FilteringTextInputFormatter.singleLineFormatter,
//         LengthLimitingTextInputFormatter(
//           maxLength ?? 7, // Set max length for the input
//           maxLengthEnforcement: enforced
//               ? MaxLengthEnforcement.enforced
//               : MaxLengthEnforcement.none,
//         ),
//       ],
//       validator: validator,
//       onSaved: onSaved,
//       onChanged: onChanged,
//       enabled: enabled,
//       readOnly: readOnly,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.only(
//           left: 10,
//           top: 2,
//           bottom: 2,
//         ),
//         border: const OutlineInputBorder(),
//         labelText: title,
//         labelStyle: const TextStyle(
//           color: Colors.black,
//           fontFamily: 'Myriad Pro',
//           fontSize: 10,
//         ),
//         fillColor: Colors.white,
//         filled: true,
//       ),
//     );
//   }
// }
