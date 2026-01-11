import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  
  // Data booking dari database
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = StorageHelper.getString('user_id');
      if (userId == null || userId.isEmpty) {
        throw Exception('User belum login');
      }

      final bookingService = BookingService();
      final bookings = await bookingService.getBookingsByUserId(userId);
      
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading bookings: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Convert BookingModel to Map for UI compatibility
  Map<String, dynamic> _bookingToMap(BookingModel booking) {
    Color statusColor;
    String statusText;
    
    switch (booking.booking_status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        statusColor = AppColors.orangeMedium;
        statusText = 'Menunggu Konfirmasi';
        break;
      case 'diproses':
      case 'accepted':
      case 'in_progress':
        statusColor = Colors.green;
        statusText = 'Sedang Diproses';
        break;
      case 'selesai':
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Selesai';
        break;
      case 'dibatalkan':
      case 'cancelled':
        statusColor = AppColors.redVibrant;
        statusText = 'Dibatalkan';
        break;
      default:
        statusColor = AppColors.grey600;
        statusText = booking.booking_status;
    }

    return {
      'id': booking.id,
      'booking_code': booking.booking_code,
      'pet_id': booking.pet_id,
      'pet_name': booking.pet_id, // Will be enhanced later with pet lookup
      'pet_type': '',
      'service_id': booking.service_id,
      'service_name': booking.service_id, // Will be enhanced later with service lookup
      'service_date': booking.bookingDateOrNull ?? DateTime.now(),
      'service_time': booking.booking_time,
      'total_price': booking.totalPriceDouble.toInt(),
      'status': booking.booking_status,
      'status_text': statusText,
      'status_color': statusColor,
      'service_method': booking.service_method,
      'payment_method': booking.payment_method,
      'special_notes': booking.special_notes,
    };
  }

  List<Map<String, dynamic>> get _allBookingsMapped => 
      _allBookings.map((b) => _bookingToMap(b)).toList();

  List<Map<String, dynamic>> get upcomingBookings => _allBookingsMapped
      .where((booking) => 
          booking['status'] == 'diproses' || 
          booking['status'] == 'accepted' || 
          booking['status'] == 'in_progress')
      .toList();

  List<Map<String, dynamic>> get historyBookings => _allBookingsMapped
      .where((booking) => 
          booking['status'] == 'selesai' || 
          booking['status'] == 'completed' ||
          booking['status'] == 'dibatalkan' || 
          booking['status'] == 'cancelled')
      .toList();

  List<Map<String, dynamic>> get pendingBookings => _allBookingsMapped
      .where((booking) => 
          booking['status'] == 'menunggu' || 
          booking['status'] == 'pending')
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Booking Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMedium, // WARNA BARU
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.orangeRedGradient, // GRADASI BARU
              boxShadow: [
                BoxShadow(
                  color: AppColors.orangeMedium.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => context.go('/notification'),
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.redVibrant, // WARNA BARU
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              child: TabBar(
                controller: _tabController,                
                labelColor: AppColors.redVibrant,
                unselectedLabelColor: AppColors.grey800,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Akan Datang'),
                  Tab(text: 'Riwayat'),
                  Tab(text: 'Menunggu'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.orangeMedium),
                  const SizedBox(height: 16),
                  const Text('Memuat data booking...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.redVibrant),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadBookings,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeMedium,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          color: AppColors.orangeMedium,
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(context, upcomingBookings, 'upcoming'),
              _buildBookingsList(context, historyBookings, 'history'),
              _buildBookingsList(context, pendingBookings, 'pending'),
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orangeMedium, // WARNA BARU
        unselectedItemColor: AppColors.grey600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        elevation: 0,
        onTap: (index) => _onBottomNavTap(context, index),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.home_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, size: 24, color: Colors.white),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.pets_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 24, color: Colors.white),
            ),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.calendar_today_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, size: 24, color: Colors.white),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.person_outline, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 24, color: Colors.white),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/pets');
        break;
      case 2:
        // Sudah di halaman Bookings
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.homePrimaryGradient, // GRADASI BARU
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeMedium.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.push('/booking-new'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        enableFeedback: false,
        mouseCursor: SystemMouseCursors.click,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<Map<String, dynamic>> bookings, String type) {
    if (bookings.isEmpty) {
      return _buildEmptyState(context, type);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking, type);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking, String type) {
    final isUpcoming = type == 'upcoming';
    final isHistory = type == 'history';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(
          '/booking-detail', // ✅ HANYA '/booking-detail' (tanpa ID)
          extra: booking,
        ),

        
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.orangeMedium.withOpacity(0.1),
        highlightColor: AppColors.creamYellow.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan ID Booking dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking['id'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: booking['status'] == 'pending' || booking['status'] == 'in_progress'
                          ? AppColors.homePrimaryGradient // GRADASI BARU
                          : null,
                      color: booking['status_color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: booking['status_color'].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      booking['status_text'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: booking['status_color'],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Informasi Booking
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Hewan
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: booking['pet_type'] == 'Kucing'
                          ? LinearGradient(
                              colors: [AppColors.creamYellow, AppColors.orangeMedium],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [AppColors.orangeMedium, AppColors.orangeRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      booking['pet_type'] == 'Kucing' ? Icons.pets : Icons.psychology,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Detail Booking
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['service_name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking['pet_name']} • ${booking['pet_type']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Tanggal dan Waktu
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppColors.orangeMedium),
                            const SizedBox(width: 4),
                            Text(
                              _dateFormat.format(booking['service_date']),
                              style: TextStyle(fontSize: 13, color: AppColors.grey800),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: AppColors.orangeMedium),
                            const SizedBox(width: 4),
                            Text(
                              booking['service_time'],
                              style: TextStyle(fontSize: 13, color: AppColors.grey800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Metode Layanan
                        Row(
                          children: [
                            Icon(
                              booking['service_method'] == 'Antar Jemput'
                                  ? Icons.directions_car
                                  : booking['service_method'] == 'Home Service'
                                      ? Icons.home
                                      : Icons.store,
                              size: 14,
                              color: AppColors.orangeMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              booking['service_method'],
                              style: TextStyle(fontSize: 13, color: AppColors.grey800),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.payment, size: 14, color: AppColors.orangeMedium),
                            const SizedBox(width: 4),
                            Text(
                              booking['payment_method'],
                              style: TextStyle(fontSize: 13, color: AppColors.grey800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Informasi Tambahan
                        if (booking['driver_status'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.creamYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.orangeMedium.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_shipping, size: 14, color: AppColors.orangeRed),
                                const SizedBox(width: 4),
                                Text(
                                  booking['driver_status'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.orangeRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (booking['estimated_pickup'] != null)
                                  Text(
                                    ' • ${booking['estimated_pickup']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        if (booking['rating'] != null)
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: AppColors.orangeMedium),
                              const SizedBox(width: 4),
                              Text(
                                '${booking['rating']}/5',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.orangeMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total Harga
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.orangeMedium.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Biaya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey800,
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,##0').format(booking['total_price'])}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tombol Aksi
              if (isUpcoming || type == 'pending')
                _buildActionButtons(context, booking, type),
              
              if (isHistory && booking['status'] == 'completed' && booking['rating'] == null)
                _buildRatingButton(context, booking),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> booking, String type) {
    final isUpcoming = type == 'upcoming';
    final isPending = type == 'pending';

    return Row(
      children: [
        if (isUpcoming && booking['service_method'] == 'Antar Jemput')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.go('/track-driver/${booking['id']}'),
              icon: Icon(Icons.location_on, size: 18, color: AppColors.orangeMedium),
              label: Text('Lacak Driver', style: TextStyle(color: AppColors.orangeMedium)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.orangeMedium,
                side: BorderSide(color: AppColors.orangeMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        
        if (isUpcoming && booking['service_method'] == 'Antar Jemput')
          const SizedBox(width: 8),

        if (isPending)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, booking),
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              label: const Text('Batalkan', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        
        if (isUpcoming)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.homePrimaryGradient, // GRADASI BARU
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.redVibrant.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    '/booking-detail', // ✅ HANYA '/booking-detail'
                    extra: booking,
                  );
                },
                icon: const Icon(Icons.info_outline, size: 18, color: Colors.white),
                label: const Text('Detail', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingButton(BuildContext context, Map<String, dynamic> booking) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.homePrimaryGradient, // GRADASI BARU
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () => _showRatingDialog(context, booking),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: Colors.white,
        ),
        child: const Text('Berikan Rating'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String type) {
    String title, subtitle, icon;
    
    switch (type) {
      case 'upcoming':
        title = 'Tidak Ada Booking Mendatang';
        subtitle = 'Anda belum memiliki jadwal grooming yang akan datang';
        icon = '📅';
        break;
      case 'history':
        title = 'Belum Ada Riwayat';
        subtitle = 'Anda belum pernah melakukan booking grooming';
        icon = '📋';
        break;
      case 'pending':
        title = 'Tidak Ada Pending';
        subtitle = 'Semua booking Anda sudah dikonfirmasi';
        icon = '⏳';
        break;
      default:
        title = 'Tidak Ada Data';
        subtitle = 'Mulai booking grooming pertama Anda';
        icon = '🐾';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.homePrimaryGradient, // GRADASI BARU
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey800,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // BUTTON "Booking Sekarang" dengan GRADASI SAMA seperti button "Detail"
          Container(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
            decoration: BoxDecoration(
              gradient: AppColors.homePrimaryGradient, // GRADASI SAMA PERSIS
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.redVibrant.withOpacity(0.3), // SHADOW SAMA PERSIS
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/booking-new'),
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Booking Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                   
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // SAMA
                foregroundColor: Colors.white, // SAMA
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // SAMA
                ),
                elevation: 0, // SAMA
                shadowColor: Colors.transparent, // SAMA
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Batalkan Booking?', style: TextStyle(color: AppColors.black)),
        content: Text('Apakah Anda yakin ingin membatalkan booking ini?', 
          style: TextStyle(color: AppColors.grey800)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak', style: TextStyle(color: AppColors.grey800)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Booking berhasil dibatalkan'),
                    backgroundColor: AppColors.redVibrant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Berikan Rating', style: TextStyle(color: AppColors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bagaimana pengalaman grooming Anda?', 
              style: TextStyle(color: AppColors.grey800)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: index < 4 ? AppColors.orangeMedium : AppColors.grey300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ulasan (opsional)',
                labelStyle: TextStyle(color: AppColors.grey700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.orangeMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.orangeMedium, width: 2),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.grey800)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.homePrimaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Terima kasih atas ulasan Anda!'),
                    backgroundColor: AppColors.orangeMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}