import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  final _dio = ApiClient().dio;

  Future<OrderModel> createOrder({
    required int addressId,
    required List<CartItem> items,
    required String paymentMethod, // 'mobile_money' | 'cash_on_delivery'
    String? promoCode,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/orders', data: {
        'address_id': addressId,
        'items': items.map((i) => i.toOrderPayload()).toList(),
        'payment_method': paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await _dio.get('/orders');
    final data = response.data['data'] as List;
    return data.map((o) => OrderModel.fromJson(o)).toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final response = await _dio.get('/orders/$id');
    return OrderModel.fromJson(response.data);
  }

  Future<void> cancelOrder(int id) async {
    try {
      await _dio.post('/orders/$id/cancel');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> submitReview(int orderId, {required int rating, String? comment}) async {
    try {
      await _dio.post('/orders/$orderId/review', data: {'rating': rating, 'comment': comment});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
