// screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:tugas_akhir/presentation/screens/services/notification_service.dart';
import 'package:tugas_akhir/core/models/notification_model.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = StorageHelper.getString('user_id');
      if (userId == null || userId.isEmpty) {
        throw Exception('User belum login');
      }

      final notifications = await _notificationService.getNotificationsByUserId(userId);
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Convert NotificationModel to Map for UI
  Map<String, dynamic> _notificationToMap(NotificationModel notif) {
    IconData iconData;
    Color color;
    
    switch (notif.type.toLowerCase()) {
      case 'booking':
        iconData = Icons.calendar_today;
        color = Colors.green;
        break;
      case 'promo':
        iconData = Icons.local_offer;
        color = Colors.orange;
        break;
      case 'reminder':
        iconData = Icons.notifications_active;
        color = Colors.blue;
        break;
      case 'service':
        iconData = Icons.celebration;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }

    return {
      'id': notif.id,
      'title': notif.title,
      'message': notif.message,
      'time': notif.formattedDate,
      'icon': iconData,
      'color': color,
      'isRead': notif.isReadBool,
      'type': notif.type,
      'metadata': notif.metadataMap,
    };
  }

  List<Map<String, dynamic>> get notifications => 
      _notifications.map((n) => _notificationToMap(n)).toList();

  int get unreadCount {
    return _notifications.where((notif) => !notif.isReadBool).length;
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = StorageHelper.getString('user_id');
      if (userId == null || userId.isEmpty) return;

      await _notificationService.markAllAsRead(userId);
      await _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menandai notifikasi: $e')),
        );
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
      setState(() {
        _notifications.removeWhere((notif) => notif.id == id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus notifikasi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Badge(
                label: Text('$unreadCount'),
                child: const Icon(Icons.mark_email_read),
              ),
              onPressed: markAllAsRead,
              tooltip: 'Tandai semua sudah dibaca',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat notifikasi...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat notifikasi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadNotifications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(notif);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Dismissible(
      key: Key(notif['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) => deleteNotification(notif['id']),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notif['isRead'] ? Colors.grey.shade200 : Colors.blue.shade200,
            width: notif['isRead'] ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              notif['isRead'] = true;
            });
            
            // Navigasi berdasarkan type notifikasi
            if (notif['type'] == 'booking' && notif['bookingId'] != null) {
              // Navigasi ke detail booking
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Membuka detail booking ${notif['bookingId']}')),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: notif['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif['icon'], color: notif['color'], size: 24),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                                color: notif['isRead'] ? Colors.black : Colors.blue.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notif['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif['message'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Badge type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(notif['type']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getTypeText(notif['type']),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!notif['isRead'])
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh atau tambah data dummy
              setState(() {
                notifications.add({
                  'id': '${notifications.length + 1}',
                  'title': 'Notifikasi Baru',
                  'message': 'Ini adalah notifikasi contoh',
                  'time': 'Baru saja',
                  'icon': Icons.info,
                  'color': Colors.blue,
                  'isRead': false,
                  'type': 'info',
                });
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Notifikasi'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking':
        return Colors.blue.shade600;
      case 'promo':
        return Colors.orange.shade600;
      case 'reminder':
        return Colors.teal.shade600;
      case 'service':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'booking':
        return 'BOOKING';
      case 'promo':
        return 'PROMO';
      case 'reminder':
        return 'PENGINGAT';
      case 'service':
        return 'LAYANAN';
      default:
        return 'INFO';
    }
  }
}