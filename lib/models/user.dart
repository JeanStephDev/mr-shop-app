class AppUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;

  AppUser({required this.id, required this.name, required this.phone, this.email, required this.role});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        role: json['role'] ?? 'client',
      );
}
