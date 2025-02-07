// Shared Configuration
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PriceLabelConfig {
  // Dimensions
  static const double itemWidth = 302.36;
  static const double itemHeight = 219.21;
  static const double a4Width = 794.0;
  static const double a4Height = 1123.0;
  static const double headerHeight = 30.0;
  static const double footerHeight = 19.0;
  static const double contentHeight = 167.0;

  // Spacing
  static const double gridHorizontalSpacing = 105.0;
  static const double gridVerticalSpacing = 50.0;
  static const double pageHorizontalPadding = 40.0;
  static const double pageVerticalPadding = 20.0;

  // Column Widths
  static const Map<String, double> columnWidths = {
    'description': 155.0,
    'was': 48.5,
    'discount': 48.0,
    'now': 45.0,
  };

  // Styles
  static const headerStyle = {
    'fontSize': 12.0,
    'fontFamily': 'MyriadPro',
  };

  static const discountStyle = {
    'fontSize': 14.0,
    'fontFamily': 'MyriadPro',
    'fontWeight': FontWeight.bold,
  };

  static const priceStyle = {
    'fontSize': 12.0,
    'fontFamily': 'MyriadPro',
  };

  static const footerStyle = {
    'fontSize': 10.0,
    'fontFamily': 'MyriadPro',
  };
}

// Abstract Builder
abstract class PriceLabelBuilder {
  Widget buildContainer(List<Widget> children, bool isRed);
  Widget buildHeader();
  Widget buildFooter(String vatText, bool isRed);
  Widget buildContentRow(
      String name, double oldPrice, double newPrice, bool isRed);
  Widget buildDiscountCell(double percentage);
}

// Flutter Implementation
class FlutterLabelBuilder extends PriceLabelBuilder {
  @override
  Widget buildContainer(List<Widget> children, bool isRed) {
    return Container(
      width: PriceLabelConfig.itemWidth,
      height: PriceLabelConfig.itemHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: isRed ? Colors.red : Colors.black,
          width: 2,
        ),
      ),
      child: Column(children: children),
    );
  }

  @override
  Widget buildHeader() {
    return Container(
      height: PriceLabelConfig.headerHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        children: [
          _buildHeaderCell(
              "Description", PriceLabelConfig.columnWidths['description']!),
          _buildHeaderCell("WAS", PriceLabelConfig.columnWidths['was']!),
          _buildHeaderCell(
              "Discount", PriceLabelConfig.columnWidths['discount']!),
          _buildHeaderCell("NOW", PriceLabelConfig.columnWidths['now']!),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(text,
          style: TextStyle(
            fontSize: double.parse(double.parse(
                    PriceLabelConfig.headerStyle['fontSize'].toString())
                .toString()),
            fontFamily: PriceLabelConfig.headerStyle['fontFamily'].toString(),
          )),
    );
  }

  @override
  Widget buildFooter(String vatText, bool isRed) {
    return Container(
      height: PriceLabelConfig.footerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border(
            top:
                BorderSide(color: isRed ? Colors.red : Colors.black, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("* All prices are in AED",
              style: TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.footerStyle['fontSize'].toString()),
                fontFamily:
                    PriceLabelConfig.footerStyle['fontFamily'].toString(),
                color: isRed ? Colors.red : Colors.black,
              )),
          Text(vatText,
              style: TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.footerStyle['fontSize'].toString()),
                fontFamily:
                    PriceLabelConfig.footerStyle['fontFamily'].toString(),
                color: isRed ? Colors.red : Colors.black,
              )),
        ],
      ),
    );
  }

  @override
  Widget buildContentRow(
      String name, double oldPrice, double newPrice, bool isRed) {
    return Expanded(
      child: Row(
        children: [
          _buildContentColumn(
            width: PriceLabelConfig.columnWidths['description']!,
            items: [name],
            isRed: isRed,
            isPrice: false,
          ),
          _buildContentColumn(
            width: PriceLabelConfig.columnWidths['was']!,
            items: [oldPrice],
            isRed: isRed,
            isPrice: true,
            lineThrough: true,
          ),
          buildDiscountCell(0), // Placeholder, will be replaced
          _buildContentColumn(
            width: PriceLabelConfig.columnWidths['now']!,
            items: [newPrice],
            isRed: isRed,
            isPrice: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContentColumn({
    required double width,
    required List<dynamic> items,
    required bool isRed,
    bool isPrice = false,
    bool lineThrough = false,
  }) {
    return Container(
      width: width,
      height: PriceLabelConfig.contentHeight,
      decoration: BoxDecoration(
        border: Border(
            right:
                BorderSide(color: isRed ? Colors.red : Colors.black, width: 1)),
      ),
      child: Column(
        children: items
            .map((item) => Container(
                  height: PriceLabelConfig.contentHeight / items.length,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: items.last != item
                          ? (isRed ? Colors.red : Colors.black)
                          : Colors.transparent,
                      width: 1,
                    )),
                  ),
                  child: isPrice
                      ? Text((item as double).toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: double.parse(PriceLabelConfig
                                .priceStyle['fontSize']
                                .toString()),
                            fontFamily: PriceLabelConfig
                                .priceStyle['fontFamily']
                                .toString(),
                            decoration:
                                lineThrough ? TextDecoration.lineThrough : null,
                            decorationColor: isRed ? Colors.red : Colors.black,
                            decorationThickness: 2,
                          ))
                      : Text(item.toString(),
                          style: TextStyle(
                            fontSize: double.parse(PriceLabelConfig
                                .priceStyle['fontSize']
                                .toString()),
                            fontFamily: PriceLabelConfig
                                .priceStyle['fontFamily']
                                .toString(),
                          )),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget buildDiscountCell(double percentage) {
    return Container(
      width: PriceLabelConfig.columnWidths['discount']!,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 1)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$percentage%",
              style: TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.discountStyle['fontSize'].toString()),
                fontFamily:
                    PriceLabelConfig.discountStyle['fontFamily'].toString(),
                fontWeight: FontWeight.bold,
              )),
          Text("OFF",
              style: TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.discountStyle['fontSize'].toString()),
                fontFamily:
                    PriceLabelConfig.discountStyle['fontFamily'].toString(),
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}

// PDF Implementation
class PdfLabelBuilder {
  final pw.Font font;

  PdfLabelBuilder(this.font);

  pw.Widget buildContainer(List<pw.Widget> children, bool isRed) {
    return pw.Container(
      width: PriceLabelConfig.itemWidth,
      height: PriceLabelConfig.itemHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: isRed ? PdfColors.red : PdfColors.black,
          width: 2,
        ),
      ),
      child: pw.Column(children: children),
    );
  }

  pw.Widget buildHeader() {
    return pw.Container(
      height: PriceLabelConfig.headerHeight,
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 2)),
      ),
      child: pw.Row(
        children: [
          _buildHeaderCell(
              "Description", PriceLabelConfig.columnWidths['description']!),
          _buildHeaderCell("WAS", PriceLabelConfig.columnWidths['was']!),
          _buildHeaderCell(
              "Discount", PriceLabelConfig.columnWidths['discount']!),
          _buildHeaderCell("NOW", PriceLabelConfig.columnWidths['now']!),
        ],
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text, double width) {
    return pw.Container(
      width: width,
      alignment: pw.Alignment.center,
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontSize: double.parse(
                PriceLabelConfig.headerStyle['fontSize'].toString()),
            font: font,
          )),
    );
  }

  pw.Widget buildFooter(String vatText, bool isRed) {
    return pw.Container(
      height: PriceLabelConfig.footerHeight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(
          color: isRed ? PdfColors.red : PdfColors.black,
          width: 1,
        )),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("* All prices are in AED",
              style: pw.TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.footerStyle['fontSize'].toString()),
                font: font,
                color: isRed ? PdfColors.red : PdfColors.black,
              )),
          pw.Text(vatText,
              style: pw.TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.footerStyle['fontSize'].toString()),
                font: font,
                color: isRed ? PdfColors.red : PdfColors.black,
              )),
        ],
      ),
    );
  }

  pw.Widget buildContentRow(
      String name, double oldPrice, double newPrice, bool isRed) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          _buildContentColumn(
            width: PriceLabelConfig.columnWidths['description']!,
            items: [name],
            isRed: isRed,
          ),
          _buildPriceColumn(
            width: PriceLabelConfig.columnWidths['was']!,
            prices: [oldPrice],
            isRed: isRed,
            lineThrough: true,
          ),
          buildDiscountCell(0), // Placeholder
          _buildPriceColumn(
            width: PriceLabelConfig.columnWidths['now']!,
            prices: [newPrice],
            isRed: isRed,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildContentColumn({
    required double width,
    required List<String> items,
    required bool isRed,
  }) {
    return pw.Container(
      width: width,
      height: PriceLabelConfig.contentHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border(
            right: pw.BorderSide(
          color: isRed ? PdfColors.red : PdfColors.black,
          width: 1,
        )),
      ),
      child: pw.Column(
        children: items
            .map((item) => pw.Container(
                  height: PriceLabelConfig.contentHeight / items.length,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                      color: (isRed ? PdfColors.red : PdfColors.black),
                      width: 1,
                    )),
                  ),
                  child: pw.Text(item,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: double.parse(
                            PriceLabelConfig.priceStyle['fontSize'].toString()),
                        font: font,
                      )),
                ))
            .toList(),
      ),
    );
  }

  pw.Widget _buildPriceColumn({
    required double width,
    required List<double> prices,
    required bool isRed,
    bool lineThrough = false,
  }) {
    return pw.Container(
      width: width,
      height: PriceLabelConfig.contentHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border(
            right: pw.BorderSide(
          color: isRed ? PdfColors.red : PdfColors.black,
          width: 1,
        )),
      ),
      child: pw.Column(
        children: prices
            .map((price) => pw.Container(
                  height: PriceLabelConfig.contentHeight / prices.length,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                      color: (isRed ? PdfColors.red : PdfColors.black),
                      width: 1,
                    )),
                  ),
                  child: pw.Text(price.toStringAsFixed(2),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: double.parse(
                            PriceLabelConfig.priceStyle['fontSize'].toString()),
                        font: font,
                        decoration:
                            lineThrough ? pw.TextDecoration.lineThrough : null,
                        decorationColor: PdfColors.red,
                        decorationStyle: pw.TextDecorationStyle.solid,
                      )),
                ))
            .toList(),
      ),
    );
  }

  pw.Widget buildDiscountCell(double percentage) {
    return pw.Container(
      width: PriceLabelConfig.columnWidths['discount']!,
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("$percentage%",
              style: pw.TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.discountStyle['fontSize'].toString()),
                font: font,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.Text("OFF",
              style: pw.TextStyle(
                fontSize: double.parse(
                    PriceLabelConfig.discountStyle['fontSize'].toString()),
                font: font,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
