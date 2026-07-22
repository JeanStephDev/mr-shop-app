import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/address.dart';

class AddressService {
  final _dio = ApiClient().dio;

  Future<List<Address>> getAddresses() async {
    final response = await _dio.get('/addresses');
    return (response.data as List).map((a) => Address.fromJson(a)).toList();
  }

  Future<Address> addAddress({
    String? label,
    required String fullAddress,
    double? lat,
    double? lng,
    bool isDefault = false,
  }) async {
    try {
      final response = await _dio.post('/addresses', data: {
        'label': label,
        'full_address': fullAddress,
        'lat': lat,
        'lng': lng,
        'is_default': isDefault,
      });
      return Address.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteAddress(int id) async {
    await _dio.delete('/addresses/$id');
  }
}
