// lib/core/models/review_model.dart
class ReviewModel {
  final String id;
  final String booking_id;
  final String user_id;
  final String rating; // ✅ String bukan int
  final String comment;
  final String is_responded; // ✅ String bukan bool
  final String response_admin;
  final String response_date; // ✅ String bukan DateTime
  final String created_at; // ✅ String bukan DateTime

  ReviewModel({
    required this.id,
    required this.booking_id,
    required this.user_id,
    required this.rating,
    required this.comment,
    required this.is_responded,
    required this.response_admin,
    required this.response_date,
    required this.created_at,
  });

  // Factory method dengan null safety dan format GoCloud
  factory ReviewModel.fromJson(Map<String, dynamic> data) {
    return ReviewModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      booking_id: data['booking_id']?.toString() ?? '',
      user_id: data['user_id']?.toString() ?? '',
      rating: data['rating']?.toString() ?? '0',
      comment: data['comment']?.toString() ?? '',
      is_responded: data['is_responded']?.toString() ?? '0',
      response_admin: data['response_admin']?.toString() ?? '',
      response_date: data['response_date']?.toString() ?? '',
      created_at: data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
    'booking_id': booking_id,
    'user_id': user_id,
    'rating': rating,
    'comment': comment,
    'is_responded': is_responded,
    'response_admin': response_admin,
    'response_date': response_date,
    'created_at': created_at,
  };

  // Helper methods untuk UI convenience

  // Konversi rating ke int
  int get ratingInt {
    try {
      return int.parse(rating);
    } catch (e) {
      return 0;
    }
  }

  // Konversi rating ke double
  double get ratingDouble {
    try {
      return double.parse(rating);
    } catch (e) {
      return 0.0;
    }
  }

  // Cek apakah sudah direspons
  bool get isRespondedBool => is_responded == '1' || is_responded == 'true';

  // Konversi response_date ke DateTime
  DateTime? get responseDateOrNull {
    try {
      return DateTime.parse(response_date);
    } catch (e) {
      return null;
    }
  }

  // Konversi created_at ke DateTime
  DateTime? get createdAtOrNull {
    try {
      return DateTime.parse(created_at);
    } catch (e) {
      return null;
    }
  }

  // Formatted date untuk display
  String get formattedDate {
    final date = createdAtOrNull;
    if (date == null) return '';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  // Formatted response date untuk display
  String get formattedResponseDate {
    if (response_admin.isEmpty) return '';
    
    final date = responseDateOrNull;
    if (date == null) return response_date;
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  // Get stars untuk UI rating display
  List<bool> get starRating {
    final ratingValue = ratingInt;
    return [
      ratingValue >= 1,
      ratingValue >= 2,
      ratingValue >= 3,
      ratingValue >= 4,
      ratingValue >= 5,
    ];
  }

  // Check if review has admin response
  bool get hasAdminResponse {
    return isRespondedBool && response_admin.isNotEmpty;
  }

  // Short comment preview (untuk list view)
  String get commentPreview {
    if (comment.length <= 100) return comment;
    return '${comment.substring(0, 100)}...';
  }

  // Copy with method (tetap dalam format String)
  ReviewModel copyWith({
    String? id,
    String? booking_id,
    String? user_id,
    String? rating,
    String? comment,
    String? is_responded,
    String? response_admin,
    String? response_date,
    String? created_at,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      booking_id: booking_id ?? this.booking_id,
      user_id: user_id ?? this.user_id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      is_responded: is_responded ?? this.is_responded,
      response_admin: response_admin ?? this.response_admin,
      response_date: response_date ?? this.response_date,
      created_at: created_at ?? this.created_at,
    );
  }

  // Method untuk add admin response
  ReviewModel addAdminResponse({
    required String adminResponse,
    required String adminName,
  }) {
    return copyWith(
      is_responded: '1',
      response_admin: '$adminName: $adminResponse',
      response_date: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk update rating
  ReviewModel updateRating(String newRating) {
    return copyWith(rating: newRating);
  }

  // Method untuk update comment
  ReviewModel updateComment(String newComment) {
    return copyWith(comment: newComment);
  }

  // Static method untuk create new review
  static ReviewModel createNew({
    required String booking_id,
    required String user_id,
    required String rating,
    required String comment,
  }) {
    return ReviewModel(
      id: '', // Empty untuk insert baru
      booking_id: booking_id,
      user_id: user_id,
      rating: rating,
      comment: comment,
      is_responded: '0', // Default belum direspons
      response_admin: '',
      response_date: '',
      created_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk validasi review
  bool get isValid {
    return booking_id.isNotEmpty &&
           user_id.isNotEmpty &&
           rating.isNotEmpty &&
           comment.isNotEmpty;
  }

  // Method untuk cek jika review kosong
  bool get isEmpty {
    return comment.isEmpty && rating == '0';
  }

  // Get rating color based on value
  String get ratingColor {
    final ratingValue = ratingDouble;
    if (ratingValue >= 4.5) return '#4CAF50'; // Green
    if (ratingValue >= 3.5) return '#8BC34A'; // Light Green
    if (ratingValue >= 2.5) return '#FFC107'; // Amber
    if (ratingValue >= 1.5) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  // Get rating label
  String get ratingLabel {
    final ratingValue = ratingDouble;
    if (ratingValue >= 4.5) return 'Sangat Baik';
    if (ratingValue >= 3.5) return 'Baik';
    if (ratingValue >= 2.5) return 'Cukup';
    if (ratingValue >= 1.5) return 'Kurang';
    return 'Buruk';
  }

  @override
  String toString() {
    return 'Review: $rating stars - $commentPreview';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel &&
        other.id == id &&
        other.booking_id == booking_id &&
        other.user_id == user_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^ booking_id.hashCode ^ user_id.hashCode;
  }
}