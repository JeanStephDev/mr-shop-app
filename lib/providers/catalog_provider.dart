import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final _catalogService = CatalogService();

  List<Category> categories = [];
  List<Product> featuredProducts = [];
  List<Product> products = [];
  bool isLoading = false;
  int? selectedCategoryId;

  Future<void> loadHome() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _catalogService.getCategories(),
        _catalogService.getProducts(featured: true),
      ]);
      categories = results[0] as List<Category>;
      featuredProducts = results[1] as List<Product>;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({int? categoryId, String? search}) async {
    isLoading = true;
    selectedCategoryId = categoryId;
    notifyListeners();
    try {
      products = await _catalogService.getProducts(categoryId: categoryId, search: search);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
