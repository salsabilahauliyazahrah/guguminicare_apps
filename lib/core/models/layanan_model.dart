// lib/core/models/layanan_model.dart

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String duration;
  final String category;
  final String icon;
  final String color;
  final String details;
  final String benefits;
  final String suitable_for;
  final String is_active;
  final String created_at;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    required this.icon,
    required this.color,
    required this.details,
    required this.benefits,
    required this.suitable_for,
    required this.is_active,
    required this.created_at,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> data) {
    return ServiceModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price']?.toString() ?? '0',
      duration: data['duration']?.toString() ?? '0',
      category: data['category']?.toString() ?? 'grooming',
      icon: data['icon']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      details: data['details']?.toString() ?? '',
      benefits: data['benefits']?.toString() ?? '',
      suitable_for: data['suitable_for']?.toString() ?? '',
      is_active: data['is_active']?.toString() ?? '1',
      created_at: data['created_at']?.toString() ?? 
                DateTime.now().toIso8601String().split('.')[0], // Format tanpa milidetik
    );
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration': duration,
        'category': category,
        'icon': icon,
        'color': color,
        'details': details,
        'benefits': benefits,
        'suitable_for': suitable_for,
        'is_active': is_active,
        'created_at': created_at,
      };

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? duration,
    String? category,
    String? icon,
    String? color,
    String? details,
    String? benefits,
    String? suitable_for,
    String? is_active,
    String? created_at,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      details: details ?? this.details,
      benefits: benefits ?? this.benefits,
      suitable_for: suitable_for ?? this.suitable_for,
      is_active: is_active ?? this.is_active,
      created_at: created_at ?? this.created_at,
    );
  }
}