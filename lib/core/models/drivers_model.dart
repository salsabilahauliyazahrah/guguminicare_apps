// lib/core/models/driver_data_model.dart
class DriverDataModel {
  final String id;
  final String name;
  final String completed; // ✅ String bukan int
  final String rating;    // ✅ String bukan double
  final String revenue;   // ✅ String bukan int

  DriverDataModel({
    required this.id,
    required this.name,
    required this.completed,
    required this.rating,
    required this.revenue,
  });

  // Factory method dengan null safety dan format GoCloud
  factory DriverDataModel.fromJson(Map<String, dynamic> data) {
    return DriverDataModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      completed: data['completed']?.toString() ?? '0',
      rating: data['rating']?.toString() ?? '0',
      revenue: data['revenue']?.toString() ?? '0',
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
    'name': name,
    'completed': completed,
    'rating': rating,
    'revenue': revenue,
  };

  // Helper methods untuk UI convenience

  // Konversi completed ke int
  int get completedInt {
    try {
      return int.parse(completed);
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

  // Konversi revenue ke int
  int get revenueInt {
    try {
      return int.parse(revenue);
    } catch (e) {
      return 0;
    }
  }

  // Konversi revenue ke formatted currency
  String get revenueFormatted {
    try {
      final revenueValue = int.parse(revenue);
      return _formatCurrency(revenueValue);
    } catch (e) {
      return 'Rp 0';
    }
  }

  // Format rating dengan 1 desimal
  String get ratingFormatted {
    try {
      final ratingValue = double.parse(rating);
      return ratingValue.toStringAsFixed(1);
    } catch (e) {
      return '0.0';
    }
  }

  // Get stars untuk UI rating display
  List<bool> get starRating {
    final ratingValue = ratingDouble;
    return [
      ratingValue >= 1,
      ratingValue >= 2,
      ratingValue >= 3,
      ratingValue >= 4,
      ratingValue >= 5,
    ];
  }

  // Get performance level berdasarkan rating
  String get performanceLevel {
    final ratingValue = ratingDouble;
    if (ratingValue >= 4.5) return 'Excellent';
    if (ratingValue >= 4.0) return 'Very Good';
    if (ratingValue >= 3.5) return 'Good';
    if (ratingValue >= 3.0) return 'Average';
    return 'Below Average';
  }

  // Get performance color
  String get performanceColor {
    final ratingValue = ratingDouble;
    if (ratingValue >= 4.5) return '#4CAF50'; // Green
    if (ratingValue >= 4.0) return '#8BC34A'; // Light Green
    if (ratingValue >= 3.5) return '#FFC107'; // Amber
    if (ratingValue >= 3.0) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  // Copy with method (tetap dalam format String)
  DriverDataModel copyWith({
    String? id,
    String? name,
    String? completed,
    String? rating,
    String? revenue,
  }) {
    return DriverDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
      rating: rating ?? this.rating,
      revenue: revenue ?? this.revenue,
    );
  }

  // Method untuk increment completed jobs
  DriverDataModel incrementCompleted() {
    final newCompleted = (completedInt + 1).toString();
    return copyWith(completed: newCompleted);
  }

  // Method untuk update rating
  DriverDataModel updateRating(String newRating) {
    return copyWith(rating: newRating);
  }

  // Method untuk add revenue
  DriverDataModel addRevenue(int amount) {
    final newRevenue = (revenueInt + amount).toString();
    return copyWith(revenue: newRevenue);
  }

  // Static method untuk create new driver data
  static DriverDataModel createNew({
    required String name,
    String completed = '0',
    String rating = '0',
    String revenue = '0',
  }) {
    return DriverDataModel(
      id: '', // Empty untuk insert baru
      name: name,
      completed: completed,
      rating: rating,
      revenue: revenue,
    );
  }

  // Method untuk validasi driver data
  bool get isValid {
    return name.isNotEmpty;
  }

  // Method untuk mendapatkan revenue per job
  double get revenuePerJob {
    final jobs = completedInt;
    if (jobs == 0) return 0.0;
    return revenueInt / jobs;
  }

  // Private helper method untuk format currency
  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return 'Rp $amount';
  }

  @override
  String toString() {
    return '$name: $completed jobs, $ratingFormatted★, $revenueFormatted';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverDataModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}