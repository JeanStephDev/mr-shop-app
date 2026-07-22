import 'product.dart';
import 'product_variant.dart';

/// Le panier vit uniquement côté app (pas de synchro serveur tant que la
/// commande n'est pas validée) — cohérent avec l'API (POST /orders envoie
/// directement le panier complet).
class CartItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  CartItem({required this.product, this.variant, this.quantity = 1});

  double get unitPrice => product.priceFor(variant);
  double get subtotal => unitPrice * quantity;

  String get displayName => variant != null ? '${product.name} (${variant!.name})' : product.name;

  Map<String, dynamic> toOrderPayload() => {
        'product_id': product.id,
        if (variant != null) 'variant_id': variant!.id,
        'quantity': quantity,
      };

  // Deux lignes de panier sont "identiques" si même produit + même variante
  bool sameAs(CartItem other) => product.id == other.product.id && variant?.id == other.variant?.id;
}
