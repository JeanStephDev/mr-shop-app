import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.subtotal);

  void add(Product product, {ProductVariant? variant, int quantity = 1}) {
    final candidate = CartItem(product: product, variant: variant);
    final existingIndex = _items.indexWhere((i) => i.sameAs(candidate));

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      candidate.quantity = quantity;
      _items.add(candidate);
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      remove(item);
      return;
    }
    final index = _items.indexWhere((i) => i.sameAs(item));
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void remove(CartItem item) {
    _items.removeWhere((i) => i.sameAs(item));
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
