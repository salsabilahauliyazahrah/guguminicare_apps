// lib/core/models/pet_medical_note_model.dart
class PetMedicalNoteModel {
  final String id;
  final String petId;
  final String? special_condition;
  final String? current_medication;
  final String? grooming_behavior;
  final String created_at; // ✅ String, bukan DateTime

  PetMedicalNoteModel({
    required this.id,
    required this.petId,
    this.special_condition,
    this.current_medication,
    this.grooming_behavior,
    required this.created_at, // ✅ WAJIB String
  });

  factory PetMedicalNoteModel.fromJson(Map<String, dynamic> json) {
    return PetMedicalNoteModel(
      id: json['id']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? json['petId']?.toString() ?? '',
      special_condition: json['special_condition']?.toString(),
      current_medication: json['current_medication']?.toString(),
      grooming_behavior: json['grooming_behavior']?.toString(),
      created_at: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'special_condition': special_condition,
      'current_medication': current_medication,
      'grooming_behavior': grooming_behavior,
      'created_at': created_at,
    };
  }
}