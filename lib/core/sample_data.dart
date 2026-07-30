import '../models/category.dart';
import '../models/product.dart';

/// Données de secours affichées si l'API est injoignable (VPS en panne,
/// pas de réseau...) — évite un écran vide et permet de continuer à
/// montrer/tester l'app. Utilisé par CatalogProvider en cas d'échec réseau.
/// Jamais utilisé si le vrai serveur répond normalement.
class SampleData {
  static List<Category> get categories => [
        Category(id: 1, name: 'Parfums', slug: 'parfums', icon: null),
        Category(id: 2, name: 'Accessoires', slug: 'accessoires', icon: null),
        Category(id: 3, name: 'Sacs', slug: 'sacs', icon: null),
      ];

  static List<Product> get products => [
        Product(id: 1, name: 'Éclat de Cocody', slug: 'eclat-de-cocody', description: 'Un parfum floral et boisé, frais et élégant.', basePrice: 15000, stock: 10, isFeatured: true),
        Product(id: 2, name: 'Nuit de Plateau', slug: 'nuit-de-plateau', description: 'Notes ambrées et musquées pour le soir.', basePrice: 18000, stock: 8, isFeatured: true),
        Product(id: 3, name: 'Brise de Marcory', slug: 'brise-de-marcory', description: 'Agrumes frais, parfait pour la journée.', basePrice: 14000, stock: 12, isFeatured: true),
        Product(id: 4, name: 'Sac By Elo', slug: 'sac-by-elo', description: 'Sac à main élégant, cuir vegan.', basePrice: 25000, stock: 5, isFeatured: false),
      ];
}
