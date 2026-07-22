class ProductVariant {
  final int id;
  final String name;
  final double price;
  final int stock;

  ProductVariant({required this.id, required this.name, required this.price, required this.stock});

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'],
        name: json['name'],
        price: double.parse(json['price'].toString()),
        stock: json['stock'] ?? 0,
      );
}
