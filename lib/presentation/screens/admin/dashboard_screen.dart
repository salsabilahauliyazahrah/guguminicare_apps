// lib/presentation/screens/admin/dashboard/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/services/dashboard_service.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  String _selectedPeriod = 'hari';
  String _chartType = 'line';
  
  // DATA REAL - GANTI INI
  Map<String, dynamic> _stats = {};
  List<BookingModel> _recentBookings = [];
  List<Map<String, dynamic>> _topServices = [];
  List<Map<String, dynamic>> _driverActivities = [];
  List<Map<String, dynamic>> _revenueData = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // TAMBAH INI
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        DashboardService.getDashboardStats(),
        DashboardService.getRecentBookings(),
        DashboardService.getTopServices(),
        DashboardService.getDriverActivities(),
        DashboardService.getRevenueData(),
      ]);
      
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentBookings = results[1] as List<BookingModel>;
        _topServices = results[2] as List<Map<String, dynamic>>;
        _driverActivities = results[3] as List<Map<String, dynamic>>;
        _revenueData = results[4] as List<Map<String, dynamic>>;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading dashboard: $e');
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: _isLoading 
        ? _buildLoadingState() // TAMBAH LOADING STATE
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan tanggal dan periode
                _buildDateHeader(),
                const SizedBox(height: 12),

                // Statistik Cards - SUDAH PAKAI DATA REAL
                _buildStatisticsCards(),
                const SizedBox(height: 12),

                // Charts Section - SUDAH PAKAI DATA REAL
                _buildChartsSection(),
                const SizedBox(height: 12),

                // Quick Actions - TETAP SAMA
                _buildQuickActions(),
                const SizedBox(height: 24),

                // Recent Bookings - SUDAH PAKAI DATA REAL
                _buildRecentBookings(),
                const SizedBox(height: 24),

                // Top Services - SUDAH PAKAI DATA REAL
                _buildTopServices(),
                const SizedBox(height: 24),

                // Driver Activities - SUDAH PAKAI DATA REAL
                _buildDriverActivities(),
                const SizedBox(height: 40),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton( // TAMBAH INI
        onPressed: _loadDashboardData,
        backgroundColor: AppColors.orangeMedium,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }


  // TAMBAH METHOD INI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.orangeMedium),
          const SizedBox(height: 16),
          const Text('Loading dashboard data...'),
        ],
      ),
    );
  }

  // 1. STATISTIK CARDS - UPDATE DENGAN DATA REAL
  Widget _buildStatisticsCards() {
    // ✅ Safe parsing untuk semua tipe data dari API
    int totalBookings = 0;
    final bookingsVal = _stats['todayBookings'];
    if (bookingsVal is int) totalBookings = bookingsVal;
    else if (bookingsVal is double) totalBookings = bookingsVal.toInt();
    else if (bookingsVal is String) totalBookings = int.tryParse(bookingsVal) ?? 0;
    else if (bookingsVal is num) totalBookings = bookingsVal.toInt();
    
    num monthlyRevenue = 0;
    final revenueVal = _stats['monthlyRevenue'];
    if (revenueVal is num) monthlyRevenue = revenueVal;
    else if (revenueVal is String) monthlyRevenue = num.tryParse(revenueVal) ?? 0;
    
    int totalCustomers = 0;
    final customersVal = _stats['totalCustomers'];
    if (customersVal is int) totalCustomers = customersVal;
    else if (customersVal is double) totalCustomers = customersVal.toInt();
    else if (customersVal is String) totalCustomers = int.tryParse(customersVal) ?? 0;
    else if (customersVal is num) totalCustomers = customersVal.toInt();
    
    double avgRating = 4.8;
    final ratingVal = _stats['averageRating'];
    if (ratingVal is double) avgRating = ratingVal;
    else if (ratingVal is int) avgRating = ratingVal.toDouble();
    else if (ratingVal is String) avgRating = double.tryParse(ratingVal) ?? 4.8;
    else if (ratingVal is num) avgRating = ratingVal.toDouble();
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: 'Booking Hari Ini',
          value: '$totalBookings',
          subtitle: 'total booking',
          icon: Icons.calendar_today,
          color: Colors.blue,
          gradient: true,
          onTap: () => context.push('/admin/bookings'),
        ),
        _buildStatCard(
          title: 'Pendapatan Bulan Ini',
          value: 'Rp ${NumberFormat('#,##0').format(monthlyRevenue)}',
          subtitle: 'total revenue',
          icon: Icons.attach_money,
          color: Colors.green,
          gradient: true,
          onTap: () => context.push('/admin/payments'),
        ),
        _buildStatCard(
          title: 'Total Pelanggan',
          value: '$totalCustomers',
          subtitle: 'registrasi',
          icon: Icons.people,
          color: Colors.purple,
          gradient: true,
          onTap: () => context.push('/admin/customers'),
        ),
        _buildStatCard(
          title: 'Rating Rata-rata',
          value: '${avgRating.toStringAsFixed(1)}',
          subtitle: '${_recentBookings.length} ulasan',
          icon: Icons.star,
          color: Colors.amber,
          gradient: true,
          onTap: () => context.go('/admin/reviews'),
        ),
      ],
    );
  }

  // 2. CHARTS - UPDATE DENGAN DATA REAL
  Widget _buildChartsSection() {
    final chartData = _revenueData.map((data) {
      final revenue = data['revenue'];
      // ✅ Safe parsing untuk semua tipe: int, double, String, dynamic
      int revenueValue = 0;
      if (revenue is int) {
        revenueValue = revenue;
      } else if (revenue is double) {
        revenueValue = revenue.toInt();
      } else if (revenue is String) {
        revenueValue = int.tryParse(revenue) ?? 0;
      } else if (revenue is num) {
        revenueValue = revenue.toInt();
      }
      
      return RevenueData(
        data['month']?.toString() ?? '',
        revenueValue, // ✅ Sekarang int
      );
    }).toList();

    return Card(      
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trend Pendapatan 6 Bulan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showChartOptions(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _chartType == 'line' 
                  ? _buildLineChart(chartData)
                  : _buildBarChart(chartData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<RevenueData> data) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        ),
      ),
      series: <CartesianSeries>[
        LineSeries<RevenueData, String>(
          dataSource: data,
          xValueMapper: (RevenueData revenue, _) => revenue.month,
          yValueMapper: (RevenueData revenue, _) => revenue.revenue,
          name: 'Pendapatan',
          color: AppColors.orangeMedium,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildBarChart(List<RevenueData> data) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<RevenueData, String>(
          dataSource: data,
          xValueMapper: (RevenueData revenue, _) => revenue.month,
          yValueMapper: (RevenueData revenue, _) => revenue.revenue,
          name: 'Pendapatan',
          color: AppColors.orangeMedium,
          width: 0.6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  // 3. RECENT BOOKINGS - UPDATE DENGAN DATA REAL
  Widget _buildRecentBookings() {
    if (_recentBookings.isEmpty) {
      return _buildEmptyState('Tidak ada booking terbaru', Icons.calendar_today);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Booking Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin/bookings'),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _recentBookings.map((booking) {
                return _buildBookingItem(booking);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingItem(BookingModel booking) {
    // Tentukan status color
    Color statusColor;
    String statusText;
    
    switch (booking.booking_status) {
      case 'menunggu':
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'diproses':
      case 'in_progress':
        statusColor = Colors.blue;
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
      default:
        statusColor = Colors.grey;
        statusText = booking.booking_status;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.booking_code,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Booking: ${booking.booking_date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${NumberFormat('#,##0').format(booking.totalPriceDouble)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. TOP SERVICES - UPDATE DENGAN DATA REAL
  Widget _buildTopServices() {
    if (_topServices.isEmpty) {
      return _buildEmptyState('Belum ada data layanan', Icons.spa);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Layanan Terpopuler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin/services'),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _topServices.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          service['name'] ?? 'Unknown Service',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${service['count']}x',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(service['revenue'])}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 5. DRIVER ACTIVITIES - UPDATE DENGAN DATA REAL
  Widget _buildDriverActivities() {
    if (_driverActivities.isEmpty) {
      return _buildEmptyState('Belum ada data driver', Icons.local_shipping);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Driver',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin/drivers'),
              child: const Text('Kelola Driver'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _driverActivities.map((driver) {
                return _buildDriverItem(driver);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverItem(Map<String, dynamic> driver) {
    Color statusColor;
    switch (driver['status']) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'on_delivery':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['driver_name'] ?? 'Unknown Driver',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driver['status_text'] ?? 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${driver['assigned'] ?? 0} tugas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${driver['completed'] ?? 0} selesai',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAMBAH METHOD INI
  Widget _buildEmptyState(String message, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.split(' ').first,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(icon, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          Icon(Icons.dashboard, color: AppColors.orangeMedium),
          const SizedBox(width: 12),
          const Text(
            'Dashboard Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            label: const Text('3'),
            child: const Icon(Icons.notifications),
          ),
          onPressed: () => context.push('/admin/notifications'),
          color: Colors.grey[700],
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/admin/settings'),
          color: Colors.grey[700],
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.homePrimaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.orangeMedium,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin Gugumini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@gugumini.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => context.go('/admin/dashboard'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: 'Manajemen Booking',
            onTap: () => context.push('/admin/bookings'),
          ),
          _buildDrawerItem(
            icon: Icons.spa,
            title: 'Layanan Grooming',
            onTap: () => context.push('/admin/services'),
          ),
          _buildDrawerItem(
            icon: Icons.pets,
            title: 'Pelanggan & Hewan',
            onTap: () => context.push('/admin/customers'),
          ),
          _buildDrawerItem(
            icon: Icons.local_shipping,
            title: 'Driver & Antar Jemput',
            onTap: () => context.push('/admin/drivers'),
          ),
          _buildDrawerItem(
            icon: Icons.attach_money,
            title: 'Pembayaran',
            onTap: () => context.push('/admin/payments'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            title: 'Laporan & Statistik',
            onTap: () => context.push('/admin/reports'),
          ),
          _buildDrawerItem(
            icon: Icons.star,
            title: 'Ulasan & Rating',
            onTap: () => context.push('/admin/reviews'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () => context.push('/admin/settings'),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // TODO: Implement logout
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_dateFormat.format(DateTime.now())} • ${DateFormat('EEEE').format(DateTime.now())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                });
              },
              items: ['hari', 'minggu', 'bulan', 'tahun']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool gradient = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight( // <-- TAMBAHKAN INI
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    if (gradient)
                      Icon(Icons.trending_up, color: color, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                
                Expanded( // <-- TAMBAHKAN EXPANDED
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChartOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.blue),
                title: const Text('Tampilkan sebagai Bar Chart'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _chartType = 'bar';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.green),
                title: const Text('Tampilkan sebagai Line Chart'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _chartType = 'line';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.purple),
                title: const Text('Ekspor Grafik sebagai Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  _exportChart();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.orange),
                title: const Text('Detail Statistik'),
                onTap: () {
                  Navigator.pop(context);
                  _showChartDetails();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Tutup'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChartDetails() {
    showDialog(
      context: context,
      builder: (context) {
        // Hitung total dan rata-rata - SAFE PARSING
        num totalRevenue = 0;
        for (var data in _revenueData) {
          final revenue = data['revenue'];
          if (revenue is int) {
            totalRevenue += revenue;
          } else if (revenue is double) {
            totalRevenue += revenue;
          } else if (revenue is String) {
            totalRevenue += num.tryParse(revenue) ?? 0;
          } else if (revenue is num) {
            totalRevenue += revenue;
          }
        }
        
        final averageRevenue = _revenueData.isNotEmpty 
            ? totalRevenue ~/ _revenueData.length 
            : 0;

        return AlertDialog(
          title: const Text('Detail Statistik Pendapatan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data Pendapatan:'),
                const SizedBox(height: 16),
                ..._revenueData.map((data) {
                  final revenue = data['revenue'];
                  // ✅ Safe parsing untuk semua tipe
                  int revenueValue = 0;
                  if (revenue is int) {
                    revenueValue = revenue;
                  } else if (revenue is double) {
                    revenueValue = revenue.toInt();
                  } else if (revenue is String) {
                    revenueValue = int.tryParse(revenue) ?? 0;
                  } else if (revenue is num) {
                    revenueValue = revenue.toInt();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['month']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500)
                        ),
                        Text(
                          'Rp ${NumberFormat('#,##0').format(revenueValue)}'
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Rp ${NumberFormat('#,##0').format(totalRevenue.toInt())}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rata-rata:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Rp ${NumberFormat('#,##0').format(averageRevenue)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _exportChart() async {
    final status = await Permission.storage.request();
    
    if (status.isGranted) {
      final GlobalKey chartKey = GlobalKey();
      
      // Buat chart data - ✅ Safe parsing
      final chartData = _revenueData.map((data) {
        final revenue = data['revenue'];
        int revenueValue = 0;
        if (revenue is int) {
          revenueValue = revenue;
        } else if (revenue is double) {
          revenueValue = revenue.toInt();
        } else if (revenue is String) {
          revenueValue = int.tryParse(revenue) ?? 0;
        } else if (revenue is num) {
          revenueValue = revenue.toInt();
        }
        
        return RevenueData(
          data['month']?.toString() ?? '',
          revenueValue,
        );
      }).toList();
      
      showDialog(
        context: context,
        builder: (context) => RepaintBoundary(
          key: chartKey,
          child: AlertDialog(
            title: const Text('Export Chart'),
            content: SizedBox(
              width: 300,
              height: 200,
              child: _chartType == 'line' 
                  ? _buildLineChart(chartData)
                  : _buildBarChart(chartData),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final boundary = chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                  if (boundary != null) {
                    final image = await boundary.toImage();
                    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                    final bytes = byteData?.buffer.asUint8List();
                    
                    if (bytes != null) {
                      final result = await ImageGallerySaver.saveImage(bytes);
                      
                      if (result['isSuccess']) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Grafik berhasil disimpan ke galeri'),
                            ),
                          );
                        }
                      }
                    }
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Export'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin penyimpanan diperlukan untuk export grafik'),
        ),
      );
    }
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.add,
        'label': 'Tambah Layanan',
        'color': Colors.blue,
        'route': '/admin/services/add',
      },
      {
        'icon': Icons.person_add,
        'label': 'Tambah Driver',
        'color': Colors.green,
        'route': '/admin/drivers/add',
      },
      {
        'icon': Icons.receipt,
        'label': 'Buat Laporan',
        'color': Colors.purple,
        'route': '/admin/reports',
      },
      {
        'icon': Icons.notifications_active,
        'label': 'Kirim Notifikasi',
        'color': Colors.amber,
        'route': '/admin/notifications/send',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        // UBAH: Gunakan Row dengan Expanded, bukan GridView
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => context.push(action['route']),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: action['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: action['color'].withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          action['icon'],
                          size: 28,
                          color: action['color'],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          action['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11, // PERKECIL KE 11
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

}

// Model untuk chart data
class RevenueData {
  final String month;
  final num revenue; 

  RevenueData(this.month, this.revenue);
}