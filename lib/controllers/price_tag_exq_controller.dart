import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:price_label_web/models/price_tag_exq.dart';
import 'package:printing/printing.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PriceTagExqController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController newPriceController = TextEditingController();
  var smallText = "All prices are inclusive of VAT".obs;
  var pickedColor = (Colors.red as Color).obs;
  List<GlobalKey> repaintKeys = [];
  var isEditMode = false.obs; // Determines if the button is in "Edit" mode
  var editIndex = -1.obs; // Stores the index of the item being edited

  final transformationController = TransformationController(); // For zoom/pan
  var data = List<PriceTagExq>.generate(
      17,
      (index) => PriceTagExq(
          name: "name $index", oldPrice: index * 2, newPrice: index * 1)).obs;

  var currentPage = 1.obs;
  var totalPages = 1.obs;

  // final pdfDocument = pw.Document(); // Document to build the PDF
  // final pdfController = Rxn<pdfx.PdfController>(); // PDF controller for preview
  late pw.Font regularFont; // Font for regular text
  late pw.Font boldFont; // Font for bold text

  var isStrikeThrogh = false.obs;
  final RxDouble progress = 0.0.obs; // Progress (0.0 to 1.0)
  final RxString progressMessage = "".obs; // Progress message
  final RxBool isProcessing = false.obs; // To track processing state

  @override
  void onInit() {
    super.onInit();
    updateRepaintKeys();
  }

  void updateText(String val) {
    smallText.value = val;
  }

  void selectColor(Color color) {
    pickedColor.value = color;
    update();
  }

  void toggleStrikeThgrough(bool? val) async {
    isStrikeThrogh.value = !isStrikeThrogh.value;
    update();
  }

  void initializePdfController() {
    totalPages.value = 0; // Reset total pages
    currentPage.value = 1; // Reset current page
  }

  void clearInputs() {
    nameController.clear();
    oldPriceController.clear();
    newPriceController.clear();
  }

  // Save or Update item
  void saveOrUpdateItem() {
    final name = nameController.text.trim();
    final oldPrice = double.tryParse(oldPriceController.text.trim());
    final newPrice = double.tryParse(newPriceController.text.trim());

    if (name.isNotEmpty && oldPrice != null && newPrice != null) {
      if (isEditMode.value) {
        // Update existing item
        data[editIndex] = PriceTagExq(
          name: name,
          oldPrice: oldPrice,
          newPrice: newPrice,
        );
        Get.snackbar("Success", "Item updated successfully");
      } else {
        // Save new item
        data.add(PriceTagExq(
          name: name,
          oldPrice: oldPrice,
          newPrice: newPrice,
        ));
        Get.snackbar("Success", "Item added successfully");
      }

      // Reset form and state
      clearInputs();
      isEditMode.value = false;
      editIndex = -1;

      // Notify UI
      update();
    } else {
      Get.snackbar("Error", "Please provide valid values");
    }
  }

  // Edit an item
  void editItem(int index) {
    var item = data[index];

    // Populate the text fields with the item's data
    nameController.text = item.name;
    oldPriceController.text = item.oldPrice.toString();
    newPriceController.text = item.newPrice.toString();

    // Switch to edit mode
    isEditMode.value = true;
    editIndex = index;

    // Notify UI
    update();
  }

  void removeDataByIndex(int index) {
    data.removeAt(index);
    update();
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      update(); // Ensure the UI rebuilds when the page changes
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      update(); // Ensure the UI rebuilds when the page changes
    }
  }

  // Update repaint keys based on total pages
  void updateRepaintKeys() {
    int totalPagesCount =
        (data.length / 18).ceil(); // Assuming 18 items per page
    repaintKeys = List.generate(totalPagesCount, (index) => GlobalKey());
    update();
  }

  Future<void> exportToPdf() async {
    try {
      final pdf = pw.Document();
      final int pageCount = repaintKeys.length;

      // Define estimated times (optional, adjust as needed)
      const double timePerPage = 1.5; // Estimated time to process one page
      double totalEstimatedTime = pageCount * timePerPage;

      // Show progress dialog
      showProgressDialog("Starting PDF export...");

      final Stopwatch stopwatch = Stopwatch()..start(); // Start tracking time

      for (int i = 0; i < pageCount; i++) {
        final key = repaintKeys[i];

        // Validate RepaintBoundary key
        if (key.currentContext == null) {
          updateProgress(i / pageCount,
              "Skipping page ${i + 1} (context null)"); // Update progress
          log("Error: RepaintBoundary key $i context is null");
          continue;
        }

        final RenderRepaintBoundary? boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary?;

        if (boundary == null) {
          updateProgress(i / pageCount,
              "Skipping page ${i + 1} (boundary null)"); // Update progress
          log("Error: RepaintBoundary key $i boundary is null");
          continue;
        }

        try {
          await Future.delayed(
              const Duration(milliseconds: 100)); // Wait for rendering
          final ui.Image image = await boundary.toImage(pixelRatio: 3.125);
          final ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData == null) {
            updateProgress(i / pageCount,
                "Failed to capture page ${i + 1}"); // Update progress
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

          // Update progress based on the number of pages processed
          final elapsedTime = stopwatch.elapsed.inSeconds;
          final remainingTime = totalEstimatedTime - elapsedTime;
          updateProgress((i + 1) / pageCount,
              "Page ${i + 1} processed. Estimated time left: ${remainingTime > 0 ? remainingTime.toInt() : 0}s");
        } catch (e) {
          updateProgress(i / pageCount,
              "Error capturing page ${i + 1}"); // Update progress
          log("Error capturing image for RepaintBoundary key $i: $e");
        }
      }

      updateProgress(1.0, "Finalizing PDF...");
      final Uint8List pdfBytes = await pdf.save();

      if (pdfBytes.isEmpty || pdfBytes.length < 1000) {
        updateProgress(1.0, "PDF generation failed (too small)");
        throw Exception("Generated PDF is invalid or empty");
      }

      // Use Printing plugin to preview the PDF
      updateProgress(1.0, "Opening PDF preview...");
      await Printing.layoutPdf(onLayout: (_) => pdfBytes);

      updateProgress(1.0, "PDF export completed");
    } catch (e) {
      log("Error exporting PDF: $e");
      updateProgress(1.0, "An error occurred: $e");
    } finally {
      await Future.delayed(
          const Duration(seconds: 1)); // Allow user to see the final status
      hideProgressDialog();
    }
  }

  Future<void> downloadPdf() async {
    try {
      final pdf = pw.Document();
      final int pageCount = repaintKeys.length;

      // Define estimated times (in seconds)
      const double timePerPage = 1.5; // Estimated time to capture one page
      const double downloadTime = 3.0; // Buffer time for saving and downloading
      final double totalEstimatedTime = pageCount * timePerPage + downloadTime;

      showProgressDialog("Starting download...");

      final Stopwatch stopwatch = Stopwatch()..start(); // Start tracking time

      for (int i = 0; i < pageCount; i++) {
        final key = repaintKeys[i];

        if (key.currentContext == null) {
          updateProgress(i / pageCount,
              "Skipping page ${i + 1} (context null)"); // Update progress
          log("Error: RepaintBoundary key $i context is null");
          continue;
        }

        final RenderRepaintBoundary? boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary?;

        if (boundary == null) {
          updateProgress(i / pageCount,
              "Skipping page ${i + 1} (boundary null)"); // Update progress
          log("Error: RepaintBoundary key $i boundary is null");
          continue;
        }

        try {
          await Future.delayed(const Duration(milliseconds: 100));
          final ui.Image image = await boundary.toImage(pixelRatio: 3.125);
          final ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData == null) {
            updateProgress(i / pageCount,
                "Failed to capture page ${i + 1}"); // Update progress
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

          // Update progress based on page completion
          final elapsedTime = stopwatch.elapsed.inSeconds;
          final remainingTime = totalEstimatedTime - elapsedTime;
          updateProgress((i + 1) / pageCount,
              "Page ${i + 1} added. Time left: ${remainingTime > 0 ? remainingTime.toInt() : 0}s");
        } catch (e) {
          updateProgress(i / pageCount,
              "Error capturing page ${i + 1}"); // Update progress
          log("Error capturing image for RepaintBoundary key $i: $e");
        }
      }

      // Simulate saving and downloading overhead
      updateProgress(1.0, "Saving PDF...");
      final Uint8List pdfBytes = await pdf.save();

      if (pdfBytes.isEmpty || pdfBytes.length < 1000) {
        updateProgress(1.0, "PDF generation failed (too small)");
        throw Exception("Generated PDF is invalid or empty");
      }

      await Future.delayed(const Duration(seconds: 2)); // Simulate save time

      updateProgress(1.0, "Downloading PDF...");
      if (kIsWeb) {
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'PriceTags.pdf'
          ..click();
        html.Url.revokeObjectUrl(url);
      }

      updateProgress(1.0, "Download complete");
    } catch (e) {
      log("Error in downloadPdf: $e");
      updateProgress(1.0, "An error occurred: $e");
    } finally {
      await Future.delayed(const Duration(seconds: 1)); // Show final status
      hideProgressDialog();
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
