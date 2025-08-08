class WasteCategory {
  final String id;
  final String name;
  final double pricePerGram;

  WasteCategory({required this.id, required this.name, required this.pricePerGram});

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'],
      name: json['name'],
      pricePerGram: (json['price_per_gram'] as num).toDouble(),
    );
  }
}