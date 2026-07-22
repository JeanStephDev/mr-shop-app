class Address {
  final int id;
  final String? label;
  final String fullAddress;
  final double? lat;
  final double? lng;
  final bool isDefault;

  Address({required this.id, this.label, required this.fullAddress, this.lat, this.lng, this.isDefault = false});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        label: json['label'],
        fullAddress: json['full_address'],
        lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
        lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
        isDefault: json['is_default'] == true,
      );
}
