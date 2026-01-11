// lib/presentation/screens/admin/drivers/admin_drivers_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  final UserService _userService = UserService();
  final BookingService _bookingService = BookingService();
  
  List<UserModel> _drivers = [];
  List<BookingModel> _pickupRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _selectedTab = 0; // 0: Drivers, 1: Pickup Requests

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load drivers (users with role 'driver')
      final drivers = await _userService.getUsersByRole('driver');
      
      // Load pickup requests (bookings with service_method containing 'antar' or 'jemput' or 'pickup')
      final allBookings = await _bookingService.getAllBookings();
      final pickupBookings = allBookings.where((booking) {
        final method = booking.service_method.toLowerCase();
        return method.contains('antar') || method.contains('jemput') || method.contains('pickup');
      }).toList();
      
      setState(() {
        _drivers = drivers;
        _pickupRequests = pickupBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  // Helper methods for driver status display
  Map<String, dynamic> _getDriverStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'aktif':
        return {'text': 'Aktif', 'color': Colors.green};
      case 'on_delivery':
      case 'sedang antar':
        return {'text': 'Sedang Antar', 'color': Colors.orange};
      case 'inactive':
      case 'offline':
        return {'text': 'Offline', 'color': Colors.grey};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),          
          title: const Text(
            'Driver & Antar Jemput',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab, // 🔥 ngisi setengah layar
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: AppColors.orangeMedium,
              ),
            ),
            labelColor: AppColors.orangeMedium,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Driver'),
              Tab(text: 'Permintaan Antar Jemput'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllData,
              color: AppColors.orangeMedium,
              tooltip: 'Refresh',
            ),
            if (_selectedTab == 0)
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: _addNewDriver,
                color: AppColors.orangeMedium,
              ),
          ],
        ),
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _loadAllData,
                    child: TabBarView(
                      children: [
                        // Tab 1: Drivers
                        _buildDriversTab(),
                        
                        // Tab 2: Pickup Requests
                        _buildPickupRequestsTab(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab() {
    final activeDrivers = _drivers.where((d) {
      final status = d.status.toLowerCase();
      return status == 'active' || status == 'aktif' || status == 'on_delivery' || status == 'sedang antar';
    }).length;
    
    final onDeliveryDrivers = _drivers.where((d) {
      final status = d.status.toLowerCase();
      return status == 'on_delivery' || status == 'sedang antar';
    }).length;
    
    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDriverStat(
                label: 'Total Driver',
                value: '${_drivers.length}',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildDriverStat(
                label: 'Aktif',
                value: '$activeDrivers',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildDriverStat(
                label: 'Sedang Tugas',
                value: '$onDeliveryDrivers',
                icon: Icons.directions_car,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        
        // Drivers list
        Expanded(
          child: _drivers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada driver',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _drivers.length,
                  itemBuilder: (context, index) {
                    final driver = _drivers[index];
                    return _buildDriverCard(driver);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPickupRequestsTab() {
    final pendingRequests = _pickupRequests.where((p) {
      final status = p.booking_status.toLowerCase();
      return status == 'pending' || status == 'menunggu';
    }).length;
    
    final inProgressRequests = _pickupRequests.where((p) {
      final status = p.booking_status.toLowerCase();
      return status == 'in_progress' || status == 'diproses';
    }).length;
    
    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPickupStat(
                label: 'Total Permintaan',
                value: '${_pickupRequests.length}',
                icon: Icons.list_alt,
                color: Colors.blue,
              ),
              _buildPickupStat(
                label: 'Pending',
                value: '$pendingRequests',
                icon: Icons.pending,
                color: Colors.orange,
              ),
              _buildPickupStat(
                label: 'Diproses',
                value: '$inProgressRequests',
                icon: Icons.directions_car,
                color: Colors.green,
              ),
            ],
          ),
        ),
        
        // Pickup requests list
        Expanded(
          child: _pickupRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada permintaan antar jemput',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _pickupRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pickupRequests[index];
                    return _buildPickupRequestCard(request);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDriverStat({required String label, required String value, required IconData icon, required Color color}) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupStat({required String label, required String value, required IconData icon, required Color color}) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(UserModel driver) {
    final statusDisplay = _getDriverStatusDisplay(driver.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        driver.phone.isNotEmpty ? driver.phone : 'Telepon belum diatur',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusDisplay['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusDisplay['text'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusDisplay['color'] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // PERBAIKAN: Contact info dengan Wrap
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 120, // Batasi lebar
                      child: Text(
                        driver.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 150, // Batasi lebar email
                      child: Text(
                        driver.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons - PERBAIKAN: Responsive untuk layar kecil
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                // View detail button
                OutlinedButton(
                  onPressed: () => _viewDriverDetail(driver),
                  child: const Text('Detail'),
                ),
                
                
                // Toggle status button
                IconButton(
                  icon: Icon(
                    driver.status.toLowerCase() == 'inactive' || driver.status.toLowerCase() == 'offline'
                        ? Icons.power_settings_new 
                        : Icons.power_off,
                    color: driver.status.toLowerCase() == 'inactive' || driver.status.toLowerCase() == 'offline'
                        ? Colors.green 
                        : Colors.red,
                  ),
                  onPressed: () => _toggleDriverStatus(driver),
                  tooltip: driver.status.toLowerCase() == 'inactive' || driver.status.toLowerCase() == 'offline'
                      ? 'Aktifkan' 
                      : 'Nonaktifkan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupRequestCard(BookingModel request) {
    final status = request.booking_status.toLowerCase();
    final isPending = status == 'pending' || status == 'menunggu';
    final isInProgress = status == 'in_progress' || status == 'diproses';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: Text(
                    request.booking_code.isNotEmpty ? request.booking_code : request.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : isInProgress ? 'DIPROSES' : request.booking_status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isPending 
                          ? Colors.orange 
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Customer info
            Text(
              'Pelanggan: ${request.user_id}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Layanan: ${request.service_id}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Details - PERBAIKAN: Gunakan Wrap untuk responsive
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildPickupDetailItem(
                  label: 'Waktu',
                  value: request.booking_time,
                  icon: Icons.access_time,
                  color: Colors.blue,
                ),
                _buildPickupDetailItem(
                  label: 'Driver',
                  value: request.driver_id.isNotEmpty ? request.driver_id : 'Belum ditugaskan',
                  icon: Icons.person,
                  color: request.driver_id.isNotEmpty 
                      ? Colors.green 
                      : Colors.grey,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons - PERBAIKAN: Gunakan Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                // View detail button
                OutlinedButton(
                  onPressed: () => _viewPickupDetail(request),
                  child: const Text('Detail'),
                ),
                
                // Assign driver button
                if (isPending)
                  ElevatedButton(
                    onPressed: () => _assignDriver(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tugaskan Driver'),
                  ),
                
                // Update status button
                if (isInProgress)
                  ElevatedButton(
                    onPressed: () => _updatePickupStatus(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Selesai'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDriverDetailItem({required String label, required String value, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailItem({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _addNewDriver() async {
    // Navigasi ke halaman tambah driver
    final result = await context.push('/admin/drivers/add');
    
    if (result != null) {
      // Refresh data dari database
      _loadAllData();
    }
  }

  void _viewDriverDetail(UserModel driver) {
    context.push('/admin/drivers/${driver.id}');
  }

  void _viewPickupDetail(BookingModel request) {
    context.push('/admin/pickups/${request.id}');
  }

  // ignore: unused_element
  void _assignTask(UserModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugaskan Driver'),
        content: const Text('Pilih tugas untuk driver ini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/admin/drivers/${driver.id}/assign');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pilih Tugas'),
          ),
        ],
      ),
    );
  }

  void _assignDriver(BookingModel request) {
    // Filter only active drivers
    final activeDrivers = _drivers.where((d) {
      final status = d.status.toLowerCase();
      return status == 'active' || status == 'aktif';
    }).toList();

    if (activeDrivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada driver aktif tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugaskan Driver'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: activeDrivers.length,
            itemBuilder: (context, index) {
              final driver = activeDrivers[index];
              final statusDisplay = _getDriverStatusDisplay(driver.status);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (statusDisplay['color'] as Color).withOpacity(0.1),
                  backgroundImage: driver.profile_picture.isNotEmpty ? NetworkImage(driver.profile_picture) : null,
                  child: driver.profile_picture.isEmpty 
                      ? Icon(Icons.person, color: statusDisplay['color'] as Color)
                      : null,
                ),
                title: Text(driver.name),
                subtitle: Text(driver.phone),
                trailing: Text(statusDisplay['text'] as String),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Update booking with driver assignment via API
                    final success = await _bookingService.updateBooking(
                      request.id,
                      {
                        'driver_id': driver.id,
                        'booking_status': 'Diproses',
                      },
                    );
                    
                    if (context.mounted) Navigator.pop(context); // Close loading
                    
                    if (success) {
                      await _loadAllData();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Driver ${driver.name} ditugaskan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menugaskan driver'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context); // Close loading
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _toggleDriverStatus(UserModel driver) async {
    final isInactive = driver.status.toLowerCase() == 'inactive' || driver.status.toLowerCase() == 'offline';
    final newStatus = isInactive ? 'active' : 'inactive';
    final newStatusText = isInactive ? 'Aktif' : 'Offline';
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Update driver status via API - create updated user model
      final updatedDriver = driver.copyWith(status: newStatus);
      await _userService.updateUser(updatedDriver);
      
      if (context.mounted) Navigator.pop(context); // Close loading
      
      await _loadAllData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status driver ${driver.name} diubah ke $newStatusText'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePickupStatus(BookingModel request) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Permintaan'),
        content: const Text('Apakah permintaan antar-jemput sudah selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                // Update booking status via API
                await _bookingService.updateBookingStatus(request.id, 'Selesai');
                
                if (context.mounted) Navigator.pop(context); // Close loading
                
                await _loadAllData();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permintaan antar-jemput diselesaikan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context); // Close loading
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}