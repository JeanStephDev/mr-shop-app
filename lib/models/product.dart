import 'product_variant.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double basePrice;
  final String? image;
  final int stock;
  final bool isFeatured;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.basePrice,
    this.image,
    required this.stock,
    required this.isFeatured,
    this.variants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        description: json['description'],
        basePrice: double.parse(json['base_price'].toString()),
        image: json['image_url'],
        stock: json['stock'] ?? 0,
        isFeatured: json['is_featured'] == true,
        variants: (json['variants'] as List? ?? []).map((v) => ProductVariant.fromJson(v)).toList(),
      );

  double priceFor(ProductVariant? variant) => variant?.price ?? basePrice;
}
