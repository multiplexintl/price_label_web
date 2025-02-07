class CosmeticsLabelPromo {
  final int percentage;
  final List<PromoItem> items;

  CosmeticsLabelPromo({
    required this.percentage,
    required this.items,
  });

  @override
  String toString() {
    return "CosmeticsLabelPromo(percentage: $percentage, items: $items)";
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

class CosmeticsLabelInvalidPromo {
  final int percentage;
  final List<InvalidCosmeticPromoItem> items;

  CosmeticsLabelInvalidPromo({required this.percentage, required this.items});

  @override
  String toString() {
    return 'CosmeticsLabelInvalidPromo(percentage: $percentage, items: $items)';
  }
}

class InvalidCosmeticPromoItem {
  final int row;
  final String name;
  final String wasPrice;
  final String discount;
  final List<String> errors;

  InvalidCosmeticPromoItem({
    required this.row,
    required this.name,
    required this.wasPrice,
    required this.discount,
    required this.errors,
  });

  @override
  String toString() {
    return 'InvalidCosmeticPromoItem(row: $row, name: $name, wasPrice: $wasPrice, discount: $discount, errors: $errors)';
  }
}

class ExcelParseResultCosmeticPromo {
  final int code;
  final String? msg;
  final List<CosmeticsLabelPromo> validPromos;
  final List<CosmeticsLabelInvalidPromo> invalidPromos;

  ExcelParseResultCosmeticPromo(
      {required this.code,
      this.msg,
      required this.validPromos,
      required this.invalidPromos});

  @override
  String toString() {
    return 'ExcelParseResultCosmeticPromo(Success Code : $code Message: $msg validPromos: $validPromos, invalidPromos: $invalidPromos)';
  }
}
