class PetModel {
  final String id;
  final String user_id;
  final String name;
  final String type;
  final String? breed;
  final String? age; // ✅ Tetap sebagai String
  final String? weight;
  final String? photo;
  final String? is_safe;
  final String? last_grooming;
  final String created_at;

  PetModel({
    required this.id,
    required this.user_id,
    required this.name,
    required this.type,
    this.breed,
    this.age,
    this.weight,
    this.photo,
    this.is_safe = 'true',
    this.last_grooming,
    required this.created_at,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    // Parse is_safe ke String
    String? isSafeValue;
    if (json['is_safe'] is String) {
      isSafeValue = json['is_safe'];
    } else if (json['is_safe'] is bool) {
      isSafeValue = json['is_safe'].toString();
    } else {
      isSafeValue = 'true';
    }

    return PetModel(
      id: json['id']?.toString() ?? '',
      user_id: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'],
      age: json['age'] is String
          ? json['age']
          : json['age'] is num
              ? json['age'].toString()
              : null,
      weight: json['weight'] is String
          ? json['weight']
          : json['weight'] is num
              ? json['weight'].toString()
              : null,
      photo: json['photo'],
      is_safe: isSafeValue,
      last_grooming: json['last_grooming']?.toString(),
      created_at:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age?.toString(),
      'weight': weight?.toString(),
      'photo': photo,
      'is_safe': is_safe.toString(),
      'last_grooming': last_grooming,
      'created_at': created_at,
    };
  }

  PetModel copyWith({
    String? id,
    String? user_id,
    String? name,
    String? type,
    String? breed,
    String? age,
    String? weight,
    String? photo,
    bool? is_safe,
    String? last_grooming,
    String? created_at,
  }) {
    return PetModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      photo: photo ?? this.photo,
      is_safe: is_safe?.toString() ?? this.is_safe,
      last_grooming: last_grooming ?? this.last_grooming,
      created_at: created_at ?? this.created_at,
    );
  }
}
