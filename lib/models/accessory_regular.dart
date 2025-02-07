class AccessoryRegular {
  final String brandName;
  final String barcode;
  final double price;

  AccessoryRegular(
      {required this.brandName, required this.barcode, required this.price});
  @override
  String toString() {
    return "AccessoryRegular(Brand Name: $brandName,Barcode: $barcode, Price: $price)";
  }
}

class InvalidRegular {
  final int row;
  final String brand;
  final String barcode;
  final String price;
  final String error;

  InvalidRegular({
    required this.row,
    required this.brand,
    required this.barcode,
    required this.price,
    required this.error,
  });

  @override
  String toString() {
    return 'InvalidRegular(row: $row, brand: $brand, barcode: $barcode, price: $price, error: $error)';
  }
}

class ExcelParseResultRegular {
  final int code;
  final String? msg;
  final List<AccessoryRegular> validRows;
  final List<InvalidRegular> invalidRows;

  ExcelParseResultRegular(
      {this.msg,
      required this.code,
      required this.validRows,
      required this.invalidRows});

  @override
  String toString() {
    return 'ExcelParseResultRegular(\n'
        '  Success Code : $code Message: $msg'
        '  validRows: ${validRows.map((promo) => promo.toString()).join(', ')},\n'
        '  invalidRows: ${invalidRows.map((row) => row.toString()).join(', ')}\n'
        ')';
  }
}
