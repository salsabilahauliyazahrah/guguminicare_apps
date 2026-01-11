// lib/presentation/screens/driver/driver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
// Import services untuk database integration
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/driver_data_service.dart';
import 'package:tugas_akhir/presentation/screens/services/notification_service.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';
// Import models
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const DriverDashboardScreen({super.key, this.loginData});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  // Services untuk database integration
  final BookingService _bookingService = BookingService();
  final DriverDataService _driverDataService = DriverDataService();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final PetService _petService = PetService();
  final ServiceService _serviceService = ServiceService();

  // Data driver dari database
  Map<String, dynamic> _currentDriver = {};
  String _currentDriverId = '';
  String _currentUserId = '';

  // Data dari database
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _driverAssignments = [];
  List<Map<String, dynamic>> _completedAssignments = [];

  // Cache untuk lookup
  Map<String, UserModel> _usersCache = {};
  Map<String, PetModel> _petsCache = {};
  Map<String, ServiceModel> _servicesCache = {};

  int _selectedTab = 0; // 0: Notifikasi, 1: Tugas, 2: Riwayat
  bool _isOnline = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Data salon
  final Map<String, dynamic> _salon = {
    'id': 1,
    'salon_name': 'Gugumi Care Salon',
    'logo': 'gugumi_logo.png',
    'address': 'Jl. Kebon Jeruk Raya No. 27, Jakarta Barat',
    'phone': '021-12345678',
  };

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ============ LOAD ALL DATA FROM DATABASE ============
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Inisialisasi driver dari login data atau storage
      await _initializeDriver();

      // Load data paralel dari database
      await Future.wait([
        _loadNotifications(),
        _loadAssignments(),
        _loadCacheData(),
      ]);

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading driver data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  // ============ INITIALIZE DRIVER FROM DATABASE ============
  Future<void> _initializeDriver() async {
    print('🚗 Initializing driver from database...');

    // Coba ambil dari loginData atau storage
    final loginData = widget.loginData;

    if (loginData != null) {
      _currentDriverId = loginData['driver_id']?.toString() ?? '';
      _currentUserId = loginData['user_id']?.toString() ?? '';
    }

    // Jika tidak ada di loginData, coba dari storage
    if (_currentDriverId.isEmpty) {
      _currentDriverId = StorageHelper.getString('driver_id') ?? '';
    }
    if (_currentUserId.isEmpty) {
      _currentUserId = StorageHelper.getString('user_id') ?? '';
    }

    print('📋 Driver ID: $_currentDriverId, User ID: $_currentUserId');

    // Load driver data dari database
    if (_currentDriverId.isNotEmpty) {
      try {
        final driverData =
            await _driverDataService.getDriverById(_currentDriverId);
        _currentDriver = {
          'id': driverData.id,
          'name': driverData.name,
          'total_earnings': driverData.revenueInt,
          'total_completed': driverData.completedInt,
          'average_rating': driverData.ratingDouble,
          'status': 'active',
          'avatar_color': Colors.blue,
          'vehicle': loginData?['vehicle'] ?? 'Kendaraan Driver',
          'email': loginData?['email'] ?? '',
          'phone': loginData?['phone'] ?? '',
        };
        print('✅ Driver data loaded: ${_currentDriver['name']}');
      } catch (e) {
        print('⚠️ Error loading driver data, using fallback: $e');
        _setFallbackDriverData(loginData);
      }
    } else {
      _setFallbackDriverData(loginData);
    }
  }

  void _setFallbackDriverData(Map<String, dynamic>? loginData) {
    _currentDriver = {
      'id': _currentDriverId.isNotEmpty ? _currentDriverId : '0',
      'name': loginData?['name'] ?? loginData?['driver_name'] ?? 'Driver',
      'email': loginData?['email'] ?? '',
      'phone': loginData?['phone'] ?? '',
      'vehicle': loginData?['vehicle'] ?? 'Kendaraan',
      'status': 'active',
      'avatar_color': Colors.blue,
      'total_earnings': 0,
      'total_completed': 0,
      'average_rating': 0.0,
    };
  }

  // ============ LOAD NOTIFICATIONS FROM DATABASE ============
  Future<void> _loadNotifications() async {
    print('🔔 Loading notifications from database...');

    if (_currentUserId.isEmpty) {
      print('⚠️ No user_id, skipping notifications');
      return;
    }

    try {
      final notificationModels =
          await _notificationService.getNotificationsByUserId(_currentUserId);

      setState(() {
        _notifications = notificationModels
            .map((n) => {
                  'id': n.id,
                  'user_id': n.user_id,
                  'type': n.type,
                  'title': n.title,
                  'message': n.message,
                  'booking_id': n.metadataMap?['booking_id'],
                  'is_read': n.isReadBool,
                  'created_at': n.created_at,
                  'action_required': n.type == 'assignment',
                })
            .toList();
      });

      print('✅ Loaded ${_notifications.length} notifications');
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() => _notifications = []);
    }
  }

  // ============ LOAD ASSIGNMENTS FROM DATABASE ============
  Future<void> _loadAssignments() async {
    print('📋 Loading assignments from database...');

    if (_currentDriverId.isEmpty && _currentUserId.isEmpty) {
      print('⚠️ No driver_id or user_id, skipping assignments');
      return;
    }

    try {
      // Load semua booking yang ditugaskan ke driver ini
      final allBookings = await _bookingService.getAllBookings();

      // Filter booking berdasarkan driver_id
      final driverBookings = allBookings.where((booking) {
        return booking.driver_id == _currentDriverId ||
            booking.driver_id == _currentUserId;
      }).toList();

      print('📊 Found ${driverBookings.length} bookings for this driver');

      // Separate active dan completed
      final activeBookings = driverBookings.where((b) {
        final status = b.booking_status.toLowerCase();
        return status != 'selesai' &&
            status != 'completed' &&
            status != 'dibatalkan' &&
            status != 'cancelled';
      }).toList();

      final completedBookings = driverBookings.where((b) {
        final status = b.booking_status.toLowerCase();
        return status == 'selesai' || status == 'completed';
      }).toList();

      // Convert to assignment format
      setState(() {
        _driverAssignments = activeBookings
            .map((booking) => _bookingToAssignment(booking, false))
            .toList();
        _completedAssignments = completedBookings
            .map((booking) => _bookingToAssignment(booking, true))
            .toList();
      });

      print('✅ Active assignments: ${_driverAssignments.length}');
      print('✅ Completed assignments: ${_completedAssignments.length}');
    } catch (e) {
      print('❌ Error loading assignments: $e');
      setState(() {
        _driverAssignments = [];
        _completedAssignments = [];
      });
    }
  }

  // ============ LOAD CACHE DATA ============
  Future<void> _loadCacheData() async {
    try {
      final results = await Future.wait([
        _userService.getUsersByRole('customer'),
        _petService.getAllPets(),
        _serviceService.getAllServices(),
      ]);

      final users = results[0] as List<UserModel>;
      final pets = results[1] as List<PetModel>;
      final services = results[2] as List<ServiceModel>;

      _usersCache = {for (var u in users) u.id: u};
      _petsCache = {for (var p in pets) p.id: p};
      _servicesCache = {for (var s in services) s.id: s};

      print(
          '✅ Cache loaded: ${users.length} users, ${pets.length} pets, ${services.length} services');
    } catch (e) {
      print('⚠️ Error loading cache: $e');
    }
  }

  // ============ CONVERT BOOKING TO ASSIGNMENT FORMAT ============
  Map<String, dynamic> _bookingToAssignment(
      BookingModel booking, bool isCompleted) {
    final customer = _usersCache[booking.user_id];
    final pet = _petsCache[booking.pet_id];
    final service = _servicesCache[booking.service_id];

    Color statusColor = Colors.blue;
    String statusText = 'Ditugaskan';

    switch (booking.booking_status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'diterima':
      case 'accepted':
        statusColor = Colors.blue;
        statusText = 'Diterima';
        break;
      case 'diproses':
      case 'in_progress':
        statusColor = Colors.purple;
        statusText = 'Diproses';
        break;
      case 'selesai':
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'dibatalkan':
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
    }

    return {
      'id': booking.id,
      'booking_id':
          booking.booking_code.isNotEmpty ? booking.booking_code : booking.id,
      'driver_id': booking.driver_id,
      'status': booking.booking_status,
      'status_text': statusText,
      'status_color': statusColor,
      'photo_groot': isCompleted ? 'groom_photo.jpg' : null,
      'updated_at': booking.created_at,
      'completed_date': isCompleted ? booking.booking_date : null,
      'notification_id': null,
      'booking_data': {
        'id': booking.id,
        'user_id': booking.user_id,
        'pet_id': booking.pet_id,
        'service_id': booking.service_id,
        'booking_date': booking.booking_date,
        'booking_time': booking.booking_time,
        'service_method': booking.service_method,
        'address': booking.address_id,
        'total_price': booking.totalPriceDouble,
        'status': booking.booking_status,
        'customer': {
          'name': customer?.name ?? 'Customer',
          'phone': customer?.phone ?? '-',
          'email': customer?.email ?? '-',
        },
        'pet': {
          'name': pet?.name ?? 'Pet',
          'type': pet?.type ?? '-',
          'age': pet?.age ?? '-',
          'weight': pet?.weight ?? '-',
        },
        'service': {
          'name': service?.name ?? 'Layanan',
          'price': service != null ? int.tryParse(service.price) ?? 0 : 0,
          'duration': service?.duration ?? '-',
        },
        'review': null,
      }
    };
  }

  // ============ NOTIFICATION ALERT ============
  // ignore: unused_element
  void _showNewNotificationAlert(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Notifikasi Baru'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsRead(notification['id']);
            },
            child: const Text('Tandai Dibaca'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsRead(notification['id']);
              setState(() {
                _selectedTab = 1; // Switch to tasks tab
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lihat Tugas'),
          ),
        ],
      ),
    );
  }

  // ============ MARK NOTIFICATION AS READ IN DATABASE ============
  void _markAsRead(dynamic notificationId) async {
    final id = notificationId.toString();

    // Update local state
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'].toString() == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
      }
    });

    // Update database
    try {
      await _notificationService.markAsRead(id);
      print('✅ Notification marked as read in database');
    } catch (e) {
      print('⚠️ Error marking notification as read: $e');
    }
  }

  int get _unreadNotificationsCount {
    return _notifications.where((n) => n['is_read'] == false).length;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          title: Text('Driver Dashboard',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.black)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.orangeMedium),
              const SizedBox(height: 16),
              const Text('Memuat data driver...'),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          title: Text('Driver Dashboard',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.black)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Dashboard',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.black,
              ),
            ),
            Text(
              _salon['salon_name'],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.orangeMedium,
              ),
            ),
          ],
        ),
        actions: [
          // Online/Offline toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Switch(
              value: _isOnline,
              onChanged: (value) {
                setState(() {
                  _isOnline = value;
                  _currentDriver['status'] = value ? 'active' : 'inactive';
                });

                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status: Online - Siap menerima tugas'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status: Offline'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          // Notification badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: AppColors.orangeMedium),
                onPressed: () => setState(() {
                  _selectedTab = 0; // Switch to notifications tab
                }),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.orangeMedium),
            onPressed: () => _showProfileMenu(context),
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orangeMedium),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Driver Info & Online Status
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.grey200,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          _currentDriver['avatar_color'] ?? Colors.blue,
                      child: Text(
                        (_currentDriver['name']?.toString().isNotEmpty == true)
                            ? _currentDriver['name'].toString()[0]
                            : 'D',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentDriver['name']?.toString() ?? 'Driver',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            _currentDriver['vehicle']?.toString() ??
                                'Kendaraan',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isOnline ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isOnline ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ID: DRV-${(_currentDriver['id']?.toString() ?? '0').padLeft(3, '0')}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      label: 'Pendapatan',
                      value:
                          'Rp ${_formatCurrency(_currentDriver['total_earnings'] ?? 0)}',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      label: 'Tugas Selesai',
                      value: '${_currentDriver['total_completed'] ?? 0}',
                      icon: Icons.check_circle,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      label: 'Rating',
                      value: (_currentDriver['average_rating'] ?? 0.0)
                          .toStringAsFixed(1),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    0,
                    'Notifikasi',
                    _unreadNotificationsCount,
                    icon: Icons.notifications,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    1,
                    'Tugas Aktif',
                    _driverAssignments.length,
                    icon: Icons.assignment,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    2,
                    'Riwayat',
                    _completedAssignments.length,
                    icon: Icons.history,
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                // Notifications Tab
                _buildNotificationsTab(),
                // Active Tasks Tab
                _buildActiveTasksTab(),
                // History Tab
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return NumberFormat.decimalPattern('id').format(amount);
  }

  Widget _buildStatCard(
      {required String label,
      required String value,
      required IconData icon,
      required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabButton(int tabIndex, String title, int count,
      {required IconData icon}) {
    final isSelected = _selectedTab == tabIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = tabIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.orangeMedium.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.orangeMedium : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.orangeMedium : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.orangeMedium : Colors.grey,
              ),
            ),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.orangeMedium : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
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
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua notifikasi akan muncul di sini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = notification['is_read'] == false;
    final iconColor = notification['type'] == 'assignment'
        ? Colors.blue
        : notification['type'] == 'payment'
            ? Colors.green
            : AppColors.orangeMedium;

    final icon = notification['type'] == 'assignment'
        ? Icons.assignment
        : notification['type'] == 'payment'
            ? Icons.payment
            : Icons.info;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 2 : 1,
      color: isUnread ? Colors.white : AppColors.grey200,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            color: AppColors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'],
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification['created_at']),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          _handleNotificationTap(notification);
        },
        onLongPress: () {
          _showNotificationActions(notification);
        },
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    _markAsRead(notification['id']);

    if (notification['type'] == 'assignment' &&
        notification['booking_id'] != null) {
      // Cari assignment terkait
      final bookingId = notification['booking_id'].toString();
      final assignment = _driverAssignments.firstWhere(
        (a) =>
            a['booking_id'].toString() == bookingId ||
            a['id'].toString() == bookingId,
        orElse: () => {},
      );

      if (assignment.isNotEmpty) {
        // Switch ke tasks tab dan show detail
        setState(() {
          _selectedTab = 1;
        });

        // Show assignment detail
        Future.delayed(const Duration(milliseconds: 300), () {
          _viewAssignmentDetail(assignment);
        });
      } else {
        // Just switch to tasks tab if assignment not found
        setState(() {
          _selectedTab = 1;
        });
      }
    } else {
      // Show notification detail
      _showNotificationDetail(notification);
    }
  }

  void _showNotificationActions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_as_unread),
              title: const Text('Tandai belum dibaca'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  notification['is_read'] = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hapus notifikasi'),
              onTap: () async {
                Navigator.pop(context);

                final notifId = notification['id'].toString();

                // Delete from local state
                setState(() {
                  _notifications.remove(notification);
                });

                // Delete from database
                try {
                  await _notificationService.deleteNotification(notifId);
                  print('✅ Notification deleted from database');
                } catch (e) {
                  print('⚠️ Error deleting notification: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Tutup'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification['message']),
              const SizedBox(height: 16),
              Text(
                'Waktu: ${_formatDateTime(notification['created_at'])}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              if (notification['booking_id'] != null)
                Text(
                  'Booking ID: BOOK-${notification['booking_id']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (notification['type'] == 'assignment' &&
              notification['booking_id'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedTab = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lihat Tugas'),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTasksTab() {
    if (_driverAssignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada tugas aktif',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            if (!_isOnline)
              Column(
                children: [
                  Text(
                    'Anda sedang offline',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isOnline = true;
                        _currentDriver['status'] = 'active';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Online Sekarang'),
                  ),
                ],
              )
            else
              Text(
                'Tunggu notifikasi tugas dari admin',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey500,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _driverAssignments.length,
      itemBuilder: (context, index) {
        final assignment = _driverAssignments[index];
        return _buildAssignmentCard(assignment, isActive: true);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_completedAssignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat tugas',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat tugas akan muncul di sini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedAssignments.length,
      itemBuilder: (context, index) {
        final assignment = _completedAssignments[index];
        return _buildAssignmentCard(assignment, isActive: false);
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment,
      {bool isActive = true}) {
    final bookingData = assignment['booking_data'] as Map<String, dynamic>;
    final customer = bookingData['customer'] as Map<String, dynamic>;
    final pet = bookingData['pet'] as Map<String, dynamic>;
    final service = bookingData['service'] as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOK-${assignment['booking_id']}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      _formatDate(bookingData['booking_date']),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: assignment['status_color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assignment['status_text'],
                    style: TextStyle(
                      fontSize: 12,
                      color: assignment['status_color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Customer Info
            _buildInfoRow(Icons.person, customer['name']),

            const SizedBox(height: 8),

            _buildInfoRow(Icons.phone, customer['phone']),

            const SizedBox(height: 8),

            _buildInfoRow(Icons.pets, '${pet['name']} (${pet['type']})'),

            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookingData['address'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Service Info
            Row(
              children: [
                Icon(Icons.cleaning_services,
                    size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service['name'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
                Text(
                  'Rp ${_formatCurrency(service['price'])}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.orangeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time Info
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  '${bookingData['booking_time'].toString().substring(0, 5)} WIB',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.directions_car, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  bookingData['service_method'] == 'pickup'
                      ? 'Antar Jemput'
                      : 'Delivery',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),

            // Photo Groom Indicator
            if (assignment['photo_groot'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.photo_camera, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Foto grooming tersedia',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            const SizedBox(height: 16),

            if (isActive)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewAssignmentDetail(assignment),
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      label: const Text('Detail'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAssignmentStatus(assignment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeMedium,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.directions_car, size: 18),
                      label: const Text('Mulai Tugas'),
                    ),
                  ),
                ],
              ),

            if (!isActive && bookingData['review'] != null) ...[
              const Divider(height: 16),
              _buildReviewSection(
                  bookingData['review'] as Map<String, dynamic>),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(Map<String, dynamic> review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${review['rating']}/5',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
            const Spacer(),
            Text(
              'Ulasan Customer',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review['review'],
          style: AppTextStyles.bodyMedium.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        if (review['reply'] != null &&
            (review['reply'] as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balasan Admin:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.orangeMedium,
                  ),
                ),
                Text(
                  review['reply'],
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  void _viewAssignmentDetail(Map<String, dynamic> assignment) {
    final bookingData = assignment['booking_data'] as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return AssignmentDetailScreen(
          assignment: assignment,
          onUpdateStatus: () {
            _updateAssignmentStatus(assignment);
          },
          onOpenMaps: () {
            _openMaps(bookingData['address']);
          },
        );
      },
    );
  }

  void _updateAssignmentStatus(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(
        currentStatus: assignment['status'],
        onStatusSelected: (newStatus) {
          _processStatusUpdate(assignment, newStatus);
        },
      ),
    );
  }

  void _processStatusUpdate(
      Map<String, dynamic> assignment, Map<String, dynamic> newStatus) async {
    Navigator.pop(context); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get booking ID
      final bookingId = assignment['id']?.toString() ?? '';

      // Map status value to booking status
      String bookingStatus = 'diproses';
      if (newStatus['value'] == 'on_the_way') {
        bookingStatus = 'diproses';
      } else if (newStatus['value'] == 'pickup_completed') {
        bookingStatus = 'diproses';
      } else if (newStatus['value'] == 'delivery') {
        bookingStatus = 'diproses';
      } else if (newStatus['value'] == 'completed') {
        bookingStatus = 'selesai';
      }

      // Update booking status in database
      if (bookingId.isNotEmpty) {
        await _bookingService.updateBookingStatus(bookingId, bookingStatus);
        print('✅ Booking status updated in database');
      }

      // Update driver stats if completed
      if (newStatus['value'] == 'completed' && _currentDriverId.isNotEmpty) {
        final bookingData = assignment['booking_data'] as Map<String, dynamic>?;
        final totalPrice = bookingData?['total_price'];
        final priceInt = totalPrice is num
            ? totalPrice.toInt()
            : int.tryParse(totalPrice?.toString() ?? '0') ?? 0;

        await _driverDataService.incrementDriverCompleted(_currentDriverId);
        await _driverDataService.addDriverRevenue(_currentDriverId, priceInt);
        print('✅ Driver stats updated');
      }

      Navigator.pop(context); // Close loading

      // Update local state
      setState(() {
        assignment['status'] = newStatus['value'];
        assignment['status_text'] = newStatus['label'];
        assignment['status_color'] = newStatus['color'];
        assignment['updated_at'] = DateTime.now().toString();

        // Update booking status
        final bookingData = assignment['booking_data'] as Map<String, dynamic>;

        if (newStatus['value'] == 'on_the_way') {
          bookingData['status'] = 'driver_on_the_way';
        } else if (newStatus['value'] == 'pickup_completed') {
          bookingData['status'] = 'at_salon';
        } else if (newStatus['value'] == 'delivery') {
          bookingData['status'] = 'on_delivery';
        } else if (newStatus['value'] == 'completed') {
          bookingData['status'] = 'completed';
          assignment['photo_groot'] =
              'groom_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Pindahkan ke completed assignments
          _driverAssignments.remove(assignment);
          _completedAssignments.insert(0, {
            ...assignment,
            'completed_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          });

          // Update driver stats locally
          _currentDriver['total_completed'] =
              (_currentDriver['total_completed'] ?? 0) + 1;
          final totalPrice = bookingData['total_price'];
          final priceInt = totalPrice is num
              ? totalPrice.toInt()
              : int.tryParse(totalPrice?.toString() ?? '0') ?? 0;
          _currentDriver['total_earnings'] =
              (_currentDriver['total_earnings'] ?? 0) + priceInt;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Status berhasil diubah menjadi "${newStatus['label']}"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      print('❌ Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openMaps(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka Google Maps ke: $address'),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final driverName = _currentDriver['name']?.toString() ?? 'Driver';
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      _currentDriver['avatar_color'] ?? Colors.blue,
                  child: Text(
                    driverName.isNotEmpty ? driverName[0] : 'D',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(driverName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentDriver['email']?.toString() ?? ''),
                    Text(_currentDriver['vehicle']?.toString() ?? 'Kendaraan'),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: AppColors.orangeMedium),
                title: const Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  _showSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: AppColors.orangeMedium),
                title: const Text('Bantuan'),
                onTap: () {
                  Navigator.pop(context);
                  _showHelp();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings() {
    // Implementation...
  }

  void _showHelp() {
    // Implementation...
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout dari akun driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear storage
              await StorageHelper.remove('driver_id');
              await StorageHelper.remove('user_id');
              await StorageHelper.remove('user_role');
              await StorageHelper.remove('user_name');

              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil logout'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Widget untuk detail assignment
class AssignmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onUpdateStatus;
  final VoidCallback onOpenMaps;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
    required this.onUpdateStatus,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final bookingData = assignment['booking_data'] as Map<String, dynamic>;
    final customer = bookingData['customer'] as Map<String, dynamic>;
    final pet = bookingData['pet'] as Map<String, dynamic>;
    final service = bookingData['service'] as Map<String, dynamic>;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Detail Tugas',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(
                        'Assignment ID', 'ASG-${assignment['id']}'),
                    _buildDetailItem(
                        'Booking ID', 'BOOK-${assignment['booking_id']}'),
                    _buildDetailItem('Status', assignment['status_text']),
                    _buildDetailItem('Terakhir Update',
                        _formatDateTime(assignment['updated_at'])),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      'Info Booking',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                        'Tanggal', _formatDate(bookingData['booking_date'])),
                    _buildDetailItem('Waktu',
                        '${bookingData['booking_time'].toString().substring(0, 5)} WIB'),
                    _buildDetailItem(
                        'Metode',
                        bookingData['service_method'] == 'pickup'
                            ? 'Antar Jemput'
                            : 'Delivery'),
                    _buildDetailItem('Total Harga',
                        'Rp ${_formatCurrency(bookingData['total_price'].toInt())}'),
                    _buildDetailItem('Status Booking', bookingData['status']),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      'Info Customer',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem('Nama', customer['name']),
                    _buildDetailItem('Telepon', customer['phone']),
                    _buildDetailItem('Email', customer['email']),
                    _buildDetailItem('Alamat', bookingData['address']),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      'Info Hewan',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem('Nama', pet['name']),
                    _buildDetailItem('Jenis', pet['type']),
                    _buildDetailItem('Usia', pet['age']),
                    if (pet['weight'] != null)
                      _buildDetailItem('Berat', '${pet['weight']}'),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      'Layanan',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem('Nama Layanan', service['name']),
                    _buildDetailItem(
                        'Harga', 'Rp ${_formatCurrency(service['price'])}'),
                    if (service['duration'] != null)
                      _buildDetailItem('Durasi', service['duration']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenMaps,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.navigation, size: 18),
                        SizedBox(width: 4),
                        Text('Maps'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onUpdateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 18),
                        SizedBox(width: 4),
                        Text('Update'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.decimalPattern('id').format(amount);
  }
}

// Dialog untuk update status
class UpdateStatusDialog extends StatefulWidget {
  final String currentStatus;
  final Function(Map<String, dynamic>) onStatusSelected;

  const UpdateStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  String _selectedStatus = '';

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'on_the_way', 'label': 'Menuju Lokasi', 'color': Colors.orange},
    {'value': 'arrived', 'label': 'Tiba di Lokasi', 'color': Colors.blue},
    {
      'value': 'pickup_completed',
      'label': 'Selesai Jemput',
      'color': Colors.purple
    },
    {'value': 'delivery', 'label': 'Sedang Mengantar', 'color': Colors.indigo},
    {'value': 'completed', 'label': 'Selesai', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Status Tugas'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView(
          children: _statusOptions.map((status) {
            final isSelected = _selectedStatus == status['value'];
            return ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status['color'],
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(status['label']),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _selectedStatus = status['value'];
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final selected = _statusOptions.firstWhere(
              (s) => s['value'] == _selectedStatus,
              orElse: () => _statusOptions.first,
            );
            widget.onStatusSelected(selected);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeMedium,
            foregroundColor: Colors.white,
          ),
          child: const Text('Update Status'),
        ),
      ],
    );
  }
}
