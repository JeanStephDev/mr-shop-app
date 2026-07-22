class Ad {
  final int id;
  final String type;
  final String? title;
  final String image;
  final String? linkUrl;

  Ad({required this.id, required this.type, this.title, required this.image, this.linkUrl});

  factory Ad.fromJson(Map<String, dynamic> json) => Ad(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        image: json['image'],
        linkUrl: json['link_url'],
      );
}
