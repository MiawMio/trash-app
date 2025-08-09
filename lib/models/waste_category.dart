class WasteCategory {
  final String id;
  final String name;
  final num price;
  final String unit;

  WasteCategory({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    num priceValue = 0;
    String unitValue = 'gram';

    // Cek apakah ada harga per kilogram, jika tidak, cari harga per gram
    if (json['price_per_kilogram'] != null) {
      priceValue = json['price_per_kilogram'];
      unitValue = 'kg';
    } else if (json['price_per_gram'] != null) {
      priceValue = json['price_per_gram'];
      unitValue = 'gram';
    }

    return WasteCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      price: priceValue,
      unit: unitValue,
    );
  }
}