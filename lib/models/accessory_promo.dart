class AccessoryPromo {
  final String brandName;
  final String barcode;
  final double oldPrice;
  final double newPrice;

  AccessoryPromo(
      {required this.brandName,
      required this.barcode,
      required this.oldPrice,
      required this.newPrice});
  @override
  String toString() {
    return "AccessoryPromo(Brand Name: $brandName, Barcode: $barcode, oldPrice: $oldPrice, newPrice: $newPrice)";
  }
}
