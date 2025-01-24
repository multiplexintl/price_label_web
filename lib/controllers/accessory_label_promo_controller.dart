import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:price_label_web/models/accessory_promo.dart';
import 'package:printing/printing.dart';

import 'dart:html' as html;

class AccessoryLabelPromoController extends GetxController {
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController newPriceController = TextEditingController();
  var isEditMode = false.obs;
  final currentEditIndex = (-1).obs;
  List<GlobalKey> repaintKeys = [];
  var data = List<AccessoryPromo>.generate(
      0,
      (index) => AccessoryPromo(
          brandName: "eylure",
          barcode: '1234567891234',
          oldPrice: index + 1 * 200,
          newPrice: index + 1 * 200)).obs;
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
    brandNameController.clear();
    barcodeController.clear();
    oldPriceController.clear();
    newPriceController.clear();
    debugPrint("Cleared all rows");
    isEditMode.value = false;
    update();
  }

  void saveOrUpdatePriceLabelPromo() {
    // Collect data from controllers
    final brandName = brandNameController.text.trim();
    final barcode = barcodeController.text.trim();
    final oldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0.0;
    final newPrice = double.tryParse(newPriceController.text.trim()) ?? 0.0;

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
    brandNameController.text = promo.brandName;
    barcodeController.text = promo.barcode;
    oldPriceController.text = promo.oldPrice.toStringAsFixed(2);
    newPriceController.text = promo.newPrice.toStringAsFixed(2);

    log("Editing AccessoryPromo at index $index: $promo");

    // Trigger UI updates
    update();
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
            ? 'Accessory_label_Promo.pdf'
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
