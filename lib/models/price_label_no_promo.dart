class PriceLabelNoPromo {
  final int index;
  final List<NoPromoItem> items;

  PriceLabelNoPromo({
    required this.index,
    required this.items,
  });

  @override
  String toString() {
    return "PriceLabelNoPromo(index: $index, items: $items)";
  }
}

class NoPromoItem {
  final String name;
  final double price;

  NoPromoItem({
    required this.name,
    required this.price,
  });

  @override
  String toString() {
    return "NoPromoItem(name: $name, Price: $price)";
  }
}
