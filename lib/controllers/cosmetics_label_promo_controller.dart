import 'dart:developer';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:price_label_web/controllers/settings_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'dart:html' as html;

import '../models/cosmetics_label_promo.dart';

class PriceLabelPromoController extends GetxController {
  var settingsCon = Get.find<SettingsController>();
  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  List<GlobalKey> repaintKeys = [];
  final TextEditingController fileNameController = TextEditingController();
  var percentageController = TextEditingController().obs;
  var vatTextController =
      TextEditingController(text: '* All prices are inclusive of VAT').obs;
  var optionalTextController = TextEditingController().obs;
  final RxList<Map<String, TextEditingController>> controllers =
      <Map<String, TextEditingController>>[].obs;
  var data = <CosmeticsLabelPromo>[].obs;
  var isRedColor = true.obs;
  // var vatText = "* All prices are inclusive of VAT".obs;
  // var optionalText = "".obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var editIndex = -1.obs; // Stores the index of the item being edited

  final RxBool isEnabled = false.obs; // To track whether fields are enabled
  final RxBool isEnabledPerc = true.obs; // To track whether fields are enabled
  var selectedRadio = 1.obs;

  final RxDouble progress = 0.0.obs; // Progress (0.0 to 1.0)
  final RxString progressMessage = "".obs; // Progress message
  final RxBool isProcessing = false.obs; // To track processing state

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers for 4 rows
    for (int i = 0; i < 4; i++) {
      controllers.add({
        "description": TextEditingController(),
        "wasPrice": TextEditingController(),
        "nowPrice": TextEditingController(),
      });
    }
    percentageController.value.addListener(() {
      // Check if any of the row controllers have a value
      bool hasValue = controllers.any((controllerMap) {
        return controllerMap.values
            .any((controller) => controller.text.isNotEmpty);
      });

      // Set isEnabledPerc based on the presence of values in row controllers
      isEnabledPerc.value = !hasValue;

      // Block percentageController from being updated if rows have values
      if (hasValue && percentageController.value.text.isNotEmpty) {
        Get.snackbar("Action Blocked",
            "Cannot change percentage while rows have values.");
      }

      // Enable or disable other fields based on percentageController text
      isEnabled.value = percentageController.value.text.isNotEmpty;
    });
    vatTextController.value.addListener(() {
      update();
    });
    optionalTextController.value.addListener(() {
      update();
    });
    if (settingsCon.isDemoOn.value) {
      generatePriceLabelPromoData();
    }
  }

  void generatePriceLabelPromoData() {
    final math.Random random = math.Random();

    // Generate random CosmeticsLabelPromo list
    data.value = List<CosmeticsLabelPromo>.generate(
      math.Random().nextInt(
              11) + // Random number of CosmeticsLabelPromo objects (20-30)
          15, // Random number of CosmeticsLabelPromo objects (20-30)
      (index) {
        final percentage =
            [25, 30, 50][random.nextInt(3)]; // Random percentage (25, 30, 50)

        return CosmeticsLabelPromo(
          percentage: percentage,
          items: List<PromoItem>.generate(
            random.nextInt(4) + 1, // Random number of PromoItem objects (1-4)
            (itemIndex) {
              final oldPrice = random.nextDouble() * (999 - 50) +
                  50; // Random oldPrice (50-999)
              final discount = (oldPrice * percentage / 100);
              final newPrice = oldPrice - discount;

              return PromoItem(
                name:
                    "Miraya Musky Note Edp oriental ${index + 1}Ml (Unisex) - ${itemIndex + 1}",
                oldPrice: oldPrice,
                newPrice: newPrice,
              );
            },
          ),
        );
      },
    ).obs;
    update();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var controllerMap in controllers) {
      controllerMap["description"]?.dispose();
      controllerMap["wasPrice"]?.dispose();
      controllerMap["nowPrice"]?.dispose();
    }
    percentageController.value.dispose();
    super.dispose();
  }

  /// Clears a specific row at the given index
  void clearRow(int index) {
    if (index < 0 || index >= controllers.length) return; // Safety check
    controllers[index]["description"]?.clear();
    controllers[index]["wasPrice"]?.clear();
    controllers[index]["nowPrice"]?.clear();
    // Check if any row still has values after clearing
    bool hasValue = controllers.any((controllerMap) {
      return controllerMap.values
          .any((controller) => controller.text.isNotEmpty);
    });

    isEnabledPerc.value = !hasValue; // Update isEnabledPerc
    debugPrint("Cleared row $index");
  }

  /// Clears all rows
  void clearAllRows() {
    percentageController.value.clear();
    for (var controllerMap in controllers) {
      controllerMap["description"]?.clear();
      controllerMap["wasPrice"]?.clear();
      controllerMap["nowPrice"]?.clear();
    }
    isEnabledPerc.value = true; // All rows are now empty
    debugPrint("Cleared all rows");
    isEditMode.value = false;
  }

  void saveOrUpdatePriceLabelPromo() {
    // Parse percentage
    final percentage = double.tryParse(percentageController.value.text) ?? 0.0;

    // Collect PromoItems from controllers
    List<PromoItem> promoItems = [];
    for (int i = 0; i < controllers.length; i++) {
      final description = controllers[i]["description"]?.text ?? "";
      final wasPrice =
          double.tryParse(controllers[i]["wasPrice"]?.text ?? "") ?? 0.0;
      final nowPrice =
          double.tryParse(controllers[i]["nowPrice"]?.text ?? "") ?? 0.0;

      // Only add items with a description
      if (description.isNotEmpty) {
        promoItems.add(PromoItem(
          name: description,
          oldPrice: wasPrice,
          newPrice: nowPrice,
        ));
      }
    }

    // Update or Create
    if (isEditMode.value) {
      // Update existing CosmeticsLabelPromo
      final index = currentEditIndex.value;
      if (index >= 0 && index < data.length) {
        data[index] = CosmeticsLabelPromo(
          percentage: percentage.toInt(),
          items: promoItems,
        );
      }
    } else {
      // Create new CosmeticsLabelPromo
      data.add(CosmeticsLabelPromo(
        percentage: percentage.toInt(),
        items: promoItems,
      ));
    }

    // Reset the edit mode
    isEditMode.value = false;
    currentEditIndex.value = -1;
    update();

    // Clear controllers after saving
    clearAllRows();
  }

  void clearAllData() {
    data.clear();
    update();
  }

  void editPriceLabelPromo(int index) {
    // Set the mode to edit
    isEditMode.value = true;
    currentEditIndex.value = index;

    // Get the CosmeticsLabelPromo to edit
    final promo = data[index];

    percentageController.value.text = promo.percentage.toString();

    // Populate the controllers with the promo data
    for (int i = 0; i < promo.items.length; i++) {
      controllers[i]["description"]?.text = promo.items[i].name;
      controllers[i]["wasPrice"]?.text = promo.items[i].oldPrice.toString();
      controllers[i]["nowPrice"]?.text = promo.items[i].newPrice.toString();
    }

    // Clear remaining controllers if any
    for (int i = promo.items.length; i < controllers.length; i++) {
      controllers[i]["description"]?.clear();
      controllers[i]["wasPrice"]?.clear();
      controllers[i]["nowPrice"]?.clear();
    }
    update();
  }

  void removeDataByIndex(int index) {
    data.removeAt(index);
    update();
  }

  void onWasPriceChanged(int index, String value) {
    // Parse the percentage value
    final percentage = double.tryParse(percentageController.value.text) ?? 0.0;

    // Parse the Was Price value
    final wasPrice = double.tryParse(value) ?? 0.0;

    // Calculate the Now Price
    final nowPrice = wasPrice - (wasPrice * percentage / 100);

    // Update the Now Price controller for the corresponding index
    controllers[index]["nowPrice"]?.text = nowPrice.toStringAsFixed(2);
  }

  // Update repaint keys based on total pages
  void updateRepaintKeys() {
    int totalPagesCount =
        (data.length / 10).ceil(); // Assuming 10 items per page
    repaintKeys = List.generate(totalPagesCount, (index) => GlobalKey());
    update();
  }

  void showProgressDialog(String message) {
    progressMessage.value = message;
    progress.value = 0.0;
    isProcessing.value = true;
    Get.dialog(
      PopScope(
        canPop: false, // Prevent closing dialog
        child: Obx(
          () {
            return AlertDialog(
              title: const Text("Processing..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress.value),
                  const SizedBox(height: 16),
                  Text(progressMessage.value),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideProgressDialog() {
    if (Get.isDialogOpen == true) {
      Get.back(); // Close dialog
    }
    isProcessing.value = false;
  }

  // Update progress value
  void updateProgress(double value, String message) {
    progress.value = value;
    progressMessage.value = message;
  }

  /////////

  Future<void> _downloadPdfWeb(Uint8List pdfBytes) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileNameController.text.isEmpty
            ? 'DPH_Perfumes_Label(${isRedColor.value ? 'Red' : 'Black&White'})_Promotional.pdf'
            : "${fileNameController.text}_(${isRedColor.value ? 'Red' : 'Black&White'}).pdf"
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  void downloadPDF({required bool isDownload}) async {
    showProgressDialog("Starting PDF generation...");

    // Handle download or print
    final pdfBytes = await generatePdfDocument(
      items: data,
      vatText: vatTextController.value.text,
      optText: optionalTextController.value.text,
      isRed: isRedColor.value,
      itemsPerPage: 8,
    );
    if (isDownload) {
      // updateProgress(1.0, "Downloading PDF...");
      await _downloadPdfWeb(pdfBytes);

      // updateProgress(1.0, "Download complete");
    } else {
      // updateProgress(1.0, "Opening PDF preview...");
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        format: PdfPageFormat.a4,
        usePrinterSettings: true, // Use printer settings for better quality
      );
      // updateProgress(1.0, "PDF export completed");
    }
  }

  Future<Uint8List> generatePdfDocument({
    required List<CosmeticsLabelPromo> items,
    required String vatText,
    required String optText,
    required bool isRed,
    required int itemsPerPage,
  }) async {
    final ttf = await loadFont();
    final pdf = pw.Document();
    const itemsPerPage = 8; // 2 rows × 4 columns

    double containerHeight = 219.21;
    double containerWidth = 302.36;

    // Show initial progress
    try {
      // Split items into pages of 8
      for (var i = 0; i < items.length; i += itemsPerPage) {
        final pageIndex = (i ~/ itemsPerPage) + 1;
        final pageItems = items.sublist(i,
            i + itemsPerPage > items.length ? items.length : i + itemsPerPage);

        // Update progress
        updateProgress(i / items.length,
            "Generating page $pageIndex (${pageItems.length} items)");

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            orientation: pw.PageOrientation.portrait,
            build: (pw.Context context) {
              return pw.Container(
                width: 794,
                height: 1123,
                color: PdfColors.white,
                child: pw.GridView(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 21,
                  childAspectRatio: containerWidth / containerHeight,
                  children: [
                    for (final promo in pageItems)
                      pw.SizedBox(
                        height: containerHeight,
                        width: containerWidth,
                        child: _buildPriceLabel(
                          promo,
                          vatText,
                          optText,
                          isRed,
                          ttf,
                          containerHeight,
                          containerWidth,
                        ),
                      ),
                    // Add empty containers to fill remaining slots
                    for (int i = pageItems.length; i < 8; i++)
                      pw.SizedBox(
                        height: containerHeight,
                        width: containerWidth,
                        child: pw.Container(), // Empty placeholder
                      ),
                  ],
                ),
              );
            },
          ),
        );
      }

      // Final progress update

      updateProgress(1.0, "Finalizing PDF...");
      final pdfBytes = await pdf.save();
      return pdfBytes;
    } catch (e) {
      updateProgress(1.0, "Error: ${e.toString()}");
      rethrow;
    } finally {
      hideProgressDialog();
    }
  }

  pw.Widget _buildPriceLabel(
      CosmeticsLabelPromo promo,
      String vatText,
      String optText,
      bool isRed,
      pw.Font ttf,
      double totalHeight,
      double totalWidth) {
    final borderColor = isRed ? PdfColors.red : PdfColors.black;
    final textColor = isRed ? PdfColors.red : PdfColors.black;
    double totalHeight = 130;
    return pw.SizedBox(
      height: totalHeight,
      width: totalWidth,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 2),
        ),
        child: pw.Column(
          children: [
            // Header Row
            pw.Container(
              height: 20,
              width: totalWidth,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: borderColor, width: 2)),
              ),
              child: pw.Row(
                children: [
                  _buildHeaderCell(
                    "Description".toUpperCase(),
                    118,
                    borderColor,
                    ttf,
                    fontSize: 10,
                  ),
                  _buildHeaderCell(
                    "WAS",
                    38,
                    borderColor,
                    ttf,
                    fontSize: 10,
                  ),
                  _buildHeaderCell(
                    "Disc.%".toUpperCase(),
                    38,
                    borderColor,
                    ttf,
                    fontSize: 10,
                  ),
                  _buildHeaderCell(
                    "NOW",
                    38,
                    borderColor,
                    ttf,
                    borderRight: false,
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            // Content Section
            pw.Expanded(
              child: pw.SizedBox(
                height: totalHeight,
                child: pw.Row(
                  children: [
                    // Item Column
                    _buildItemColumn(
                      promo.items.map((item) => item.name).toList(),
                      118,
                      borderColor,
                      ttf,
                      totalHeight,
                    ),
                    // Was Price Column
                    if (selectedRadio.value == 1)
                      _buildPriceColumn2(
                        promo.items.map((item) => item.oldPrice).toList(),
                        38,
                        borderColor,
                        ttf,
                        totalHeight,
                        isStrike: true,
                      ),
                    if (selectedRadio.value == 2)
                      _buildPriceColumn(
                        promo.items.map((item) => item.oldPrice).toList(),
                        38,
                        borderColor,
                        ttf,
                        totalHeight,
                        isStrike: true,
                      ),
                    // Discount Column
                    _buildDiscountCell(
                      promo.percentage.toDouble(),
                      38,
                      borderColor,
                      ttf,
                      totalHeight,
                    ),
                    // Now Price Column
                    _buildPriceColumn(
                        promo.items.map((item) => item.newPrice).toList(),
                        34,
                        borderColor,
                        ttf,
                        totalHeight,
                        borderRight: false),
                  ],
                ),
              ),
            ),

            // Footer
            pw.Container(
              height: 15,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: borderColor, width: 1),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(optText,
                      style: pw.TextStyle(
                          font: ttf, fontSize: 8, color: textColor)),
                  pw.Text(vatText,
                      style: pw.TextStyle(
                          font: ttf, fontSize: 8, color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildHeaderCell(
      String text, double width, PdfColor borderColor, pw.Font ttf,
      {double? fontSize, bool borderRight = true}) {
    return pw.Container(
      width: width,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: borderRight
              ? pw.BorderSide(
                  color: borderColor,
                  width: 1,
                )
              : pw.BorderSide.none,
        ),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(text,
          style: pw.TextStyle(font: ttf, fontSize: fontSize ?? 12)),
    );
  }

  pw.Widget _buildItemColumn(List<String> items, double width,
      PdfColor borderColor, pw.Font ttf, double totalHeight) {
    final itemCount = items.length.clamp(1, 4); // Ensure 1-4 items
    final itemHeight = totalHeight / itemCount;

    return pw.Container(
      width: width,
      height: totalHeight, // Fixed total height
      decoration: pw.BoxDecoration(
        border: pw.Border(right: pw.BorderSide(color: borderColor, width: 1)),
      ),
      child: pw.Column(
        children: [
          for (int index = 0; index < items.length; index++)
            pw.Container(
              height: itemHeight,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: index < items.length - 1
                      ? pw.BorderSide(color: borderColor, width: 1)
                      : pw.BorderSide.none,
                ),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                items[index],
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildPriceColumn(
    List<double> prices,
    double width,
    PdfColor borderColor,
    pw.Font ttf,
    double totalHeight, {
    bool isStrike = false,
    bool borderRight = true,
  }) {
    final itemCount = prices.length.clamp(1, 4);
    final itemHeight = totalHeight / itemCount;

    return pw.Container(
      width: width,
      height: totalHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: borderRight
              ? pw.BorderSide(
                  color: borderColor,
                  width: 1,
                )
              : pw.BorderSide.none,
        ),
      ),
      child: pw.Column(
        children: [
          for (int index = 0; index < prices.length; index++)
            pw.Container(
              height: itemHeight,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: index < prices.length - 1
                      ? pw.BorderSide(color: borderColor, width: 1)
                      : pw.BorderSide.none,
                ),
              ),
              alignment: pw.Alignment.center,
              child: pw.Stack(
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "AED",
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          height: 0.8,
                        ),
                      ),
                      pw.Text(
                        prices[index].toStringAsFixed(2),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (isStrike)
                    pw.Positioned(
                      left: 0,
                      right: 0,
                      top: 3.5,
                      child: pw.Container(
                        height: 1.2,
                        color:
                            isRedColor.value ? PdfColors.red : PdfColors.black,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildPriceColumn2(
    List<double> prices,
    double width,
    PdfColor borderColor,
    pw.Font ttf,
    double totalHeight, {
    bool isStrike = false,
    double? borderWidth,
  }) {
    final itemCount = prices.length.clamp(1, 4);
    final itemHeight = totalHeight / itemCount;

    return pw.Container(
      width: width,
      height: totalHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(
            color: borderWidth == 0 ? PdfColors.white : borderColor,
            width: borderWidth ?? 1,
          ),
        ),
      ),
      child: pw.Column(
        children: [
          for (int index = 0; index < prices.length; index++)
            pw.Container(
              height: itemHeight,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: index < prices.length - 1
                      ? pw.BorderSide(color: borderColor, width: 1)
                      : pw.BorderSide.none,
                ),
              ),
              alignment: pw.Alignment.center,
              child: pw.Stack(
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "AED",
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          height: 0.8,
                        ),
                      ),
                      pw.Text(
                        prices[index].toStringAsFixed(2),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  if (isStrike)
                    pw.Positioned.fill(
                      child: pw.Transform.rotate(
                        angle: 0.6,
                        child: pw.Container(
                          alignment: pw.Alignment.center,
                          child: pw.Container(
                            width: 250,
                            height: 1.2,
                            color: isRedColor.value
                                ? PdfColors.red
                                : PdfColors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildDiscountCell(double percentage, double width,
      PdfColor borderColor, pw.Font ttf, double totalHeight) {
    return pw.Container(
      width: width,
      height: totalHeight, // Match total height
      decoration: pw.BoxDecoration(
        border: pw.Border(right: pw.BorderSide(color: borderColor, width: 1)),
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              "${percentage.toStringAsFixed(0)}%",
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "OFF",
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/MyriadPro-Bold.ttf');
    return pw.Font.ttf(fontData.buffer.asByteData());
  }

  void downloadTemplate() async {
    String path = 'assets/samples/example_DPH & Cosmetics Label Promotion.xlsx';
    ByteData data = await rootBundle.load(path);
    var fileBytes = data.buffer.asUint8List();
    await downloadPreforma(
        fileBytes, "Accessory Label Promotion Preforma.xlsx");
  }

  Future<void> downloadPreforma(Uint8List pdfBytes, String name) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = name
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  void pickExcelFile(BuildContext context) async {
    var width = context.width;
    var result = await parseExcelToLabelPromo();
    log(result.toString());

    if (result.code != 200) {
      log("No Data found");
      Get.snackbar(
        "Error!!",
        result.msg ?? "Something went wrong, try again",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    log("Data found");
    var validData = result.validPromos;
    var invalidData = result.invalidPromos;

    String title = "Excel Parsing Summary";
    Widget content;
    List<Widget> actions = [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    ];

    if (validData.isEmpty && invalidData.isEmpty) {
      content = _buildMessage(
          "No valid or invalid batches were extracted from the Excel file. Please check the Excel sheet again.");
    } else if (validData.isNotEmpty && invalidData.isEmpty) {
      content = _buildMessage(
          "${validData.length} valid batches were successfully extracted from the Excel file.");
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (validData.isNotEmpty)
            _buildMessage(
                "${validData.length} valid batches were successfully extracted from the Excel file."),
          if (invalidData.isNotEmpty) ...[
            _buildMessage(
                "However, we found ${invalidData.length} invalid batches with errors. Below are the invalid batches that require attention:"),
            const SizedBox(height: 10),
            _buildInvalidTable(invalidData),
          ],
        ],
      );
    }

    if (validData.isNotEmpty) {
      actions.insert(
        1,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.white),
          onPressed: () {
            Get.back();
            data.addAll(validData);
            update();
          },
          child: const Text("Continue"),
        ),
      );
    }

    _showDialog(width, title, content, actions);
  }

  void _showDialog(
      double width, String title, Widget content, List<Widget> actions) {
    Get.dialog(
      AlertDialog(
        title: Center(child: Text(title)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                500, // Ensures the dialog is scrollable if content overflows
            maxWidth: width * 0.9, // Prevents overflow beyond screen width
          ),
          child: content,
        ),
        actions: actions,
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInvalidTable(List<CosmeticsLabelInvalidPromo> invalidData) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxHeight: 300), // Ensures proper scrolling
      child: SingleChildScrollView(
        child: Column(
          children: [
            _rowWidget(
              rowValues: {
                40.0: "Row", // Small width for Row number
                200.0: "Description", // Wider column for description
                80.0: "Was Price",
                81.0: "Discount",
                170.0: "Errors",
              },
              isHead: true,
            ),
            ...List.generate(invalidData.length, (batchIndex) {
              var batch = invalidData[batchIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Batch with ${batch.percentage}% Discount",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ...List.generate(batch.items.length, (index) {
                    var item = batch.items[index];
                    return _rowWidget(
                      rowValues: {
                        40: item.row.toString(),
                        200: item.name,
                        80: item.wasPrice,
                        81: item.discount,
                        170: item.errors
                            .join(", "), // Show all errors in one column
                      },
                    );
                  }),
                  const Divider(), // Separate batches visually
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _rowWidget({
    required Map<double, String> rowValues, // Each item has a custom width
    bool isHead = false,
  }) {
    var fontWeight = isHead ? FontWeight.bold : FontWeight.normal;
    double fontSize = isHead ? 16 : 12;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: rowValues.entries.map((entry) {
          return Container(
            width: entry.key, // Custom width from the map key
            alignment: Alignment.center,
            child: Text(
              entry.value, // Text from the map value
              style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<ExcelParseResultCosmeticPromo> parseExcelToLabelPromo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        return ExcelParseResultCosmeticPromo(
            code: 400, validPromos: [], invalidPromos: []);
      }

      final Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) {
        return ExcelParseResultCosmeticPromo(
            code: 400, validPromos: [], invalidPromos: []);
      }

      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return ExcelParseResultCosmeticPromo(
            code: 400, validPromos: [], invalidPromos: []);
      }

      final sheet = excel.tables.values.first;
      final List<CosmeticsLabelPromo> validPromos = [];
      final List<CosmeticsLabelInvalidPromo> invalidPromos = [];

      int rowIndex = 2; // Start after headers
      List<PromoItem> currentBatchItems = [];
      List<InvalidCosmeticPromoItem> batchErrors = [];
      double? currentBatchPercentage;
      bool hasBatchError = false;
      int consecutiveEmptyRows = 0;

      for (var row in sheet.rows.skip(2)) {
        rowIndex++;
        final rowValues = row.map((cell) => _getString(cell)).toList();

        // Check for 'end' keyword or empty row in any column
        if (rowValues.any((cell) => cell.toLowerCase() == 'end') ||
            rowValues.every((cell) => cell.isEmpty)) {
          _finalizeBatch(
            currentBatchItems,
            currentBatchPercentage,
            validPromos,
            batchErrors,
            invalidPromos,
            hasBatchError,
          );
          currentBatchItems = [];
          currentBatchPercentage = null;
          hasBatchError = false;
          batchErrors = [];

          consecutiveEmptyRows++;
          if (consecutiveEmptyRows >= 5) {
            log("Stopping: More than 5 consecutive empty rows detected.");
            break;
          }
          continue;
        } else {
          consecutiveEmptyRows =
              0; // Reset empty row counter if valid row found
        }

        // Extract and validate row data
        final description = rowValues[0];
        final wasPriceStr = rowValues[1];
        final discountStr = rowValues[2];

        final wasPrice = double.tryParse(wasPriceStr);
        final discount = double.tryParse(discountStr);
        final errors = <String>[];

        if (description.isEmpty) errors.add("Missing product name");
        if (wasPrice == null) errors.add("Invalid Was Price");
        if (discount == null) errors.add("Invalid discount percentage");

        // Check batch discount consistency
        if (currentBatchPercentage != null &&
            discount != currentBatchPercentage) {
          errors.add("Discount differs from batch percentage");
        }

        if (errors.isNotEmpty) {
          batchErrors.add(InvalidCosmeticPromoItem(
            row: rowIndex,
            name: description,
            wasPrice: wasPriceStr,
            discount: discountStr,
            errors: errors,
          ));
          hasBatchError = true;
          continue;
        }

        // Set batch percentage if first valid row
        currentBatchPercentage ??= discount;

        currentBatchItems.add(PromoItem(
          name: description,
          oldPrice: wasPrice!,
          newPrice: wasPrice * (1 - discount! / 100),
        ));

        // Handle batch splitting if more than 4 items
        if (currentBatchItems.length == 4) {
          _finalizeBatch(
            currentBatchItems,
            currentBatchPercentage,
            validPromos,
            batchErrors,
            invalidPromos,
            hasBatchError,
          );
          currentBatchItems = [];
          currentBatchPercentage = null;
          hasBatchError = false;
          batchErrors = [];
        }
      }

      // Process remaining batch items if we haven't hit 5 empty rows
      if (consecutiveEmptyRows < 5 &&
          (currentBatchItems.isNotEmpty || batchErrors.isNotEmpty)) {
        _finalizeBatch(
          currentBatchItems,
          currentBatchPercentage,
          validPromos,
          batchErrors,
          invalidPromos,
          hasBatchError,
        );
      }

      return ExcelParseResultCosmeticPromo(
          code: 200, validPromos: validPromos, invalidPromos: invalidPromos);
    } catch (e) {
      log("Error parsing label promo: $e");
      return ExcelParseResultCosmeticPromo(
          code: 400, validPromos: [], invalidPromos: []);
    }
  }

  void _finalizeBatch(
    List<PromoItem> items,
    double? percentage,
    List<CosmeticsLabelPromo> validPromos,
    List<InvalidCosmeticPromoItem> batchErrors,
    List<CosmeticsLabelInvalidPromo> invalidPromos,
    bool hasError,
  ) {
    if (hasError || batchErrors.isNotEmpty) {
      invalidPromos.add(CosmeticsLabelInvalidPromo(
          percentage: percentage?.round() ?? 0, items: batchErrors));
      return;
    }

    // If we hit 5 empty rows, do not add the batch
    if (items.isEmpty || items.length > 4) return;

    validPromos.add(
        CosmeticsLabelPromo(percentage: percentage!.round(), items: items));
  }

  String _getString(Data? cell) => cell?.value?.toString().trim() ?? '';
}
