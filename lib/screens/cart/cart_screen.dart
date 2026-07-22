import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/cart_provider.dart';
import '../checkout/address_list_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(alignment: Alignment.centerLeft, child: Text('Votre panier', style: Theme.of(context).textTheme.headlineSmall)),
          ),
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('Votre panier est vide', style: TextStyle(color: AppColors.navySoft)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(colors: [AppColors.peach, AppColors.orange]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('${item.unitPrice.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(onPressed: () => cart.updateQuantity(item, item.quantity - 1), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                IconButton(onPressed: () => cart.updateQuantity(item, item.quantity + 1), icon: const Icon(Icons.add_circle_outline, size: 20)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (!cart.isEmpty)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _summaryRow('Sous-total', '${cart.subtotal.toStringAsFixed(0)} FCFA'),
                  const SizedBox(height: 6),
                  const Text('Les frais de livraison seront calculés à l\'étape suivante', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressListScreen())),
                      child: const Text('Passer la commande →'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      );
}
