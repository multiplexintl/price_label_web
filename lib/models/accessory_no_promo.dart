class AccessoryNoPromo {
  final String brandName;
  final String barcode;
  final double price;

  AccessoryNoPromo(
      {required this.brandName, required this.barcode, required this.price});
  @override
  String toString() {
    return "AccessoryNoPromo(Brand Name: $brandName,Barcode: $barcode, Price: $price)";
  }
}
