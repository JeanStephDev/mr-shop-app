import 'package:dio/dio.dart';
import '../core/api_client.dart';

class PaymentService {
  final _dio = ApiClient().dio;

  /// Lance le paiement GeniusPay pour une commande et renvoie l'URL de checkout
  /// à ouvrir dans la WebView (voir screens/checkout/payment_webview_screen.dart).
  Future<String> initiatePayment(int orderId) async {
    try {
      final response = await _dio.post('/orders/$orderId/pay');
      final url = response.data['checkout_url'];
      if (url == null) throw ApiException('Impossible de démarrer le paiement.');
      return url;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> checkPaymentStatus(int orderId) async {
    final response = await _dio.get('/orders/$orderId/payment-status');
    return response.data['payment_status'];
  }
}
