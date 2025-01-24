class PriceTagExq {
  final String name;
  final double oldPrice;
  final double newPrice;

  PriceTagExq(
      {required this.name, required this.oldPrice, required this.newPrice});
  @override
  String toString() {
    return "PriceTagExq(name: $name, oldPrice: $oldPrice, newPrice: $newPrice)";
  }
}
