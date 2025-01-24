class PriceLabelPromo {
  final int percentage;
  final List<PromoItem> items;

  PriceLabelPromo({
    required this.percentage,
    required this.items,
  });

  @override
  String toString() {
    return "PriceLabelPromo(percentage: $percentage, items: $items)";
  }
}

class PromoItem {
  final String name;
  final double oldPrice;
  final double newPrice;

  PromoItem({
    required this.name,
    required this.oldPrice,
    required this.newPrice,
  });

  @override
  String toString() {
    return "PromoItem(name: $name, oldPrice: $oldPrice, newPrice: $newPrice)";
  }
}
