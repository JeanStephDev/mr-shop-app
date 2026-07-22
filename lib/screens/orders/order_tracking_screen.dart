import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/review_dialog.dart';

const _statusLabels = {
  'pending': 'En attente de validation',
  'accepted': 'Acceptée',
  'preparing': 'En préparation',
  'courier_assigned': 'Livreur assigné',
  'picked_up': 'Récupérée par le livreur',
  'on_the_way': 'En route vers vous',
  'delivered': 'Livrée',
  'rejected': 'Refusée',
  'cancelled': 'Annulée',
};

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _orderService = OrderService();
  OrderModel? _order;
  Timer? _pollTimer;
  bool _reviewPromptShown = false;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final order = await _orderService.getOrder(widget.orderId);
    if (!mounted) return;
    setState(() => _order = order);

    // Propose l'avis automatiquement une seule fois par ouverture d'écran,
    // dès qu'on détecte que la commande est livrée et sans avis existant.
    if (order.status == 'delivered' && !order.hasReview && !_reviewPromptShown) {
      _reviewPromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => showReviewDialog(context, order.id).then((_) => _load()));
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Oui, annuler')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.cancelOrder(widget.orderId);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final canCancel = order != null && ['pending', 'accepted'].contains(order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(order != null ? 'Commande ${order.orderNumber}' : 'Commande'),
        actions: [
          if (canCancel) TextButton(onPressed: _cancelOrder, child: const Text('Annuler', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
      body: order == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(_statusLabels[order.status] ?? order.status, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),

                if (!['rejected', 'cancelled'].contains(order.status))
                  ...OrderModel.statusFlow.asMap().entries.map((entry) {
                    final index = entry.key;
                    final status = entry.value;
                    final isDone = order.currentStepIndex >= 0 && index <= order.currentStepIndex;
                    final isCurrent = index == order.currentStepIndex;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isDone ? AppColors.orange : AppColors.peachLight,
                              child: Icon(isDone ? Icons.check : Icons.circle, size: 14, color: isDone ? Colors.white : AppColors.navySoft),
                            ),
                            if (index < OrderModel.statusFlow.length - 1)
                              Container(width: 2, height: 40, color: isDone ? AppColors.orange : Colors.grey.shade300),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _statusLabels[status] ?? status,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isDone ? AppColors.navy : AppColors.navySoft,
                            ),
                          ),
                        ),
                      ],
                    );
                  })
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      order.status == 'cancelled' ? 'Vous avez annulé cette commande.' : 'Cette commande a été refusée par la boutique.',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),

                if (order.courierName != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: AppColors.navy, child: Icon(Icons.delivery_dining, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(order.courierName!, style: const TextStyle(fontWeight: FontWeight.w700))),
                        if (order.courierPhone != null)
                          IconButton(
                            icon: const CircleAvatar(backgroundColor: AppColors.peachLight, child: Icon(Icons.phone, color: AppColors.orange, size: 18)),
                            onPressed: () => launchUrl(Uri.parse('tel:${order.courierPhone}')),
                          ),
                      ],
                    ),
                  ),
                ],

                if (order.status == 'delivered') ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => showReviewDialog(context, order.id).then((_) => _load()),
                    icon: Icon(order.hasReview ? Icons.star : Icons.star_border, color: AppColors.yellow),
                    label: Text(order.hasReview ? 'Avis envoyé — modifier' : 'Laisser un avis'),
                  ),
                ],

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _row('Sous-total', order.subtotal),
                      _row('Livraison', order.deliveryFee),
                      if (order.discount > 0) _row('Réduction', -order.discount),
                      const Divider(color: Colors.white24),
                      _row('Total', order.total, bold: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: bold ? Colors.white : Colors.white70, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
            Text('${value.toStringAsFixed(0)} FCFA', style: TextStyle(color: bold ? AppColors.yellow : Colors.white, fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
          ],
        ),
      );
}
