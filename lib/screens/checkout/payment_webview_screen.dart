import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/order.dart';
import '../../services/payment_service.dart';
import '../orders/order_tracking_screen.dart';

/// Ouvre la page de paiement hébergée GeniusPay dans une WebView.
/// GeniusPay redirige vers `return_url` (configurée côté API) une fois le
/// paiement terminé -> on détecte cette redirection pour fermer la WebView
/// et aller vérifier le statut réel du paiement.
class PaymentWebviewScreen extends StatefulWidget {
  final OrderModel order;
  const PaymentWebviewScreen({super.key, required this.order});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (url.contains('/payment/return')) {
            _onPaymentReturned();
          }
        },
        onPageFinished: (_) => setState(() => _isLoading = false),
      ));
    _loadCheckout();
  }

  Future<void> _loadCheckout() async {
    try {
      final checkoutUrl = await PaymentService().initiatePayment(widget.order.id);
      _controller.loadRequest(Uri.parse(checkoutUrl));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        Navigator.of(context).pop();
      }
    }
  }

  void _onPaymentReturned() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: widget.order.id)),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement sécurisé')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
