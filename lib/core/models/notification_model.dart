// lib/core/models/notification_model.dart

import 'dart:convert';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String user_id;
  final String title;
  final String message;
  final String type; // 'booking','promo','reminder','service','system'
  final String icon;
  final String color;
  final String is_read; // ✅ String bukan bool
  final String metadata; // ✅ String bukan Map
  final String created_at; // ✅ String bukan DateTime

  NotificationModel({
    required this.id,
    required this.user_id,
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    required this.color,
    required this.is_read,
    required this.metadata,
    required this.created_at,
  });

  // Factory method dengan null safety dan format GoCloud
  factory NotificationModel.fromJson(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      user_id: data['user_id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'system',
      icon: data['icon']?.toString() ?? '',
      color: data['color']?.toString() ?? '#4FC3F7', // Default blue
      is_read: data['is_read']?.toString() ?? '0', // '1' untuk true, '0' untuk false
      metadata: data['metadata']?.toString() ?? '',
      created_at: data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
    'user_id': user_id,
    'title': title,
    'message': message,
    'type': type,
    'icon': icon,
    'color': color,
    'is_read': is_read,
    'metadata': metadata,
    'created_at': created_at,
  };

  // Helper methods untuk UI convenience

  // Konversi is_read ke bool
  bool get isReadBool => is_read == '1' || is_read == 'true';

  // Konversi metadata dari String ke Map (jika berupa JSON)
  Map<String, dynamic>? get metadataMap {
    if (metadata.isEmpty) return null;
    try {
      return json.decode(metadata);
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
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    }
  }

  // Get icon berdasarkan type
  IconData get iconData {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'promo':
        return Icons.local_offer;
      case 'reminder':
        return Icons.notifications;
      case 'service':
        return Icons.spa;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications_none;
    }
  }

  // Get color berdasarkan type
  Color get colorData {
    switch (type) {
      case 'booking':
        return Colors.blue;
      case 'promo':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'service':
        return Colors.purple;
      case 'system':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get type label untuk display
  String get typeLabel {
    switch (type) {
      case 'booking':
        return 'Booking';
      case 'promo':
        return 'Promo';
      case 'reminder':
        return 'Pengingat';
      case 'service':
        return 'Layanan';
      case 'system':
        return 'Sistem';
      default:
        return type;
    }
  }

  // Copy with method (tetap dalam format String)
  NotificationModel copyWith({
    String? id,
    String? user_id,
    String? title,
    String? message,
    String? type,
    String? icon,
    String? color,
    String? is_read,
    String? metadata,
    String? created_at,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      is_read: is_read ?? this.is_read,
      metadata: metadata ?? this.metadata,
      created_at: created_at ?? this.created_at,
    );
  }

  // Method untuk mark as read
  NotificationModel markAsRead() {
    return copyWith(is_read: '1');
  }

  // Method untuk mark as unread
  NotificationModel markAsUnread() {
    return copyWith(is_read: '0');
  }

  // Static method untuk create new notification
  static NotificationModel createNew({
    required String user_id,
    required String title,
    required String message,
    required String type,
    String icon = '',
    String color = '',
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: '', // Empty untuk insert baru
      user_id: user_id,
      title: title,
      message: message,
      type: type,
      icon: icon,
      color: color,
      is_read: '0', // Default unread
      metadata: metadata != null ? json.encode(metadata) : '',
      created_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk validasi notification
  bool get isValid {
    return user_id.isNotEmpty &&
           title.isNotEmpty &&
           message.isNotEmpty &&
           type.isNotEmpty;
  }

  // Method untuk short message preview
  String get messagePreview {
    if (message.length <= 60) return message;
    return '${message.substring(0, 60)}...';
  }

  @override
  String toString() {
    return 'Notification[$type]: $title - ${isReadBool ? 'Read' : 'Unread'}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.user_id == user_id &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^ user_id.hashCode ^ created_at.hashCode;
  }
}