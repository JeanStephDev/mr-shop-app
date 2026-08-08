import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/address.dart';
import '../models/city.dart';

class AddressService {
  final _dio = ApiClient().dio;

  Future<List<Address>> getAddresses() async {
    final response = await _dio.get('/addresses');
    return (response.data as List).map((a) => Address.fromJson(a)).toList();
  }

  Future<Address> addAddress({
    String? label,
    required String fullAddress,
    int? cityId,
    int? communeId,
    String? quartier,
    double? lat,
    double? lng,
    String? phoneContact,
    bool isDefault = false,
  }) async {
    try {
      final response = await _dio.post('/addresses', data: {
        'label': label,
        'full_address': fullAddress,
        'city_id': cityId,
        'commune_id': communeId,
        'quartier': quartier,
        'lat': lat,
        'lng': lng,
        'phone_contact': phoneContact,
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

  Future<List<City>> getCities() async {
    final response = await _dio.get('/cities');
    return (response.data as List).map((c) => City.fromJson(c)).toList();
  }

  Future<List<Commune>> getCommunes(int cityId) async {
    final response = await _dio.get('/communes', queryParameters: {'city_id': cityId});
    return (response.data as List).map((c) => Commune.fromJson(c)).toList();
  }
}
