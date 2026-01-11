// lib/presentation/screens/admin/bookings/admin_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:tugas_akhir/presentation/screens/services/notification_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  
  // Services
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final PetService _petService = PetService();
  final ServiceService _serviceService = ServiceService();
  final NotificationService _notificationService = NotificationService();
  
  String _selectedFilter = 'semua';
  String _selectedTimeRange = 'semua';
  
  // Data booking dari database
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];
  
  // Cache untuk data terkait
  Map<String, UserModel> _usersCache = {};
  Map<String, PetModel> _petsCache = {};
  Map<String, ServiceModel> _servicesCache = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  
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
      // Load bookings dan data pendukung secara paralel
      final results = await Future.wait([
        _bookingService.getAllBookings(),
        _userService.getUsersByRole('customer'),
        _petService.getAllPets(),
        _serviceService.getAllServices(),
      ]);
      
      final bookings = results[0] as List<BookingModel>;
      final users = results[1] as List<UserModel>;
      final pets = results[2] as List<PetModel>;
      final services = results[3] as List<ServiceModel>;
      
      // Buat cache untuk lookup cepat
      _usersCache = {for (var u in users) u.id: u};
      _petsCache = {for (var p in pets) p.id: p};
      _servicesCache = {for (var s in services) s.id: s};
      
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
      
      _applyFilters();
      
      print('✅ Loaded ${bookings.length} bookings from database');
      
    } catch (e) {
      print('❌ Error loading bookings: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data booking: $e';
      });
    }
  }
  
  // Helper untuk mendapatkan nama customer
  String _getCustomerName(String userId) {
    return _usersCache[userId]?.name ?? 'Unknown Customer';
  }
  
  // Helper untuk mendapatkan nama pet
  String _getPetName(String petId) {
    return _petsCache[petId]?.name ?? 'Unknown Pet';
  }
  
  // Helper untuk mendapatkan nama service
  String _getServiceName(String serviceId) {
    return _servicesCache[serviceId]?.name ?? 'Unknown Service';
  }
  
  // Helper untuk status display
  Map<String, dynamic> _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return {'text': 'Menunggu Konfirmasi', 'color': Colors.orange};
      case 'diproses':
      case 'accepted':
      case 'in_progress':
        return {'text': 'Sedang Diproses', 'color': Colors.blue};
      case 'selesai':
      case 'completed':
        return {'text': 'Selesai', 'color': Colors.purple};
      case 'dibatalkan':
      case 'rejected':
      case 'cancelled':
        return {'text': 'Dibatalkan', 'color': Colors.red};
      case 'diterima':
        return {'text': 'Diterima', 'color': Colors.green};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }
  
  // Helper untuk service method display
  String _getServiceMethodDisplay(String method) {
    switch (method.toLowerCase()) {
      case 'salon':
        return 'Datang ke Salon';
      case 'home':
        return 'Home Service';
      case 'pickup':
        return 'Antar Jemput';
      default:
        return method;
    }
  }
  
  void _applyFilters() {
    _filteredBookings = List.from(_allBookings);
    
    // Apply status filter
    if (_selectedFilter != 'semua') {
      _filteredBookings = _filteredBookings.where((booking) {
        final status = booking.booking_status.toLowerCase();
        switch (_selectedFilter) {
          case 'pending':
            return status == 'menunggu' || status == 'pending';
          case 'accepted':
            return status == 'diterima' || status == 'accepted';
          case 'in_progress':
            return status == 'diproses' || status == 'in_progress';
          case 'completed':
            return status == 'selesai' || status == 'completed';
          case 'rejected':
            return status == 'dibatalkan' || status == 'rejected' || status == 'cancelled';
          default:
            return true;
        }
      }).toList();
    }
    
    // Apply time range filter
    _filteredBookings = _filteredBookings.where((booking) {
      final bookingDate = DateTime.tryParse(booking.booking_date) ?? DateTime.now();
      final now = DateTime.now();
      
      switch (_selectedTimeRange) {
        case 'hari-ini':
          return bookingDate.year == now.year &&
                 bookingDate.month == now.month &&
                 bookingDate.day == now.day;
        case 'minggu-ini':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          return bookingDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                 bookingDate.isBefore(endOfWeek);
        case 'bulan-ini':
          return bookingDate.year == now.year &&
                 bookingDate.month == now.month;
        case 'semua':
        default:
          return true;
      }
    }).toList();
    
    // Sort by date (newest first)
    _filteredBookings.sort((a, b) {
      final dateA = DateTime.tryParse(a.created_at) ?? DateTime.now();
      final dateB = DateTime.tryParse(b.created_at) ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    
    setState(() {});
  }
  
  int _getBookingCountByStatus(String status) {
    return _allBookings.where((booking) {
      final bookingStatus = booking.booking_status.toLowerCase();
      switch (status) {
        case 'pending':
          return bookingStatus == 'menunggu' || bookingStatus == 'pending';
        case 'in_progress':
          return bookingStatus == 'diproses' || bookingStatus == 'in_progress';
        case 'completed':
          return bookingStatus == 'selesai' || bookingStatus == 'completed';
        default:
          return bookingStatus == status;
      }
    }).length;
  }
  
  int _getTodayBookingsCount() {
    final now = DateTime.now();
    return _allBookings.where((booking) {
      final bookingDate = DateTime.tryParse(booking.booking_date) ?? DateTime.now();
      return bookingDate.year == now.year &&
             bookingDate.month == now.month &&
             bookingDate.day == now.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Manajemen Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            color: AppColors.orangeMedium,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            color: Colors.grey[700],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportBookings,
            color: Colors.grey[700],
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Header dengan filter
                    _buildFilterHeader(),
                    
                    // List booking
                    Expanded(
                      child: _filteredBookings.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadAllData,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: _filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = _filteredBookings[index];
                                  return _buildBookingCard(booking);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addManualBooking(),
        backgroundColor: AppColors.orangeMedium,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.orangeMedium),
          const SizedBox(height: 16),
          const Text('Memuat data booking...'),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'semua' 
              ? 'Belum ada booking untuk ditampilkan'
              : 'Tidak ada booking dengan status "${_getStatusDisplayName()}"',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_selectedFilter != 'semua')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'semua';
                  _applyFilters();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tampilkan Semua Booking'),
            ),
        ],
      ),
    );
  }

  String _getStatusDisplayName() {
    switch (_selectedFilter) {
      case 'semua': return 'Semua Status';
      case 'pending': return 'Menunggu Konfirmasi';
      case 'accepted': return 'Diterima';
      case 'in_progress': return 'Sedang Diproses';
      case 'completed': return 'Selesai';
      case 'rejected': return 'Ditolak';
      default: return _selectedFilter;
    }
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistik cepat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                label: 'Pending',
                value: _getBookingCountByStatus('pending').toString(),
                color: Colors.orange,
              ),
              _buildQuickStat(
                label: 'Diproses',
                value: _getBookingCountByStatus('in_progress').toString(),
                color: Colors.blue,
              ),
              _buildQuickStat(
                label: 'Hari Ini',
                value: _getTodayBookingsCount().toString(),
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filter bar
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.filter_list, size: 16),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                          _applyFilters();
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'semua', child: Text('Semua Status')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'accepted', child: Text('Diterima')),
                        DropdownMenuItem(value: 'in_progress', child: Text('Diproses')),
                        DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                        DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeRange,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeRange = newValue!;
                        _applyFilters();
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'hari-ini', child: Text('Hari Ini')),
                      DropdownMenuItem(value: 'minggu-ini', child: Text('Minggu Ini')),
                      DropdownMenuItem(value: 'bulan-ini', child: Text('Bulan Ini')),
                      DropdownMenuItem(value: 'semua', child: Text('Semua Waktu')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusDisplay = _getStatusDisplay(booking.booking_status);
    final bookingDate = DateTime.tryParse(booking.booking_date) ?? DateTime.now();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewBookingDetail(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan ID dan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.booking_code.isNotEmpty ? booking.booking_code : booking.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
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
              
              // Detail booking
              Row(
                children: [
                  // Customer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCustomerName(booking.user_id),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hewan: ${_getPetName(booking.pet_id)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Layanan: ${_getServiceName(booking.service_id)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Date & time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _dateFormat.format(bookingDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        booking.booking_time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(booking.totalPriceDouble)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Footer dengan action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Metode & driver
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode: ${_getServiceMethodDisplay(booking.service_method)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (booking.driver_id.isNotEmpty)
                        Text(
                          'Driver: ${booking.driver_id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  
                  // Action buttons berdasarkan status
                  Row(
                    children: _buildActionButtons(booking),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BookingModel booking) {
    final List<Widget> buttons = [];
    final status = booking.booking_status.toLowerCase();
    
    if (status == 'menunggu' || status == 'pending') {
      buttons.addAll([
        IconButton(
          icon: const Icon(Icons.check, size: 20),
          onPressed: () => _acceptBooking(booking),
          color: Colors.green,
          tooltip: 'Terima Booking',
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => _rejectBooking(booking),
          color: Colors.red,
          tooltip: 'Tolak Booking',
        ),
        IconButton(
          icon: const Icon(Icons.info, size: 20),
          onPressed: () => _viewBookingDetail(booking),
          color: Colors.blue,
          tooltip: 'Detail',
        ),
      ]);
    } else if (status == 'diterima' || status == 'accepted') {
      buttons.addAll([
        IconButton(
          icon: const Icon(Icons.play_arrow, size: 20),
          onPressed: () => _startGrooming(booking),
          color: Colors.blue,
          tooltip: 'Mulai Grooming',
        ),
        IconButton(
          icon: const Icon(Icons.schedule, size: 20),
          onPressed: () => _rescheduleBooking(booking),
          color: Colors.orange,
          tooltip: 'Reschedule',
        ),
      ]);
    } else if (status == 'diproses' || status == 'in_progress') {
      buttons.addAll([
        IconButton(
          icon: const Icon(Icons.check_circle, size: 20),
          onPressed: () => _completeGrooming(booking),
          color: Colors.green,
          tooltip: 'Selesaikan Grooming',
        ),
      ]);
    } else if (status == 'selesai' || status == 'completed') {
      buttons.addAll([
        IconButton(
          icon: const Icon(Icons.receipt, size: 20),
          onPressed: () => _generateReceipt(booking),
          color: Colors.purple,
          tooltip: 'Buat Nota',
        ),
      ]);
    }
    
    return buttons;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Lanjutan'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter by service
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jenis Layanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Premium Grooming'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Basic Grooming'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Spa Treatment'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Medical Grooming'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Special Package'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Filter by payment status
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Status Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Lunas'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Dibatalkan'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Reset filters
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'semua';
                      _selectedTimeRange = 'hari-ini';
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset Semua Filter'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Terapkan Filter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportBookings() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ekspor Data Booking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Filter: ${_getStatusDisplayName()} | ${_getTimeRangeDisplayName()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Excel Option
              _buildExportOption(
                icon: Icons.table_chart,
                title: 'Excel Spreadsheet',
                subtitle: 'Format untuk analisis data',
                color: Colors.green,
                format: 'excel',
              ),
              
              const SizedBox(height: 12),
              
              // CSV Option
              _buildExportOption(
                icon: Icons.table_rows,
                title: 'CSV File',
                subtitle: 'Format ringan untuk database',
                color: Colors.blue,
                format: 'csv',
              ),
              
              const SizedBox(height: 24),                     
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String format,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _processExport(format, false);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _exportWithOptions(bool exportAll) async {
    final format = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(exportAll ? 'Ekspor Semua Data' : 'Pilih Format Ekspor'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'excel'),
              child: const ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Excel Spreadsheet'),
                subtitle: Text('Cocok untuk analisis data'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'csv'),
              child: const ListTile(
                leading: Icon(Icons.table_rows, color: Colors.blue),
                title: Text('CSV File'),
                subtitle: Text('Cocok untuk database'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'pdf'),
              child: const ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('PDF Report'),
                subtitle: Text('Cocok untuk dokumen'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: const Center(
                child: Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        );
      },
    );
    
    if (format != null) {
      await _processExport(format, exportAll);
    }
  }

  Future<void> _processExport(String format, bool exportAll) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeMedium),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sedang mengekspor...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exportAll 
                  ? 'Mengekspor semua data booking'
                  : 'Mengekspor data dengan filter saat ini',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    
    // Simulasi proses export
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      Navigator.pop(context); // Tutup loading dialog
      _showExportSuccess(format, exportAll);
    }
  }

  void _showExportSuccess(String format, bool exportAll) {
    final dataToExport = exportAll ? _allBookings : _filteredBookings;
    final count = dataToExport.length;
    final totalRevenue = dataToExport.fold<double>(0, (sum, booking) => sum + booking.totalPriceDouble);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              format == 'excel' ? Icons.table_chart :
              format == 'csv' ? Icons.table_rows :
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export $format Berhasil!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$count data booking (Rp ${NumberFormat('#,##0').format(totalRevenue)})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: format == 'excel' ? Colors.green :
                       format == 'csv' ? Colors.blue : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }



  // ignore: unused_element
  void _copySummaryToClipboard(bool exportAll) {
    final dataToExport = exportAll ? _allBookings : _filteredBookings;
    final totalRevenue = dataToExport.fold<double>(0, (sum, booking) => sum + booking.totalPriceDouble);
    
    final summary = '''
Data Booking Pet Grooming
${exportAll ? 'Semua Data' : 'Filter: ${_getStatusDisplayName()} | ${_getTimeRangeDisplayName()}'}
Tanggal: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}

Statistik:
- Total Booking: ${dataToExport.length}
- Total Pendapatan: Rp ${NumberFormat('#,##0').format(totalRevenue)}
- Rata-rata per Booking: Rp ${NumberFormat('#,##0').format(dataToExport.isNotEmpty ? totalRevenue / dataToExport.length : 0)}

Distribusi Status:
- Pending: ${dataToExport.where((b) => b.booking_status.toLowerCase() == 'pending' || b.booking_status.toLowerCase() == 'menunggu').length}
- Diterima: ${dataToExport.where((b) => b.booking_status.toLowerCase() == 'accepted' || b.booking_status.toLowerCase() == 'diterima').length}
- Diproses: ${dataToExport.where((b) => b.booking_status.toLowerCase() == 'in_progress' || b.booking_status.toLowerCase() == 'diproses').length}
- Selesai: ${dataToExport.where((b) => b.booking_status.toLowerCase() == 'completed' || b.booking_status.toLowerCase() == 'selesai').length}
- Ditolak: ${dataToExport.where((b) => b.booking_status.toLowerCase() == 'rejected' || b.booking_status.toLowerCase() == 'ditolak').length}
''';
    
    // Copy to clipboard
    debugPrint(summary);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ringkasan data disalin ke clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getTimeRangeDisplayName() {
    switch (_selectedTimeRange) {
      case 'hari-ini':
        return 'Hari Ini';
      case 'minggu-ini':
        return 'Minggu Ini';
      case 'bulan-ini':
        return 'Bulan Ini';
      case 'semua':
        return 'Semua Waktu';
      default:
        return _selectedTimeRange;
    }
  }

  // Tambahkan method untuk menambah booking
  void _addManualBooking() async {
    // Navigasi ke halaman tambah booking
    final result = await context.push('/admin/bookings/add');
    
    // Jika ada result (booking baru), refresh data
    if (result != null) {
      _loadAllData();
    }
  }

  void _viewBookingDetail(BookingModel booking) async {
    final result = await context.push<Map<String, dynamic>>(
      '/admin/bookings/${booking.id}',
      extra: booking.toJson(),
    );
    
    // Handle jika booking dihapus atau diupdate dari detail screen
    if (result != null) {
      _loadAllData();
    }
  }

  void _acceptBooking(BookingModel booking) {
    // Jika metode booking adalah "Antar Jemput", tampilkan dialog pilih driver
    if (booking.service_method.toLowerCase() == 'antar jemput' || 
        booking.service_method.toLowerCase() == 'pickup') {
      _assignDriverForPickup(booking);
    } else {
      // Untuk metode lain, langsung terima booking
      _acceptBookingDirectly(booking);
    }
  }

  Future<void> _acceptBookingDirectly(BookingModel booking) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Booking'),
        content: const Text('Apakah Anda yakin ingin menerima booking ini?'),
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
                // Update status booking via API
                await _bookingService.updateBookingStatus(booking.id, 'Diterima');
                
                if (context.mounted) Navigator.pop(context); // Close loading
                
                // Refresh data
                await _loadAllData();

                // Send notification to user
                try {
                  await _notificationService.sendPushNotification(
                    userId: booking.user_id,
                    title: 'Booking Diterima',
                    message: 'Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} telah diterima.',
                    type: 'booking_status',
                    metadata: {'booking_id': booking.id, 'status': 'diterima'},
                  );
                } catch (e) {
                  print('⚠️ Notification error (accept): $e');
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} diterima'),
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
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignDriverForPickup(BookingModel booking) async {
    // Load drivers from database
    List<UserModel> availableDrivers = [];
    try {
      availableDrivers = await _userService.getUsersByRole('driver');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data driver: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (availableDrivers.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada driver tersedia'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    String? selectedDriverId;

    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terima Booking & Tugaskan Driver'),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                children: [
                  // Booking info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Customer: ${_getCustomerName(booking.user_id)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.pets, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hewan: ${_getPetName(booking.pet_id)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Waktu: ${booking.booking_time}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Driver selection
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Driver:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // List of drivers from database
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = availableDrivers[index];
                        final isSelected = selectedDriverId == driver.id;
                        
                        return InkWell(
                          onTap: () {
                            setStateDialog(() {
                              selectedDriverId = driver.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isSelected ? Colors.blue[50] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? Colors.blue : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    backgroundImage: driver.profile_picture.isNotEmpty 
                                        ? NetworkImage(driver.profile_picture) 
                                        : null,
                                    child: driver.profile_picture.isEmpty 
                                        ? Icon(Icons.person, color: Colors.blue[700]) 
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          driver.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: isSelected ? Colors.blue[700] : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          driver.phone,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? Colors.green : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: selectedDriverId == null
                    ? null
                    : () async {
                        Navigator.pop(context);
                        
                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        try {
                          // Find selected driver
                          final selectedDriver = availableDrivers.firstWhere(
                            (driver) => driver.id == selectedDriverId,
                          );
                          
                          // Update booking with driver assignment via API
                          final success = await _bookingService.updateBooking(
                            booking.id,
                            {
                              'booking_status': 'Diterima',
                              'driver_id': selectedDriverId,
                            },
                          );
                          
                          if (context.mounted) Navigator.pop(context); // Close loading
                          
                          if (success) {
                            // Refresh data
                            await _loadAllData();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} diterima'),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Driver ${selectedDriver.name} telah ditugaskan',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                            // Send notification about acceptance and driver assignment
                            try {
                              await _notificationService.sendPushNotification(
                                userId: booking.user_id,
                                title: 'Booking Diterima & Driver Ditugaskan',
                                message: 'Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} diterima. Driver ${selectedDriver.name} telah ditugaskan.',
                                type: 'booking_status',
                                metadata: {'booking_id': booking.id, 'status': 'diterima', 'driver_id': selectedDriver.id},
                              );
                            } catch (e) {
                              print('⚠️ Notification error (assign driver): $e');
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menerima booking'),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Terima & Tugaskan Driver'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _rejectBooking(BookingModel booking) async {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap masukkan alasan penolakan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                // Update booking status via API
                final success = await _bookingService.updateBooking(
                  booking.id,
                  {
                    'booking_status': 'Ditolak',
                    'rejection_reason': reasonController.text,
                  },
                );
                
                if (context.mounted) Navigator.pop(context); // Close loading
                
                if (success) {
                  await _loadAllData();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} ditolak'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  // Send notification about rejection
                  try {
                    await _notificationService.sendPushNotification(
                      userId: booking.user_id,
                      title: 'Booking Ditolak',
                      message: 'Booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} ditolak. Alasan: ${reasonController.text}',
                      type: 'booking_status',
                      metadata: {'booking_id': booking.id, 'status': 'ditolak', 'reason': reasonController.text},
                    );
                  } catch (e) {
                    print('⚠️ Notification error (reject): $e');
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menolak booking'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _startGrooming(BookingModel booking) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Grooming'),
        content: const Text('Apakah Anda ingin memulai proses grooming untuk booking ini?'),
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
                await _bookingService.updateBookingStatus(booking.id, 'Diproses');
                
                if (context.mounted) Navigator.pop(context); // Close loading
                
                await _loadAllData();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Memulai grooming untuk ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id}'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
                // Send notification about grooming start
                try {
                  await _notificationService.sendPushNotification(
                    userId: booking.user_id,
                    title: 'Proses Grooming Dimulai',
                    message: 'Grooming untuk booking ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id} telah dimulai.',
                    type: 'booking_status',
                    metadata: {'booking_id': booking.id, 'status': 'diproses'},
                  );
                } catch (e) {
                  print('⚠️ Notification error (start grooming): $e');
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
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mulai Grooming'),
          ),
        ],
      ),
    );
  }

  void _rescheduleBooking(BookingModel booking) {
    // Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur reschedule booking'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _completeGrooming(BookingModel booking) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Grooming'),
        content: const Text('Apakah Anda telah menyelesaikan proses grooming untuk booking ini?'),
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
                await _bookingService.updateBookingStatus(booking.id, 'Selesai');
                
                if (context.mounted) Navigator.pop(context); // Close loading
                
                await _loadAllData();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Grooming selesai untuk ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id}'),
                      backgroundColor: Colors.purple,
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
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(BookingModel booking) {
    // Implement generate receipt functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuat nota untuk ${booking.booking_code.isNotEmpty ? booking.booking_code : booking.id}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.purple,
      ),
    );
  }
}