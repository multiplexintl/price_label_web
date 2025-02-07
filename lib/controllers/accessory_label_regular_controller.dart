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
import 'package:price_label_web/models/accessory_regular.dart';
import 'package:printing/printing.dart';

import 'dart:html' as html;

class AccessoryLabelNoPromoController extends GetxController {
  var settingsCon = Get.find<SettingsController>();
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  List<GlobalKey> repaintKeys = [];
  var data = <AccessoryRegular>[].obs;
  // var isRedColor = false.obs;
  final vatTextController =
      TextEditingController(text: "* All prices are inclusive of VAT").obs;
  final optionalTextController = TextEditingController().obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var editIndex = -1.obs;

  final RxDouble progress = 0.0.obs; // Progress (0.0 to 1.0)
  final RxString progressMessage = "".obs; // Progress message
  final RxBool isProcessing = false.obs; // To track processing state
  final RxBool isEnabled = false.obs; // To track whether fields are enabled
  final RxBool isEnabledPerc = true.obs; // To track whether fields are enabled

  @override
  void onInit() {
    super.onInit();
    vatTextController.value.addListener(() {
      update();
    });
    optionalTextController.value.addListener(() {
      update();
    });
    if (settingsCon.isDemoOn.value) {
      generateAccessoryNoPromoData();
    }
  }

  void generateAccessoryNoPromoData() {
    final math.Random random = math.Random();

    // Generate random AccessoryRegular list
    data.value = List<AccessoryRegular>.generate(
      random.nextInt(11) +
          20, // Random number of AccessoryRegular objects (20-30)
      (index) {
        // Generate a random 13-digit barcode
        final barcode = List.generate(13, (_) => random.nextInt(10))
            .join(); // Generate a string of 13 random digits

        // Generate a random price between 50 and 999
        final price = random.nextDouble() * (999 - 50) + 50;

        return AccessoryRegular(
          brandName: "eylure", // Constant brand name
          barcode: barcode,
          price: price,
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
  void clearRow(int index) {}

  /// Clears all rows
  void clearAllRows() {
    brandNameController.clear();
    priceController.clear();
    barcodeController.clear();
    debugPrint("Cleared all rows");
    isEditMode.value = false;
  }

  void saveOrUpdatePriceLabelPromo() {
    // Collect data from controllers
    final brandName = brandNameController.text.trim();
    final barcode = barcodeController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    // Validate required fields
    if (brandName.isEmpty || barcode.isEmpty || price == 0.0) {
      log("Error: Enter valid items.");
      return;
    }

    // Update or Create
    if (isEditMode.value) {
      // Update existing AccessoryRegular
      final index = currentEditIndex.value;
      if (index >= 0 && index < data.length) {
        data[index] = AccessoryRegular(
            brandName: brandName, barcode: barcode, price: price);
        log("Updated AccessoryRegular at index $index: ${data[index]}");
      } else {
        log("Error: Invalid index for update.");
      }
    } else {
      // Create new AccessoryRegular
      final newPromo = AccessoryRegular(
        brandName: brandName,
        barcode: barcode,
        price: price,
      );
      data.add(newPromo);
      log("Added new AccessoryRegular: $newPromo");
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

    // Get the AccessoryRegular to edit
    final promo = data[index];

    // Populate the controllers with the promo data
    brandNameController.text = promo.brandName;
    barcodeController.text = promo.barcode;
    priceController.text = promo.price.toStringAsFixed(2);

    log("Editing AccessoryRegular at index $index: $promo");

    // Trigger UI updates
    update();
  }

  void copyPriceLabelPromo(int index) {
    if (index >= 0 && index < data.length) {
      // Retrieve the original promo
      final originalPromo = data[index];

      // Create a new copy with the same values
      final copiedPromo = AccessoryRegular(
          brandName: originalPromo.brandName,
          price: originalPromo.price,
          barcode: originalPromo.barcode);

      // Insert the copy right after the original item
      data.insert(index + 1, copiedPromo);

      log("Copied AccessoryRegular from index $index to index ${index + 1}: $copiedPromo");

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

  void clearAllData() {
    data.clear();
    update();
  }

  void downloadPDF({required bool isDownload}) async {
    // showProgressDialog("Starting PDF generation...");

    // Handle download or print
    final pdfBytes = await generateAccessoriesPdf(
        items: data,
        vatText: vatTextController.value.text,
        optText: optionalTextController.value.text
        // isRed: isRedColor.value,
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
            ? 'Accessory_Label_Regular.pdf'
            : "${fileNameController.text}.pdf"
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

  Future<Uint8List> generateAccessoriesPdf({
    required List<AccessoryRegular> items,
    required String vatText,
    required String optText,
    // required bool isRed,
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
            // padding:
            //     const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: pw.GridView(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 25,
              childAspectRatio: totalWidth / totalHeight,
              children: [
                for (final item in pageItems)
                  pw.SizedBox(
                    width: totalWidth,
                    height: totalHeight,
                    child: _buildPdfAccessoryLabel(
                      item,
                      vatText,
                      optText,
                      // isRed,
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

  pw.Widget _buildPdfAccessoryLabel(
    AccessoryRegular promo,
    String vatText,
    String optText,
    // bool isRed,
    pw.Font font,
    double totalWidth,
    double totalHeight,
  ) {
    // final borderColor = isRed ? PdfColors.red : PdfColors.black;
    const borderColor = PdfColors.black;
    const textColor = PdfColors.black;

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
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 130,
                  height: 20,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        right: pw.BorderSide(color: borderColor, width: 1)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "ITEM",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  width: 50,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "PRICE",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Container(
                    width: 130,
                    height: 85,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          promo.brandName.toUpperCase(),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          promo.barcode,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ],
                    )),
                pw.Container(
                    width: 50,
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          "AED",
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                        pw.Text(
                          promo.price.toStringAsFixed(2),
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          // Footer
          pw.Container(
            height: 15,
            decoration: const pw.BoxDecoration(
              border:
                  pw.Border(top: pw.BorderSide(color: borderColor, width: 1)),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 8),
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

  void downloadTemplate() async {
    String path = 'assets/samples/example_accessory_regular.xlsx';
    ByteData data = await rootBundle.load(path);
    var fileBytes = data.buffer.asUint8List();
    await downloadPreforma(fileBytes, "Accessory Label Regular Preforma.xlsx");
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
      var validData = result.validRows;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "${validData.length} valid rows were successfully extracted from the Excel file."),
            const SizedBox(height: 20),
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
      AlertDialog(
        title: Center(child: Text(title)),
        content: content,
        actions: actions,
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Text(message);
  }

  Widget _buildInvalidTable(List<InvalidRegular> invalidData) {
    return Column(
      children: [
        _rowWidget(
          row: "Row",
          brand: "Brand",
          barcode: "Barcode",
          price: "Price",
          error: "Error!",
          isHead: true,
        ),
        ...invalidData.map((data) => _rowWidget(
              row: data.row.toString(),
              brand: data.brand,
              barcode: data.barcode,
              price: data.price,
              error: data.error,
            ))
      ],
    );
  }

  Widget _buildValidTable(List<AccessoryRegular> validData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _rowWidget(
          row: "Sl No",
          brand: "Brand",
          barcode: "Barcode",
          price: "Price",
          isHead: true,
        ),
        ...validData.asMap().entries.map((entry) {
          int index = entry.key + 1; // Start index from 1
          var data = entry.value;

          return _rowWidget(
            row: index.toString(), // Display index
            brand: data.brandName,
            barcode: data.barcode,
            price: data.price.toString(),
          );
        }),
      ],
    );
  }

  SizedBox _rowWidget({
    required String row,
    required String brand,
    required String barcode,
    required String price,
    String? error,
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
              price,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
          if (error != null)
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

  Future<ExcelParseResultRegular> parseExcelToAccessoryPromo() async {
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
        return ExcelParseResultRegular(
            code: 400,
            msg: "No file selected.",
            validRows: [],
            invalidRows: []);
      }

      // Get file bytes
      Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) {
        log("Error: Unable to read file bytes.");
        return ExcelParseResultRegular(
            code: 400,
            msg: "Error: Unable to read file bytes.",
            validRows: [],
            invalidRows: []);
      }

      // Decode Excel
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        log("Error: Excel file has no sheets.");
        return ExcelParseResultRegular(
            code: 400,
            msg: "Error: Excel file has no sheets.",
            validRows: [],
            invalidRows: []);
      }

      final sheet = excel.tables[excel.tables.keys.first]!;
      List<AccessoryRegular> validRows = [];
      List<InvalidRegular> invalidRows = [];

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
          final priceStr = _getString(row[2]);

          // Validate required fields
          if (brand.isEmpty || barcode.isEmpty || priceStr.isEmpty) {
            invalidRows.add(InvalidRegular(
                row: rowIndex,
                brand: brand,
                barcode: barcode,
                price: priceStr,
                error: "Missing required values"));
            continue;
          }

          // Validate numeric formats
          final price = double.tryParse(priceStr);

          if (price == null) {
            invalidRows.add(InvalidRegular(
              row: rowIndex,
              brand: brand,
              barcode: barcode,
              price: priceStr,
              error: "Invalid number format",
            ));
            continue;
          }

          // Create valid promo entry
          validRows.add(AccessoryRegular(
            brandName: brand,
            barcode: barcode,
            price: price,
          ));
        } catch (e) {
          log("Error processing row $rowIndex: $e");
          invalidRows.add(InvalidRegular(
            row: rowIndex,
            brand: '',
            barcode: '',
            price: '',
            error: "Unexpected error",
          ));
        }
      }

      log("Parsing completed. Valid: ${validRows.length}, Invalid: ${invalidRows.length}");
      return ExcelParseResultRegular(
        code: 200,
        msg: "Success!",
        validRows: validRows,
        invalidRows: invalidRows,
      );
    } catch (e) {
      log("Critical error: $e");
      return ExcelParseResultRegular(
          code: 400, msg: "Critical error: $e", validRows: [], invalidRows: []);
    }
  }

  String _getString(Data? cell) {
    return cell?.value.toString().trim() ?? "";
  }
}
