// lib/presentation/screens/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/notification_model.dart';

class NotificationService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET NOTIFICATIONS BY USER ID ============
  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    print('🔔 Mengambil notifikasi untuk user: $userId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'notification',
          'appid': _appId,
          'where_field': 'user_id',
          'where_value': userId,
        },
      );
      
      print('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        print('📊 Jumlah notifikasi ditemukan: ${rawData.length}');
        
        final List<NotificationModel> notifications = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> notificationMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final notification = NotificationModel.fromJson(notificationMap);
            notifications.add(notification);
            
            print('✅ Loaded: ${notification.title} - ${notification.type}');
          } catch (e) {
            print('⚠️ Error parsing notification: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        notifications.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return notifications;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil notifikasi: $e');
      throw Exception('Gagal mengambil data notifikasi: $e');
    }
  }

  // ============ CREATE NEW NOTIFICATION ============
  Future<NotificationModel> createNotification(NotificationModel notification) async {
    print('➕ Membuat notifikasi baru: ${notification.title}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'notification',
        'appid': _appId,
        'user_id': notification.user_id,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type,
        'icon': notification.icon,
        'color': notification.color,
        'is_read': notification.is_read,
        'metadata': notification.metadata,
        'created_at': notification.created_at,
      };
      
      print('📋 Notification Data:');
      bodyData.forEach((key, value) {
        print('   $key: ${value.isNotEmpty ? value : "(kosong)"}');
      });
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyData,
      );
      
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is List && responseData.isNotEmpty) {
          final createdData = responseData[0];
          final newId = createdData['_id']?.toString() ?? '';
          
          print('✅ Notification created with ID: $newId');
          return notification.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return notification;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating notification: $e');
      rethrow;
    }
  }

  // ============ MARK AS READ ============
  Future<void> markAsRead(String notificationId) async {
    print('✅ Mark notification as read: $notificationId');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final updateData = {
        'is_read': '1',
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'notification',
          'appid': _appId,
          'id': notificationId,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      print('📡 Update Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Notification marked as read');
      } else {
        throw Exception('Mark as read failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error marking as read: $e');
      rethrow;
    }
  }

  // ============ MARK ALL AS READ ============
  Future<void> markAllAsRead(String userId) async {
    print('✅ Mark all notifications as read for user: $userId');
    
    try {
      final notifications = await getNotificationsByUserId(userId);
      
      // Mark semua yang belum dibaca
      for (var notification in notifications) {
        if (!notification.isReadBool) {
          await markAsRead(notification.id);
        }
      }
      
      print('✅ All notifications marked as read');
    } catch (e) {
      print('💥 Error marking all as read: $e');
      rethrow;
    }
  }

  // ============ GET UNREAD COUNT ============
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotificationsByUserId(userId);
      final unreadCount = notifications.where((n) => !n.isReadBool).length;
      print('📊 Unread notifications: $unreadCount');
      return unreadCount;
    } catch (e) {
      print('💥 Error getting unread count: $e');
      return 0;
    }
  }

  // ============ DELETE NOTIFICATION ============
  Future<void> deleteNotification(String notificationId) async {
    print('🗑️ Delete notification: $notificationId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'notification',
          'appid': _appId,
          'id': notificationId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Notification deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting notification: $e');
      rethrow;
    }
  }

  // ============ SEND PUSH NOTIFICATION ============
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    print('📤 Sending push notification to user: $userId');
    
    try {
      final notification = NotificationModel.createNew(
        user_id: userId,
        title: title,
        message: message,
        type: type,
        metadata: metadata,
      );
      
      await createNotification(notification);
      
      // Di sini bisa tambahkan Firebase Cloud Messaging atau service push notification lainnya
      
      print('✅ Push notification sent');
    } catch (e) {
      print('💥 Error sending push notification: $e');
      rethrow;
    }
  }
}