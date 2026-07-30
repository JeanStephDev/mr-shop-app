import 'package:flutter/foundation.dart' hide Category;
import '../core/sample_data.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final _catalogService = CatalogService();

  List<Category> categories = [];
  List<Product> featuredProducts = [];
  List<Product> products = [];
  bool isLoading = false;
  bool isOffline = false;
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
      isOffline = false;
    } catch (_) {
      // API injoignable (serveur en panne, pas de réseau...) : on affiche
      // des exemples plutôt qu'un écran vide, avec un bandeau "hors ligne".
      categories = SampleData.categories;
      featuredProducts = SampleData.products.where((p) => p.isFeatured).toList();
      isOffline = true;
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
      isOffline = false;
    } catch (_) {
      products = SampleData.products;
      isOffline = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
