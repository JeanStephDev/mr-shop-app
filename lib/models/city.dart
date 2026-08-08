class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) => City(id: json['id'], name: json['name']);
}

class Commune {
  final int id;
  final String name;

  Commune({required this.id, required this.name});

  factory Commune.fromJson(Map<String, dynamic> json) => Commune(id: json['id'], name: json['name']);
}
