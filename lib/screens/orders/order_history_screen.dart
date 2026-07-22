import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _orders = await _orderService.getMyOrders();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(alignment: Alignment.centerLeft, child: Text('Mes commandes', style: Theme.of(context).textTheme.headlineSmall)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text('Aucune commande pour le moment', style: TextStyle(color: AppColors.navySoft)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _orders.length,
                          itemBuilder: (context, i) {
                            final order = _orders[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text('${order.total.toStringAsFixed(0)} FCFA · ${order.status}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id))),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
