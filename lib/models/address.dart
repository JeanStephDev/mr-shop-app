class Address {
  final int id;
  final String? label;
  final String fullAddress;
  final int? cityId;
  final String? cityName;
  final int? communeId;
  final String? communeName;
  final String? quartier;
  final double? lat;
  final double? lng;
  final String? phoneContact;
  final bool isDefault;

  Address({
    required this.id,
    this.label,
    required this.fullAddress,
    this.cityId,
    this.cityName,
    this.communeId,
    this.communeName,
    this.quartier,
    this.lat,
    this.lng,
    this.phoneContact,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        label: json['label'],
        fullAddress: json['full_address'],
        cityId: json['city_id'],
        cityName: json['city']?['name'],
        communeId: json['commune_id'],
        communeName: json['commune']?['name'],
        quartier: json['quartier'],
        lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
        lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
        phoneContact: json['phone_contact'],
        isDefault: json['is_default'] == true,
      );

  String get shortSummary {
    final parts = [quartier, communeName, cityName].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? fullAddress : parts.join(', ');
  }
}
