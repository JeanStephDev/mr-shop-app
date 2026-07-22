import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/category.dart';
import '../models/product.dart';

class CatalogService {
  final _dio = ApiClient().dio;

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    return (response.data as List).map((c) => Category.fromJson(c)).toList();
  }

  Future<List<Product>> getProducts({int? categoryId, String? search, bool? featured}) async {
    final response = await _dio.get('/products', queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      if (search != null) 'search': search,
      if (featured == true) 'featured': true,
    });
    final data = response.data['data'] as List; // pagination Laravel
    return data.map((p) => Product.fromJson(p)).toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data);
  }
}
