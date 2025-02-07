class ExcelParseResultCosmeticRegular {
  final int code;
  final String? msg;
  final List<CosmeticsLabelRegular> validRegular;
  final List<CosmeticsLabelInvalidRegular> invalidRegular;

  ExcelParseResultCosmeticRegular({
    required this.code,
    this.msg,
    required this.validRegular,
    required this.invalidRegular,
  });

  @override
  String toString() {
    return 'ExcelParseResultCosmeticRegular(Success Code: $code, Message: $msg, validRegular: $validRegular, invalidRegular: $invalidRegular)';
  }
}

class CosmeticsLabelRegular {
  final int index;
  final List<RegularItem> items;

  CosmeticsLabelRegular({
    required this.index,
    required this.items,
  });

  @override
  String toString() {
    return "CosmeticsLabelRegular(index: $index, items: $items)";
  }
}

class RegularItem {
  final String name;
  final double price;

  RegularItem({
    required this.name,
    required this.price,
  });

  @override
  String toString() {
    return "RegularItem(name: $name, Price: $price)";
  }
}

class CosmeticsLabelInvalidRegular {
  final int index;
  final List<InvalidCosmeticRegularItem> items;

  CosmeticsLabelInvalidRegular({required this.index, required this.items});

  @override
  String toString() {
    return 'CosmeticsLabelInvalidRegular(index: $index, items: $items)';
  }
}

class InvalidCosmeticRegularItem {
  final int row;
  final String name;
  final String regularPrice;
  final List<String> errors;

  InvalidCosmeticRegularItem({
    required this.row,
    required this.name,
    required this.regularPrice,
    required this.errors,
  });

  @override
  String toString() {
    return 'InvalidCosmeticRegularItem(row: $row, name: $name, regularPrice: $regularPrice, errors: $errors)';
  }
}