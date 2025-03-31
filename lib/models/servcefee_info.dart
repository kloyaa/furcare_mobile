import 'dart:convert';

class ServiceFee {
  final String id;
  final double fee;
  final String title;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceFee({
    required this.id,
    required this.fee,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Service from JSON
  factory ServiceFee.fromJson(Map<String, dynamic> json) {
    return ServiceFee(
      id: json['_id'] as String,
      fee:
          json['fee'] is int
              ? (json['fee'] as int).toDouble()
              : json['fee'] as double,
      title: json['title'] as String,
      version: json['__v'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Static method to create a list of ServiceFee objects from JSON array
  static List<ServiceFee> fromJsonList(dynamic jsonData) {
    if (jsonData == null) {
      return [];
    }

    // If jsonData is already a List
    if (jsonData is List) {
      return jsonData
          .map((item) => ServiceFee.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // If jsonData is a String that needs to be parsed
    if (jsonData is String) {
      try {
        final List<dynamic> parsed = jsonDecode(jsonData);
        return parsed
            .map((item) => ServiceFee.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing JSON string: $e');
        return [];
      }
    }

    return [];
  }

  // Method to convert Service to JSON
  Map<String, dynamic> toJson() => {
    '_id': id,
    'fee': fee,
    'title': title,
    '__v': version,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
