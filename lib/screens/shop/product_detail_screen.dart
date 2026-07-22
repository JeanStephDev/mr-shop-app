import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../models/product_variant.dart';
import '../../providers/cart_provider.dart';
import '../../services/admob_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    AdMobService.notifyProductViewed();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.priceFor(_selectedVariant);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.cream,
            foregroundColor: AppColors.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: product.image != null
                  ? Image.network(product.image!, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.peach, AppColors.orange])),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${price.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.orange, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  if (product.description != null) Text(product.description!, style: const TextStyle(color: AppColors.navySoft, height: 1.5)),

                  if (product.variants.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Choisir une option', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: product.variants.map((v) {
                        final selected = _selectedVariant?.id == v.id;
                        return ChoiceChip(
                          label: Text(v.name),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedVariant = v),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Quantité', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().add(product, variant: _selectedVariant, quantity: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajouté au panier ✅')));
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter au panier'),
          ),
        ),
      ),
    );
  }
}
