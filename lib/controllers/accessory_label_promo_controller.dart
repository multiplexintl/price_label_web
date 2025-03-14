import 'dart:developer';
import 'dart:math' as math;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:price_label_web/controllers/settings_controller.dart';
import 'package:price_label_web/models/accessory_promo.dart';
import 'package:printing/printing.dart';

import 'dart:html' as html;

class AccessoryLabelPromoController extends GetxController {
  var settingCon = Get.find<SettingsController>();
  final TextEditingController fileNameController = TextEditingController();
  final brandNameController = TextEditingController().obs;
  final barcodeController = TextEditingController().obs;
  final percentageController = TextEditingController().obs;
  final oldPriceController = TextEditingController().obs;
  final newPriceController = TextEditingController().obs;
  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  var data = <AccessoryPromo>[].obs;
  var isRedColor = true.obs;
  final vatTextController =
      TextEditingController(text: '* All prices are inclusive of VAT').obs;
  final optionalTextController = TextEditingController().obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var editIndex = -1.obs; // Stores the index of the item being edited

  final transformationController = TransformationController(); // For zoom/pan
  var pickedColor = (Colors.red as Color).obs;

  late pw.Font regularFont; // Font for regular text
  late pw.Font boldFont; // Font for bold text
  var selectedRadio = 1.obs;

  final RxDouble progress = 0.0.obs; // Progress (0.0 to 1.0)
  final RxString progressMessage = "".obs; // Progress message
  final RxBool isProcessing = false.obs; // To track processing state
  final RxBool isEnabled = false.obs; // To track whether fields are enabled
  final RxBool isEnabledPerc = true.obs; // To track whether fields are enabled

  @override
  void onInit() {
    percentageController.value.addListener(() {
      // Check if any of the row controllers have a value
      var controllers = [
        brandNameController,
        barcodeController,
        oldPriceController,
        newPriceController,
      ];
      bool hasValue = controllers.any((controller) {
        return controller.value.text.isNotEmpty;
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
    if (settingCon.isDemoOn.value) {
      generateAccessoryPromoData();
    }
    super.onInit();
  }

  void generateAccessoryPromoData() {
    final math.Random random = math.Random();

    // Generate random AccessoryPromo list
    data.value = List<AccessoryPromo>.generate(
      random.nextInt(11) +
          20, // Random number of AccessoryPromo objects (20-30)
      (index) {
        // Generate a random 13-digit barcode
        final barcode = List.generate(13, (_) => random.nextInt(10))
            .join(); // Generate a string of 13 random digits

        // Generate a random oldPrice between 50 and 999
        final oldPrice = random.nextDouble() * (999 - 50) + 50;

        // Select a random discount percentage (25%, 30%, 50%)
        final discountPercentage = [25, 30, 50][random.nextInt(3)];
        final newPrice = oldPrice - (oldPrice * discountPercentage / 100);

        return AccessoryPromo(
          brandName: "eylure", // Constant brand name
          barcode: barcode,
          oldPrice: oldPrice,
          newPrice: newPrice,
          percentage: discountPercentage.toDouble(),
        );
      },
    );
    update();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    super.dispose();
  }

  /// Clears a specific row at the given index
  void clearAllData() async {
    data.clear();
    update();
  }

  /// Clears all rows
  void clearAllRows() {
    brandNameController.value.clear();
    barcodeController.value.clear();
    oldPriceController.value.clear();
    newPriceController.value.clear();
    debugPrint("Cleared all rows");
    isEditMode.value = false;
    update();
  }

  void saveOrUpdatePriceLabelPromo() {
    // Collect data from controllers
    final brandName = brandNameController.value.text.trim();
    final barcode = barcodeController.value.text.trim();
    final oldPrice =
        double.tryParse(oldPriceController.value.text.trim()) ?? 0.0;
    final newPrice =
        double.tryParse(newPriceController.value.text.trim()) ?? 0.0;
    final percentage =
        double.tryParse(percentageController.value.text.trim()) ?? 0.0;

    // Validate required fields
    if (brandName.isEmpty) {
      log("Error: Brand Name is required.");
      return;
    }

    // Update or Create
    if (isEditMode.value) {
      // Update existing AccessoryPromo
      final index = currentEditIndex.value;
      if (index >= 0 && index < data.length) {
        data[index] = AccessoryPromo(
          brandName: brandName,
          barcode: barcode,
          oldPrice: oldPrice,
          newPrice: newPrice,
          percentage: percentage,
        );
        log("Updated AccessoryPromo at index $index: ${data[index]}");
      } else {
        log("Error: Invalid index for update.");
      }
    } else {
      // Create new AccessoryPromo
      final newPromo = AccessoryPromo(
        brandName: brandName,
        barcode: barcode,
        oldPrice: oldPrice,
        newPrice: newPrice,
        percentage: percentage,
      );
      data.add(newPromo);
      log("Added new AccessoryPromo: $newPromo");
    }

    // Reset the edit mode
    isEditMode.value = false;
    currentEditIndex.value = -1;
    update();

    // Clear controllers after saving
    clearAllRows();
  }

  void editPriceLabelPromo(int index) {
    // Set the mode to edit
    isEditMode.value = true;
    currentEditIndex.value = index;

    // Get the AccessoryPromo to edit
    final promo = data[index];

    // Populate the controllers with the promo data
    brandNameController.value.text = promo.brandName;
    barcodeController.value.text = promo.barcode;
    oldPriceController.value.text = promo.oldPrice.toStringAsFixed(2);
    newPriceController.value.text = promo.newPrice.toStringAsFixed(2);

    log("Editing AccessoryPromo at index $index: $promo");

    // Trigger UI updates
    update();
  }

  void onWasPriceChanged(String value) {
    // Parse the percentage value
    final percentage = double.tryParse(percentageController.value.text) ?? 0.0;

    // Parse the Was Price value
    final wasPrice = double.tryParse(value) ?? 0.0;

    // Calculate the Now Price
    final nowPrice = wasPrice - (wasPrice * percentage / 100);

    // Update the Now Price controller for the corresponding index
    newPriceController.value.text = nowPrice.toStringAsFixed(2);
  }

  void copyPriceLabelPromo(int index) {
    if (index >= 0 && index < data.length) {
      // Retrieve the original promo
      final originalPromo = data[index];

      // Create a new copy with the same values
      final copiedPromo = AccessoryPromo(
        brandName: originalPromo.brandName,
        barcode: originalPromo.barcode,
        oldPrice: originalPromo.oldPrice,
        newPrice: originalPromo.newPrice,
        percentage: originalPromo.percentage,
      );

      // Insert the copy right after the original item
      data.insert(index + 1, copiedPromo);

      log("Copied AccessoryPromo from index $index to index ${index + 1}: $copiedPromo");

      // Trigger UI updates
      update();
    } else {
      log("Error: Invalid index $index for copying.");
    }
  }

  void removeDataByIndex(int index) {
    data.removeAt(index);
    update();
  }

  void downloadPDF({required bool isDownload}) async {
    // showProgressDialog("Starting PDF generation...");

    // Handle download or log
    final pdfBytes = await generateAccessoriesPromoPdf(
      items: data,
      vatText: vatTextController.value.text,
      optText: optionalTextController.value.text,
      isRed: isRedColor.value,
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

  Future<void> _downloadPdfWeb(Uint8List pdfBytes) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileNameController.text.isEmpty
            ? 'Accessory_Label(${isRedColor.value ? 'Red' : 'Black&White'})_Promotion.pdf'
            : "${fileNameController.text}_(${isRedColor.value ? 'Red' : 'Black&White'}).pdf"
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  // Show progress dialog
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

  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/MyriadPro-Bold.ttf');
    return pw.Font.ttf(fontData.buffer.asByteData());
  }

  // PDF Generation Function
  Future<Uint8List> generateAccessoriesPromoPdf({
    required List<AccessoryPromo> items,
    required String vatText,
    required String optText,
    required bool isRed,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    const itemsPerPage = 18;
    double totalWidth = 290;
    double totalHeight = 190;

    for (int i = 0; i < items.length; i += itemsPerPage) {
      final pageItems =
          items.sublist(i, (i + itemsPerPage).clamp(0, items.length));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(15),
          orientation: pw.PageOrientation.portrait,
          build: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(),
            width: 794,
            height: 1123,
            color: PdfColors.white,
            child: pw.GridView(
              crossAxisCount: 3,
              crossAxisSpacing: 22,
              mainAxisSpacing: 23,
              childAspectRatio: totalWidth / totalHeight,
              children: [
                for (final item in pageItems)
                  pw.SizedBox(
                    width: totalWidth,
                    height: totalHeight,
                    child: _buildPdfAccessoryPromoLabel(
                      item,
                      vatText,
                      optText,
                      isRed,
                      font,
                      totalWidth,
                      totalHeight,
                    ),
                  ),
                // Add empty containers to fill remaining slots
                for (int i = pageItems.length; i < 18; i++)
                  pw.SizedBox(
                    height: totalHeight,
                    width: totalWidth,
                    child: pw.Container(), // Empty placeholder
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }

// PDF Widget Builder
  pw.Widget _buildPdfAccessoryPromoLabel(
    AccessoryPromo promo,
    String vatText,
    String optText,
    bool isRed,
    pw.Font font,
    double totalWidth,
    double totalHeight,
  ) {
    final borderColor = isRed ? PdfColors.red : PdfColors.black;
    final textColor = isRed ? PdfColors.red : PdfColors.black;

    return pw.Container(
      width: totalWidth,
      height: totalHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 2),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: totalWidth,
            height: 20,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: borderColor, width: 2)),
            ),
            child: pw.Row(
              children: [
                _buildPdfHeaderCell(
                  "ITEM",
                  98,
                  borderColor,
                  font,
                ),
                _buildPdfHeaderCell(
                  "WAS",
                  38,
                  borderColor,
                  font,
                ),
                _buildPdfHeaderCell(
                  "NOW",
                  38,
                  borderColor,
                  font,
                  isBorder: false,
                ),
              ],
            ),
          ),
          // Price Section
          pw.Container(
            height: 56,
            alignment: pw.Alignment.center,
            // color: PdfColors.amber,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _buildPdfBarcodeCell(promo, borderColor, font),
                if (selectedRadio.value == 2)
                  _buildPdfPrice(
                    price: promo.oldPrice.toStringAsFixed(2),
                    borderColor: borderColor,
                    font: font,
                    isStrikeThrough: true,
                  ),
                if (selectedRadio.value == 1)
                  _buildPdfPrice2(
                    price: promo.oldPrice.toStringAsFixed(2),
                    borderColor: borderColor,
                    font: font,
                    isStrikeThrough: true,
                  ),
                _buildPdfPrice(
                  price: promo.newPrice.toStringAsFixed(2),
                  borderColor: borderColor,
                  font: font,
                  isStrikeThrough: false,
                ),
              ],
            ),
          ),
          // Discount Section
          pw.Container(
            // color: PdfColors.red,
            height: 25,
            child: pw.Row(
              children: [
                pw.Container(
                  width: 98,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        right: pw.BorderSide(color: borderColor, width: 1)),
                  ),
                ),
                pw.Container(
                  width: 76,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "${promo.percentage}% OFF",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          pw.Container(
            height: 15,
            decoration: pw.BoxDecoration(
              border:
                  pw.Border(top: pw.BorderSide(color: borderColor, width: 1)),
            ),
            padding: const pw.EdgeInsets.only(right: 10, left: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  optText,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 6,
                    color: textColor,
                  ),
                ),
                pw.Text(
                  vatText,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 6,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfHeaderCell(
    String text,
    double width,
    PdfColor borderColor,
    pw.Font font, {
    bool isBorder = true,
  }) {
    return pw.Container(
      width: width,
      decoration: pw.BoxDecoration(
        border: pw.Border(
            right: isBorder
                ? pw.BorderSide(color: borderColor, width: 1)
                : pw.BorderSide.none),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPdfBarcodeCell(
      AccessoryPromo promo, PdfColor borderColor, pw.Font font) {
    return pw.Container(
      width: 98,
      decoration: pw.BoxDecoration(
        border: pw.Border(right: pw.BorderSide(color: borderColor, width: 1)),
      ),
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            promo.brandName.toUpperCase(),
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            promo.barcode.toUpperCase(),
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfPrice(
      {required String price,
      required PdfColor borderColor,
      required pw.Font font,
      required bool isStrikeThrough}) {
    return pw.Container(
      width: 38,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(color: borderColor, width: 1),
          bottom: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            "AED",
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Stack(
            children: [
              pw.Text(
                price,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (isStrikeThrough)
                pw.Positioned(
                  left: 0,
                  right: 0,
                  top: 3.5,
                  child: pw.Container(
                    height: 1.2,
                    color: isRedColor.value ? PdfColors.red : PdfColors.black,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfPrice2({
    required String price,
    required PdfColor borderColor,
    required pw.Font font,
    required bool isStrikeThrough,
  }) {
    return pw.Container(
      width: 38,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(color: borderColor, width: 1),
          bottom: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      alignment: pw.Alignment.center,
      child: pw.Container(
        alignment: pw.Alignment.center,
        child: pw.Stack(
          children: [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "AED",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  price,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isStrikeThrough)
              pw.Positioned.fill(
                child: pw.Transform.rotate(
                  angle: 0.6,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Container(
                      width: 250,
                      height: 1.2,
                      color: isRedColor.value ? PdfColors.red : PdfColors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // from excel
  void pickExcelFile(BuildContext context) async {
    var width = context.width;
    var result = await parseExcelToAccessoryPromo();
    log(result.toString());

    if (result.code != 200) {
      log("No Data found");
      Get.snackbar(
        "Error!!",
        result.msg ?? "Something went wrong, try again",
        snackPosition: SnackPosition.TOP,
      );
      return;
    } else {
      log("Data found");
      var validData = result.validPromos;
      var invalidData = result.invalidRows;

      // Determine message & actions
      String title = "Excel Parsing Summary";
      Widget content;
      List<Widget> actions = [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
      ];

      if (validData.isEmpty && invalidData.isEmpty) {
        content = _buildMessage(
          "No valid or invalid rows were extracted from the Excel file. Please check the Excel sheet again.",
        );
        actions.insert(
          1,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              data.addAll(validData);
              update();
            },
            child: const Text("Continue"),
          ),
        );
      } else if (validData.isNotEmpty && invalidData.isEmpty) {
        content = _buildMessage(
          "${validData.length} valid rows were successfully extracted from the Excel file.",
        );
        actions.insert(
          1,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              data.addAll(validData);
              update();
            },
            child: const Text("Continue"),
          ),
        );
      } else if (validData.isEmpty && invalidData.isNotEmpty) {
        content = Column(
          children: [
            const Text(
                "No valid rows were successfully extracted from the Excel file."),
            Text(
                "We found ${invalidData.length} invalid rows with errors. Below are the invalid rows that require attention:"),
            const SizedBox(height: 20),
            _buildInvalidTable(invalidData),
          ],
        );
      } else {
        content = Column(
          children: [
            Text(
                "${validData.length} valid rows were successfully extracted from the Excel file."),
            Text(
                "However, we found ${invalidData.length} invalid rows with errors. Below are the invalid rows that require attention:"),
            const SizedBox(height: 20),
            _buildInvalidTable(invalidData),
          ],
        );
        actions.insert(
          1,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              data.addAll(validData);
              update();
            },
            child: const Text("Continue"),
          ),
        );
      }

      // Show dialog
      _showDialog(width, title, content, actions);
    }
  }

  void _showDialog(
      double width, String title, Widget content, List<Widget> actions) {
    Get.dialog(
      SizedBox(
        width: width,
        child: AlertDialog(
          title: Center(child: Text(title)),
          content: content,
          actions: actions,
          actionsAlignment: MainAxisAlignment.spaceAround,
        ),
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Text(message);
  }

  Widget _buildInvalidTable(List<InvalidPromo> invalidData) {
    return Column(
      children: [
        _rowWidget(
          row: "Row",
          brand: "Brand",
          barcode: "Barcode",
          oldPrice: "Price",
          discount: "Discount",
          error: "Error!",
          isHead: true,
        ),
        ...invalidData.map((data) => _rowWidget(
              row: data.row.toString(),
              brand: data.brand,
              barcode: data.barcode,
              discount: data.discount,
              oldPrice: data.oldPrice,
              error: data.error,
            ))
      ],
    );
  }

  SizedBox _rowWidget({
    required String row,
    required String brand,
    required String barcode,
    required String oldPrice,
    required String discount,
    required String error,
    bool isHead = false,
  }) {
    var fontWeight = isHead ? FontWeight.bold : FontWeight.normal;
    double fontSize = isHead ? 16 : 12;
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Container(
            width: 80,
            // color: Colors.amber,
            alignment: Alignment.center,
            child: Text(
              row,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            width: 100,
            // color: Colors.red,
            alignment: Alignment.center,
            child: Text(
              brand,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            width: 140,
            alignment: Alignment.center,
            child: Text(
              barcode,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              oldPrice,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              discount,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            width: 150,
            alignment: Alignment.center,
            child: Text(
              error,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<ExcelParseResultPromo> parseExcelToAccessoryPromo() async {
    try {
      // Pick Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        onFileLoading: (loading) {
          log(loading.name);
        },
      );

      if (result == null) {
        log("No file selected.");
        return ExcelParseResultPromo(
            code: 400,
            msg: "No file selected.",
            validPromos: [],
            invalidRows: []);
      }

      // Get file bytes
      Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) {
        log("Error: Unable to read file bytes.");
        return ExcelParseResultPromo(
            code: 400,
            msg: "Error: Unable to read file bytes.",
            validPromos: [],
            invalidRows: []);
      }

      // Decode Excel
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        log("Error: Excel file has no sheets.");
        return ExcelParseResultPromo(
            code: 400,
            msg: "Error: Excel file has no sheets.",
            validPromos: [],
            invalidRows: []);
      }

      final sheet = excel.tables[excel.tables.keys.first]!;
      List<AccessoryPromo> validPromos = [];
      List<InvalidPromo> invalidRows = [];

      int emptyRowCount = 0;
      int rowIndex = 2; // Start after header rows

      for (var row in sheet.rows.skip(2)) {
        rowIndex++; // Increment row index for each row processed

        // Check if row is completely empty (all cells are null or empty strings)
        bool isRowEmpty = row.every((cell) {
          final value = cell?.value;
          return value == null || value.toString().trim().isEmpty;
        });

        if (isRowEmpty) {
          emptyRowCount++;
          if (emptyRowCount > 5) {
            log("Stopping: More than 5 consecutive empty rows detected.");
            break;
          }
          continue; // Skip empty rows
        }

        emptyRowCount = 0; // Reset counter when valid row found

        try {
          // Extract and sanitize cell values
          final brand = _getString(row[0]);
          final barcode = _getString(row[1]);
          final oldPriceStr = _getString(row[2]);
          final discountStr = _getString(row[3]);

          // Validate required fields
          if (brand.isEmpty ||
              barcode.isEmpty ||
              oldPriceStr.isEmpty ||
              discountStr.isEmpty) {
            invalidRows.add(InvalidPromo(
                row: rowIndex,
                brand: brand,
                barcode: barcode,
                oldPrice: oldPriceStr,
                discount: discountStr,
                error: "Missing required values"));
            continue;
          }

          // Validate numeric formats
          final oldPrice = double.tryParse(oldPriceStr);
          final discount = double.tryParse(discountStr);

          if (oldPrice == null || discount == null) {
            invalidRows.add(InvalidPromo(
              row: rowIndex,
              brand: brand,
              barcode: barcode,
              oldPrice: oldPriceStr,
              discount: discountStr,
              error: "Invalid number format",
            ));
            continue;
          }

          // Create valid promo entry
          validPromos.add(AccessoryPromo(
            brandName: brand,
            barcode: barcode,
            oldPrice: oldPrice,
            newPrice: oldPrice * (1 - discount / 100),
            percentage: discount,
          ));
        } catch (e) {
          log("Error processing row $rowIndex: $e");
          invalidRows.add(InvalidPromo(
            row: rowIndex,
            brand: '',
            barcode: '',
            oldPrice: '',
            discount: '',
            error: "Unexpected error",
          ));
        }
      }

      log("Parsing completed. Valid: ${validPromos.length}, Invalid: ${invalidRows.length}");
      return ExcelParseResultPromo(
        code: 200,
        msg: "Success!",
        validPromos: validPromos,
        invalidRows: invalidRows,
      );
    } catch (e) {
      log("Critical error: $e");
      return ExcelParseResultPromo(
          code: 400,
          msg: "Critical error: $e",
          validPromos: [],
          invalidRows: []);
    }
  }

  /// Extracts and cleans a string from a cell
  String _getString(Data? cell) {
    return cell?.value.toString().trim() ?? "";
  }

  void downloadTemplate() async {
    String path = 'assets/samples/example_accessory_promo.xlsx';
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
}
