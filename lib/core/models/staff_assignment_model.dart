// lib/core/models/staff_assignments_model.dart
class StaffAssignmentsModel {
  final String id;
  final String staff_id;
  final String role; // 'admin','driver','manager','staff'
  final String assigned_by;
  final String status; // 'active','inactive','pending'
  final String created_at;

  StaffAssignmentsModel({
    required this.id,
    required this.staff_id,
    required this.role,
    required this.assigned_by,
    required this.status,
    required this.created_at,
  });

  // Factory method dengan null safety dan format GoCloud
  factory StaffAssignmentsModel.fromJson(Map<String, dynamic> data) {
    return StaffAssignmentsModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      staff_id: data['staff_id']?.toString() ?? '',
      role: data['role']?.toString() ?? 'staff',
      assigned_by: data['assigned_by']?.toString() ?? '',
      status: data['status']?.toString() ?? 'active',
      created_at: data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
    'staff_id': staff_id,
    'role': role,
    'assigned_by': assigned_by,
    'status': status,
    'created_at': created_at,
  };

  // Helper methods untuk UI convenience

  // Check jika status active
  bool get isActive => status == 'active';

  // Check jika status inactive
  bool get isInactive => status == 'inactive';

  // Check jika status pending
  bool get isPending => status == 'pending';

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

  // Get role label untuk display
  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'driver':
        return 'Driver';
      case 'manager':
        return 'Manager';
      case 'staff':
        return 'Staff';
      case 'groomer':
        return 'Groomer';
      case 'vet':
        return 'Veterinarian';
      default:
        return role;
    }
  }

  // Get status label untuk display
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      case 'pending':
        return 'Menunggu';
      case 'suspended':
        return 'Ditangguhkan';
      default:
        return status;
    }
  }

  // Get status color untuk UI
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'inactive':
        return '#F44336'; // Red
      case 'pending':
        return '#FF9800'; // Orange
      case 'suspended':
        return '#9E9E9E'; // Grey
      default:
        return '#607D8B'; // Blue Grey
    }
  }

  // Get role icon untuk UI
  String get roleIcon {
    switch (role.toLowerCase()) {
      case 'admin':
        return '👑';
      case 'driver':
        return '🚗';
      case 'manager':
        return '💼';
      case 'staff':
        return '👨‍💼';
      case 'groomer':
        return '✂️';
      case 'vet':
        return '🏥';
      default:
        return '👤';
    }
  }

  // Copy with method (tetap dalam format String)
  StaffAssignmentsModel copyWith({
    String? id,
    String? staff_id,
    String? role,
    String? assigned_by,
    String? status,
    String? created_at,
  }) {
    return StaffAssignmentsModel(
      id: id ?? this.id,
      staff_id: staff_id ?? this.staff_id,
      role: role ?? this.role,
      assigned_by: assigned_by ?? this.assigned_by,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
    );
  }

  // Method untuk activate staff
  StaffAssignmentsModel activate() {
    return copyWith(status: 'active');
  }

  // Method untuk deactivate staff
  StaffAssignmentsModel deactivate() {
    return copyWith(status: 'inactive');
  }

  // Method untuk suspend staff
  StaffAssignmentsModel suspend() {
    return copyWith(status: 'suspended');
  }

  // Method untuk update role
  StaffAssignmentsModel updateRole(String newRole) {
    return copyWith(role: newRole);
  }

  // Static method untuk create new staff assignment
  static StaffAssignmentsModel createNew({
    required String staff_id,
    required String role,
    required String assigned_by,
    String status = 'active',
  }) {
    return StaffAssignmentsModel(
      id: '', // Empty untuk insert baru
      staff_id: staff_id,
      role: role,
      assigned_by: assigned_by,
      status: status,
      created_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk validasi staff assignment
  bool get isValid {
    return staff_id.isNotEmpty &&
           role.isNotEmpty &&
           assigned_by.isNotEmpty &&
           status.isNotEmpty;
  }

  // Method untuk mendapatkan assignment details
  String get assignmentDetails {
    return '$roleLabel - $statusLabel (Ditugaskan oleh: $assigned_by)';
  }

  @override
  String toString() {
    return 'Staff $staff_id sebagai $roleLabel ($statusLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffAssignmentsModel &&
        other.id == id &&
        other.staff_id == staff_id &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ staff_id.hashCode ^ role.hashCode;
  }
}