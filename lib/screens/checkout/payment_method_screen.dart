import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/address.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import 'payment_webview_screen.dart';
import '../orders/order_tracking_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Address address;
  const PaymentMethodScreen({super.key, required this.address});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _method = 'mobile_money';
  bool _isPlacing = false;
  final _promoController = TextEditingController();

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    setState(() => _isPlacing = true);

    try {
      final order = await OrderService().createOrder(
        addressId: widget.address.id,
        items: cart.items,
        paymentMethod: _method,
        promoCode: _promoController.text.trim(),
      );

      cart.clear();
      if (!mounted) return;

      if (_method == 'mobile_money') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PaymentWebviewScreen(order: order)));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)),
          (r) => r.isFirst,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            RadioListTile(
              value: 'mobile_money',
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              title: const Text('Mobile Money (Wave, Orange, MTN, Moov)'),
              activeColor: AppColors.orange,
            ),
            RadioListTile(
              value: 'cash_on_delivery',
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              title: const Text('Paiement à la livraison'),
              activeColor: AppColors.orange,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promoController,
              decoration: const InputDecoration(hintText: 'Code promo (optionnel)'),
            ),
            const Spacer(),
            Text('Sous-total : ${cart.subtotal.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.navySoft)),
            const SizedBox(height: 4),
            const Text('Frais de livraison calculés à la validation', style: TextStyle(color: AppColors.navySoft, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : _placeOrder,
                child: _isPlacing ? const CircularProgressIndicator(color: Colors.white) : const Text('Valider la commande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
