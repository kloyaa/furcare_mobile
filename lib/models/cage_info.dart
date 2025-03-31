class Cage {
  final String id;
  final String title;
  final double price;
  final int used;
  final int limit;
  final bool available;

  Cage({
    required this.id,
    required this.title,
    required this.price,
    required this.used,
    required this.limit,
    required this.available,
  });

  // Factory constructor to create a Cage from JSON
  factory Cage.fromJson(Map<String, dynamic> json) {
    return Cage(
      id: json['_id'] as String,
      title: json['title'] as String,
      price:
          json['price'] is int
              ? (json['price'] as int).toDouble()
              : json['price'] as double,
      used: json['used'] as int,
      limit: json['limit'] as int,
      available: json['available'] as bool,
    );
  }

  // Method to convert Cage to JSON
  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'price': price,
    'used': used,
    'limit': limit,
    'available': available,
  };
}
