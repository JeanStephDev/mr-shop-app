import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/address.dart';
import '../../providers/auth_provider.dart';
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
  bool _isRecipientMe = true;
  final _promoController = TextEditingController();
  final _recipientPhoneController = TextEditingController();

  Future<void> _placeOrder() async {
    if (!_isRecipientMe && _recipientPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez le numéro de la personne qui reçoit')));
      return;
    }

    final cart = context.read<CartProvider>();
    setState(() => _isPlacing = true);

    try {
      final order = await OrderService().createOrder(
        addressId: widget.address.id,
        items: cart.items,
        paymentMethod: _method,
        promoCode: _promoController.text.trim(),
        // Ne modifie jamais le numéro du compte — seulement le contact pour
        // CETTE commande. Vide = l'API utilise le numéro habituel par défaut.
        recipientPhone: _isRecipientMe ? null : _recipientPhoneController.text.trim(),
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
    final myPhone = context.watch<AuthProvider>().user?.phone;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: SingleChildScrollView(
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

            const SizedBox(height: 20),
            const Text('Qui réceptionne la commande ?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            if (myPhone != null)
              Text('Votre numéro de compte : $myPhone', style: const TextStyle(color: AppColors.navySoft, fontSize: 12)),
            const SizedBox(height: 8),
            RadioListTile(
              value: true,
              groupValue: _isRecipientMe,
              onChanged: (v) => setState(() => _isRecipientMe = v!),
              title: const Text('C\'est moi qui réceptionne'),
              activeColor: AppColors.orange,
            ),
            RadioListTile(
              value: false,
              groupValue: _isRecipientMe,
              onChanged: (v) => setState(() => _isRecipientMe = v!),
              title: const Text('Quelqu\'un d\'autre réceptionne'),
              activeColor: AppColors.orange,
            ),
            if (!_isRecipientMe)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: TextField(
                  controller: _recipientPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Numéro du destinataire pour cette commande'),
                ),
              ),

            const SizedBox(height: 16),
            TextField(
              controller: _promoController,
              decoration: const InputDecoration(hintText: 'Code promo (optionnel)'),
            ),
            const SizedBox(height: 20),
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
