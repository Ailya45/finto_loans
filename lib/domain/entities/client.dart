class Client {
  final int? id;
  final String name;
  final String? cedula;
  final String? phone;
  final DateTime createdAt;

  Client({this.id, required this.name, this.phone, required this.createdAt, this.cedula});

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      cedula: map['cedula'] as String?,
      phone: map['phone'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cedula': cedula,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    DateTime? createdAt,
    String? cedula,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      cedula: cedula ?? this.cedula,
    );
  }
}
