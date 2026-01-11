// lib/core/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String password;  // ✅ Sesuai gocloud (bukan passwordHash)
  final String name;
  final String phone;  // ✅ Sesuai gocloud (bukan nullable)
  final String role;
  final String birth_date;
  final String gender;
  final String profile_picture;
  final String salon_code;
  final String salon_name;
  final String salon_id;
  final String created_at;
  final String status;  // ✅ Untuk driver status (active, inactive, on_delivery)

  UserModel({
    required this.id,
    required this.email,
    required this.password,  // ✅
    required this.name,
    required this.phone,  // ✅
    required this.role,
    required this.birth_date,
    required this.gender,
    required this.profile_picture,
    required this.salon_code,
    required this.salon_name,
    required this.salon_id,
    required this.created_at,
    this.status = 'active',  // ✅ Default status
  });

  // Factory untuk parse dari database (gocloud)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      birth_date: json['birth_date']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      profile_picture: json['profile_picture']?.toString() ?? '',
      salon_code: json['salon_code']?.toString() ?? '',
      salon_name: json['salon_name']?.toString() ?? '',
      salon_id: json['salon_id']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      status: json['status']?.toString() ?? 'active',
    );
  }

  // Convert ke Map untuk database
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
      'birth_date': birth_date,
      'gender': gender,
      'profile_picture': profile_picture,
      'salon_code': salon_code,
      'salon_name': salon_name,
      'salon_id': salon_id,
      'created_at': created_at,
      'status': status,
    };
  }

  // Helper untuk UI (optional fields)
  String? get phoneOrNull => phone.isEmpty ? null : phone;
  DateTime? get birthDateOrNull => birth_date.isEmpty ? null : DateTime.tryParse(birth_date);
  DateTime? get createdAtOrNull => created_at.isEmpty ? null : DateTime.tryParse(created_at);

  // CopyWith method (tetap snake_case)
  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? phone,
    String? role,
    String? birth_date,
    String? gender,
    String? profile_picture,
    String? salon_code,
    String? salon_name,
    String? salon_id,
    String? created_at,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      birth_date: birth_date ?? this.birth_date,
      gender: gender ?? this.gender,
      profile_picture: profile_picture ?? this.profile_picture,
      salon_code: salon_code ?? this.salon_code,
      salon_name: salon_name ?? this.salon_name,
      salon_id: salon_id ?? this.salon_id,
      created_at: created_at ?? this.created_at,
      status: status ?? this.status,
    );
  }
}