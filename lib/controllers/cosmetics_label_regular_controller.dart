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
import 'package:price_label_web/models/cosmetics_label_regular.dart';
import 'package:printing/printing.dart';
import 'dart:html' as html;

class PriceLabelNoPromoController extends GetxController {
  var settingCon = Get.find<SettingsController>();
  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  final TextEditingController fileNameController = TextEditingController();
  final RxList<Map<String, TextEditingController>> controllers =
      <Map<String, TextEditingController>>[].obs;
  var data = <CosmeticsLabelRegular>[].obs;

  // var isRedColor = false.obs;
  var vatTextController =
      TextEditingController(text: '* All prices are inclusive of VAT').obs;
  var optionalTextController = TextEditingController().obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var editIndex = -1.obs; // Stores the index of the item being edited
  late pw.Font regularFont; // Font for regular text
  late pw.Font boldFont; // Font for bold text

  final RxDouble progress = 0.0.obs; // Progress (0.0 to 1.0)
  final RxString progressMessage = "".obs; // Progress message
  final RxBool isProcessing = false.obs; // To track processing state
  final RxBool isEnabled = false.obs; // To track whether fields are enabled
  final RxBool isEnabledPerc = true.obs; // To track whether fields are enabled

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers for 4 rows
    for (int i = 0; i < 4; i++) {
      controllers.add({
        "description": TextEditingController(),
        "price": TextEditingController(),
      });
    }
    vatTextController.value.addListener(() {
      update();
    });
    optionalTextController.value.addListener(() {
      update();
    });
    if (settingCon.isDemoOn.value) {
      generatePriceLabelNoPromoData();
    }
  }

  void generatePriceLabelNoPromoData() {
    final math.Random random = math.Random();

    // Generate random CosmeticsLabelRegular list
    data.value = List<CosmeticsLabelRegular>.generate(
      random.nextInt(11) +
          20, // Random number of CosmeticsLabelRegular objects (20-30)
      (index) {
        return CosmeticsLabelRegular(
          index: index,
          items: List<RegularItem>.generate(
            random.nextInt(4) + 1, // Random number of RegularItem objects (1-4)
            (itemIndex) {
              final price = random.nextDouble() * (999 - 50) +
                  50; // Random price (50-999)

              return RegularItem(
                name:
                    "Miraya Musky Note Edp oriental ${index + 1}Ml (Unisex) - ${itemIndex + 1}",
                price: price,
              );
            },
          ),
        );
      },
    );
    update();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var controllerMap in controllers) {
      controllerMap["description"]?.dispose();
      controllerMap["price"]?.dispose();
    }
    super.dispose();
  }

  /// Clears a specific row at the given index
  void clearRow(int index) {
    if (index < 0 || index >= controllers.length) return; // Safety check
    controllers[index]["description"]?.clear();
    controllers[index]["price"]?.clear();
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
    for (var controllerMap in controllers) {
      controllerMap["description"]?.clear();
      controllerMap["price"]?.clear();
    }
    isEnabledPerc.value = true; // All rows are now empty
    debugPrint("Cleared all rows");
    isEditMode.value = false;
  }

  void saveOrUpdatePriceLabelNoPromo() {
    // Prepare a list to collect `RegularItem` items
    final List<RegularItem> updatedItems = [];

    // Loop through the controllers to collect data
    for (int i = 0; i < controllers.length; i++) {
      final description = controllers[i]["description"]?.text.trim() ?? "";
      final price =
          double.tryParse(controllers[i]["price"]?.text.trim() ?? "") ?? 0.0;

      if (description.isNotEmpty) {
        updatedItems.add(RegularItem(
          name: description,
          price: price,
        ));
      }
    }

    // Validate data and proceed to Update or Create
    if (isEditMode.value) {
      // Update existing `CosmeticsLabelRegular`
      final index = currentEditIndex.value;
      if (index >= 0 && index < data.length) {
        data[index] = CosmeticsLabelRegular(
          index: data[index].index,
          items: updatedItems,
        );
        log("Updated CosmeticsLabelRegular at index $index: ${data[index]}");
      } else {
        log("Invalid index $index for update.");
      }
    } else {
      // Create new `CosmeticsLabelRegular`
      final newIndex = data.length + 1; // Assuming index is sequential
      data.add(CosmeticsLabelRegular(
        index: newIndex,
        items: updatedItems,
      ));
      log("Added new CosmeticsLabelRegular: ${data.last}");
    }

    // Reset edit mode and clear controllers
    isEditMode.value = false;
    currentEditIndex.value = -1;
    update();
    clearAllRows();
  }

  void editPriceLabelNoPromo(int index) {
    // Set the mode to edit
    isEditMode.value = true;
    currentEditIndex.value = index;

    // Get the `CosmeticsLabelRegular` to edit
    final promo = data[index];

    // Populate the controllers with promo data
    for (int i = 0; i < promo.items.length; i++) {
      controllers[i]["description"]?.text = promo.items[i].name;
      controllers[i]["price"]?.text = promo.items[i].price.toString();
    }

    // Clear remaining controllers, if any
    for (int i = promo.items.length; i < controllers.length; i++) {
      controllers[i]["description"]?.clear();
      controllers[i]["price"]?.clear();
    }

    update();
  }

  void clearAllData() {
    data.clear();
    update();
  }

  void removeDataByIndex(int index) {
    data.removeAt(index);
    update();
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

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/MyriadPro-Bold.ttf');
    return pw.Font.ttf(fontData.buffer.asByteData());
  }

  // Update progress value
  void updateProgress(double value, String message) {
    progress.value = value;
    progressMessage.value = message;
  }

  Future<void> _downloadPdfWeb(Uint8List pdfBytes) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileNameController.text.isEmpty
            ? 'DPH_Perfumes_Label_Regular.pdf'
            : "${fileNameController.text}.pdf"
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
      optionalText: optionalTextController.value.text,
      // isRed: isRedColor.value,
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
    required List<CosmeticsLabelRegular> items,
    required String vatText,
    required String optionalText,
    // required bool isRed,
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
                          optionalText,
                          // isRed,
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

  pw.Widget _buildPriceLabel(CosmeticsLabelRegular promo, String vatText,
      String optText, pw.Font ttf, double totalHeight, double totalWidth) {
    const borderColor = PdfColors.black;
    const textColor = PdfColors.black;
    double totalHeight = 124;
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
              height: 22,
              width: totalWidth,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: borderColor, width: 2)),
              ),
              child: pw.Row(
                children: [
                  _buildHeaderCell(
                    "Description",
                    175,
                    borderColor,
                    ttf,
                    fontSize: 11,
                  ),
                  _buildHeaderCell(
                    "Price",
                    50,
                    borderColor,
                    ttf,
                    fontSize: 11,
                    borderRight: false,
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
                      175,
                      borderColor,
                      ttf,
                      totalHeight,
                    ),
                    // Price Column
                    _buildPriceColumn(
                      promo.items.map((item) => item.price).toList(),
                      53,
                      borderColor,
                      ttf,
                      totalHeight,
                      borderRight: false,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            pw.Container(
              height: 19,
              decoration: const pw.BoxDecoration(
                border:
                    pw.Border(top: pw.BorderSide(color: borderColor, width: 1)),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 5),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(optText,
                        style: pw.TextStyle(
                            font: ttf, fontSize: 9, color: textColor)),
                    pw.Text(vatText,
                        style: pw.TextStyle(
                            font: ttf, fontSize: 9, color: textColor)),
                  ]),
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
              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.Text(
                items[index],
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 11,
                ),
              ),
            ),
          // Add empty containers if less than 4 items
          // if (items.length < 4)
          //   for (int i = 0; i < 4 - items.length; i++)
          //     pw.Container(height: itemHeight),
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
    bool borderRight = true,
  }) {
    final itemCount = prices.length.clamp(1, 4);
    final itemHeight = totalHeight / itemCount;

    return pw.Container(
      width: width,
      height: totalHeight,
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
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "AED",
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      height: 0.8,
                    ),
                  ),
                  pw.Text(
                    prices[index].toStringAsFixed(2),
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ///////////
  ///
  void downloadTemplate() async {
    String path = 'assets/samples/example_DPH & Cosmetics Label Regular.xlsx';
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
    var result = await parseExcelToLabelRegular();
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
    var validData = result.validRegular;
    var invalidData = result.invalidRegular;

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

  Widget _buildInvalidTable(List<CosmeticsLabelInvalidRegular> invalidData) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxHeight: 300), // Ensures proper scrolling
      child: SingleChildScrollView(
        child: Column(
          children: [
            _rowWidget(
              rowValues: {
                41.0: "Index",
                40.0: "Row", // Small width for Row number
                200.0: "Description", // Wider column for description
                100.0: "Regular Price",
                170.0: "Errors",
              },
              isHead: true,
            ),
            ...List.generate(invalidData.length, (batchIndex) {
              var batch = invalidData[batchIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...List.generate(batch.items.length, (index) {
                    var item = batch.items[index];
                    return _rowWidget(
                      rowValues: {
                        41.0: batch.index.toString(),
                        40: item.row.toString(),
                        200: item.name,
                        100: item.regularPrice,
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

  Future<ExcelParseResultCosmeticRegular> parseExcelToLabelRegular() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        return ExcelParseResultCosmeticRegular(
            code: 400, validRegular: [], invalidRegular: []);
      }

      final Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) {
        return ExcelParseResultCosmeticRegular(
            code: 400, validRegular: [], invalidRegular: []);
      }

      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return ExcelParseResultCosmeticRegular(
            code: 400, validRegular: [], invalidRegular: []);
      }

      final sheet = excel.tables.values.first;
      final List<CosmeticsLabelRegular> validRegular = [];
      final List<CosmeticsLabelInvalidRegular> invalidRegular = [];

      int rowIndex = 2; // Start after headers
      List<RegularItem> currentBatchItems = [];
      List<InvalidCosmeticRegularItem> batchErrors = [];
      int batchIndex = 1;
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
            batchIndex,
            validRegular,
            batchErrors,
            invalidRegular,
            hasBatchError,
          );
          currentBatchItems = [];
          hasBatchError = false;
          batchErrors = [];
          batchIndex++;

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
        final priceStr = rowValues[1];

        final price = double.tryParse(priceStr);
        final errors = <String>[];

        if (description.isEmpty) errors.add("Missing product name");
        if (price == null) errors.add("Invalid Regular Price");

        if (errors.isNotEmpty) {
          batchErrors.add(InvalidCosmeticRegularItem(
            row: rowIndex,
            name: description,
            regularPrice: priceStr,
            errors: errors,
          ));
          hasBatchError = true;
          continue;
        }

        currentBatchItems.add(RegularItem(
          name: description,
          price: price!,
        ));

        // Handle batch splitting if more than 4 items
        if (currentBatchItems.length == 4) {
          _finalizeBatch(
            currentBatchItems,
            batchIndex,
            validRegular,
            batchErrors,
            invalidRegular,
            hasBatchError,
          );
          currentBatchItems = [];
          hasBatchError = false;
          batchErrors = [];
          batchIndex++;
        }
      }

      // Process remaining batch items if we haven't hit 5 empty rows
      if (consecutiveEmptyRows < 5 &&
          (currentBatchItems.isNotEmpty || batchErrors.isNotEmpty)) {
        _finalizeBatch(
          currentBatchItems,
          batchIndex,
          validRegular,
          batchErrors,
          invalidRegular,
          hasBatchError,
        );
      }

      return ExcelParseResultCosmeticRegular(
          code: 200,
          validRegular: validRegular,
          invalidRegular: invalidRegular);
    } catch (e) {
      log("Error parsing label regular items: $e");
      return ExcelParseResultCosmeticRegular(
          code: 400, validRegular: [], invalidRegular: []);
    }
  }

  void _finalizeBatch(
    List<RegularItem> items,
    int index,
    List<CosmeticsLabelRegular> validRegular,
    List<InvalidCosmeticRegularItem> batchErrors,
    List<CosmeticsLabelInvalidRegular> invalidRegular,
    bool hasError,
  ) {
    if (hasError || batchErrors.isNotEmpty) {
      invalidRegular
          .add(CosmeticsLabelInvalidRegular(index: index, items: batchErrors));
      return;
    }

    if (items.isEmpty || items.length > 4) return;

    validRegular.add(CosmeticsLabelRegular(index: index, items: items));
  }

  String _getString(Data? cell) => cell?.value?.toString().trim() ?? '';
}
