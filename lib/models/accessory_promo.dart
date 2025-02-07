class AccessoryPromo {
  final String brandName;
  final String barcode;
  final double oldPrice;
  final double newPrice;
  final double percentage;

  AccessoryPromo(
      {required this.brandName,
      required this.barcode,
      required this.oldPrice,
      required this.newPrice,
      required this.percentage});
  @override
  String toString() {
    return "AccessoryPromo(Brand Name: $brandName, Barcode: $barcode, oldPrice: $oldPrice, newPrice: $newPrice, percentage: $percentage)";
  }
}

class InvalidPromo {
  final int row;
  final String brand;
  final String barcode;
  final String oldPrice;
  final String discount;
  final String error;

  InvalidPromo({
    required this.row,
    required this.brand,
    required this.barcode,
    required this.oldPrice,
    required this.discount,
    required this.error,
  });

  @override
  String toString() {
    return 'InvalidPromo(row: $row, brand: $brand, barcode: $barcode, oldPrice: $oldPrice, discount: $discount, error: $error)';
  }
}

class ExcelParseResultPromo {
  final int code;
  final String? msg;
  final List<AccessoryPromo> validPromos;
  final List<InvalidPromo> invalidRows;

  ExcelParseResultPromo(
      {this.msg,
      required this.code,
      required this.validPromos,
      required this.invalidRows});

  @override
  String toString() {
    return 'ExcelParseResultPromo(\n'
        '  Success Code : $code Message: $msg'
        '  validPromos: ${validPromos.map((promo) => promo.toString()).join(', ')},\n'
        '  invalidRows: ${invalidRows.map((row) => row.toString()).join(', ')}\n'
        ')';
  }
}
