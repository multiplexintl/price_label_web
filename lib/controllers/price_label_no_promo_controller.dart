import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:price_label_web/models/price_label_no_promo.dart';
import 'package:printing/printing.dart';
import 'dart:html' as html;

class PriceLabelNoPromoController extends GetxController {

  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  List<GlobalKey> repaintKeys = [];
  final TextEditingController fileNameController = TextEditingController();
  final RxList<Map<String, TextEditingController>> controllers =
      <Map<String, TextEditingController>>[].obs;
  var data = List<PriceLabelNoPromo>.generate(
    0,
    (index) => PriceLabelNoPromo(
      index: index,
      items: List<NoPromoItem>.generate(
        4, // Number of NoPromoItem objects per PriceLabelPromo
        (itemIndex) => NoPromoItem(
          name:
              "Miraya Musky Note Edp oriental ${index + 1}Ml (Unisex) - ${itemIndex + 1}",
          price: (itemIndex + 1) * 257.0,
        ),
      ),
    ),
  ).obs;

  var isRedColor = false.obs;
  var smallText = "* All prices are inclusive of VAT".obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var editIndex = -1.obs; // Stores the index of the item being edited

  final transformationController = TransformationController(); // For zoom/pan
  var pickedColor = (Colors.red as Color).obs;

  // final pdfDocument = pw.Document(); // Document to build the PDF
  // final pdfController = Rxn<pdfx.PdfController>(); // PDF controller for preview
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
    // Prepare a list to collect `NoPromoItem` items
    final List<NoPromoItem> updatedItems = [];

    // Loop through the controllers to collect data
    for (int i = 0; i < controllers.length; i++) {
      final description = controllers[i]["description"]?.text.trim() ?? "";
      final price =
          double.tryParse(controllers[i]["price"]?.text.trim() ?? "") ?? 0.0;

      if (description.isNotEmpty) {
        updatedItems.add(NoPromoItem(
          name: description,
          price: price,
        ));
      }
    }

    // Validate data and proceed to Update or Create
    if (isEditMode.value) {
      // Update existing `PriceLabelNoPromo`
      final index = currentEditIndex.value;
      if (index >= 0 && index < data.length) {
        data[index] = PriceLabelNoPromo(
          index: data[index].index,
          items: updatedItems,
        );
        log("Updated PriceLabelNoPromo at index $index: ${data[index]}");
      } else {
        log("Invalid index $index for update.");
      }
    } else {
      // Create new `PriceLabelNoPromo`
      final newIndex = data.length + 1; // Assuming index is sequential
      data.add(PriceLabelNoPromo(
        index: newIndex,
        items: updatedItems,
      ));
      log("Added new PriceLabelNoPromo: ${data.last}");
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

    // Get the `PriceLabelNoPromo` to edit
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

  void updateText(String val) {
    smallText.value = val;
  }

  // Update repaint keys based on total pages
  void updateRepaintKeys() {
    int totalPagesCount =
        (data.length / 10).ceil(); // Assuming 10 items per page
    repaintKeys = List.generate(totalPagesCount, (index) => GlobalKey());
    update();
  }

  Future<void> generatePdf({bool isDownload = false}) async {
    try {
      const int batchSize = 10; // Number of pages to process per batch
      final pdf = pw.Document();
      final int pageCount = repaintKeys.length;

      // Define quality settings and estimated processing times
      const double pixelRatio = 4.0; // High-quality rendering
      const double timePerPage = 1.5; // Estimated time to process each page
      const double downloadTime = 3.0; // Estimated download time for saving
      final double totalEstimatedTime = isDownload
          ? pageCount * timePerPage + downloadTime
          : pageCount * timePerPage;

      showProgressDialog(
          isDownload ? "Preparing to download..." : "Starting PDF export...");

      final Stopwatch stopwatch = Stopwatch()..start();

      for (int batchStart = 0;
          batchStart < pageCount;
          batchStart += batchSize) {
        // Calculate the range of pages for the current batch
        final int batchEnd = (batchStart + batchSize > pageCount)
            ? pageCount
            : batchStart + batchSize;

        for (int i = batchStart; i < batchEnd; i++) {
          final key = repaintKeys[i];

          // Validate RepaintBoundary key
          if (key.currentContext == null) {
            updateProgress(
              i / pageCount,
              "Skipping page ${i + 1} (context null)",
            );
            log("Error: RepaintBoundary key $i context is null");
            continue;
          }

          final RenderRepaintBoundary? boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary?;

          if (boundary == null) {
            updateProgress(
              i / pageCount,
              "Skipping page ${i + 1} (boundary null)",
            );
            log("Error: RepaintBoundary key $i boundary is null");
            continue;
          }

          try {
            // Render image with specified pixel ratio
            await Future.delayed(const Duration(milliseconds: 100));
            final ui.Image image =
                await boundary.toImage(pixelRatio: pixelRatio);
            final ByteData? byteData =
                await image.toByteData(format: ui.ImageByteFormat.png);

            if (byteData == null) {
              updateProgress(
                i / pageCount,
                "Failed to capture page ${i + 1}",
              );
              log("Error: ByteData for RepaintBoundary key $i is null");
              continue;
            }

            final Uint8List pngBytes = byteData.buffer.asUint8List();
            final imageProvider = pw.MemoryImage(pngBytes);

            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Image(
                      imageProvider,
                      fit: pw.BoxFit.contain,
                      width: PdfPageFormat.a4.width,
                      height: PdfPageFormat.a4.height,
                    ),
                  );
                },
              ),
            );

            // Update progress dynamically
            final elapsedTime = stopwatch.elapsed.inSeconds;
            final remainingTime = totalEstimatedTime - elapsedTime;
            updateProgress(
              (i + 1) / pageCount,
              "Page ${i + 1} processed. Estimated time left: ${remainingTime > 0 ? remainingTime.toInt() : 0}s",
            );
          } catch (e) {
            updateProgress(
              i / pageCount,
              "Error capturing page ${i + 1}",
            );
            log("Error capturing image for RepaintBoundary key $i: $e");
          }
        }

        // Flush batch to release memory
        await Future.delayed(const Duration(seconds: 1));
        log("Batch processed: $batchStart to $batchEnd");
      }

      updateProgress(1.0, "Finalizing PDF...");
      final Uint8List pdfBytes = await pdf.save();

      if (pdfBytes.isEmpty || pdfBytes.length < 1000) {
        updateProgress(1.0, "PDF generation failed (too small)");
        throw Exception("Generated PDF is invalid or empty");
      }

      if (isDownload) {
        // Simulate saving and downloading
        updateProgress(1.0, "Saving PDF...");
        await Future.delayed(const Duration(seconds: 2));

        updateProgress(1.0, "Downloading PDF...");
        await _downloadPdfWeb(pdfBytes);
        fileNameController.clear();
        updateProgress(1.0, "Download complete");
      } else {
        // Preview the PDF
        updateProgress(1.0, "Opening PDF preview...");
        await Printing.layoutPdf(onLayout: (_) => pdfBytes);
        updateProgress(1.0, "PDF export completed");
      }
    } catch (e) {
      log("Error in generatePdf: $e");
      updateProgress(1.0, "An error occurred: $e");
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      hideProgressDialog();
    }
  }

  Future<void> _downloadPdfWeb(Uint8List pdfBytes) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileNameController.text.isEmpty
            ? 'Price_Label_No_Promo.pdf'
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
}
