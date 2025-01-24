// For web-based file downloads
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:get/get.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'dart:html' as html;

class PDFController extends GetxController {
  final ExportDelegate exportDelegate = ExportDelegate(
      ttfFonts: {
        'Myriad Pro': 'assets/fonts/MyriadPro-Bold.ttf',
      },
      options: const ExportOptions(
        pageFormatOptions: PageFormatOptions.a4(),
      ));

  void createPDF() async {
    final pdf = await exportDelegate.exportToPdfDocument(
      'frame1',
      overrideOptions: const ExportOptions(
        checkboxOptions: CheckboxOptions(
          interactive: false,
        ),
        pageFormatOptions: PageFormatOptions.a4(),
      ),
    );
    final Uint8List pdfBytes = await pdf.save();
    await _downloadPdfWeb(pdfBytes);
  }

  Future<void> _downloadPdfWeb(Uint8List pdfBytes) async {
    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'Price_Label_No_Promo.pdf'
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
