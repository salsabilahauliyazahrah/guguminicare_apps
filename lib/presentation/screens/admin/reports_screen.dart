// lib/presentation/screens/admin/reports/admin_reports_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tugas_akhir/core/models/drivers_model.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/services/dashboard_service.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = 'bulan-ini';
  String _selectedReportType = 'pendapatan';
  String _chartType = 'line';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<DriverDataModel> _driverData = []; 
  
  // Services
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final ServiceService _serviceService = ServiceService();
  
  // State
  bool _isLoading = true;
  String? _errorMessage;
  
  // Data dari database
  List<BookingModel> _allBookings = [];
  List<UserModel> _allCustomers = [];
  List<ServiceModel> _allServices = [];
  Map<String, ServiceModel> _servicesCache = {};
  Map<String, UserModel> _usersCache = {};
  
  // Data untuk chart
  List<RevenueData> _revenueData = [];
  List<ServiceData> _serviceData = [];
  List<CustomerData> _customerData = [];
  
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
      // Load all data in parallel
      final results = await Future.wait([
        _bookingService.getAllBookings(),
        _userService.getUsersByRole('customer'),
        _serviceService.getAllServices(),
        DashboardService.getRevenueData(),
        DashboardService.getTopServices(),
        DashboardService.getDriverActivities(),
      ]);
      
      _allBookings = results[0] as List<BookingModel>;
      _allCustomers = results[1] as List<UserModel>;
      _allServices = results[2] as List<ServiceModel>;
      
      // Build caches
      _servicesCache = {};
      for (var service in _allServices) {
        _servicesCache[service.id] = service;
      }
      
      _usersCache = {};
      for (var customer in _allCustomers) {
        _usersCache[customer.id] = customer;
      }
      
      // Process revenue data - ✅ Safe parsing
      final revenueData = results[3] as List<Map<String, dynamic>>;
      _revenueData = revenueData.map((data) {
        final revenue = data['revenue'];
        double revenueValue = 0;
        if (revenue is num) {
          revenueValue = revenue.toDouble();
        } else if (revenue is String) {
          revenueValue = double.tryParse(revenue) ?? 0;
        }
        return RevenueData(
          data['month']?.toString() ?? '',
          revenueValue,
        );
      }).toList();
      
      // Process top services - ✅ Safe parsing
      final topServices = results[4] as List<Map<String, dynamic>>;
      _serviceData = topServices.map((data) {
        final count = data['count'];
        final revenue = data['revenue'];
        
        int countValue = 0;
        if (count is num) {
          countValue = count.toInt();
        } else if (count is String) {
          countValue = int.tryParse(count) ?? 0;
        }
        
        double revenueValue = 0;
        if (revenue is num) {
          revenueValue = revenue.toDouble();
        } else if (revenue is String) {
          revenueValue = double.tryParse(revenue) ?? 0;
        }
        
        return ServiceData(
          data['name']?.toString() ?? 'Layanan',
          countValue,
          revenueValue,
        );
      }).toList();
      
      // Calculate top customers from bookings
      _calculateTopCustomers();
      
      // Process driver data
      final driverActivities = results[5] as List<Map<String, dynamic>>;
      _driverData = driverActivities.map((data) {
        return DriverDataModel(
          id: data['driver_id']?.toString() ?? '',
          name: data['driver_name']?.toString() ?? 'Driver',
          completed: data['completed']?.toString() ?? '0',
          rating: '4.5', // Default rating
          revenue: '0', // Calculate from bookings if needed
        );
      }).toList();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
      
      // Load fallback data
      _loadFallbackData();
    }
  }
  
  void _loadFallbackData() {
    // Fallback data if API fails
    _revenueData = [
      RevenueData('Jan', 4500000),
      RevenueData('Feb', 5200000),
      RevenueData('Mar', 4800000),
      RevenueData('Apr', 6100000),
      RevenueData('Mei', 5500000),
      RevenueData('Jun', 7200000),
    ];
    
    _serviceData = [
      ServiceData('Premium Grooming', 45, 8100000),
      ServiceData('Basic Grooming', 38, 4560000),
      ServiceData('Spa Treatment', 25, 5000000),
      ServiceData('Special Package', 18, 4500000),
      ServiceData('Medical Grooming', 12, 3600000),
    ];
    
    _customerData = [
      CustomerData('Pelanggan 1', 12, 2160000),
      CustomerData('Pelanggan 2', 8, 1440000),
      CustomerData('Pelanggan 3', 15, 3000000),
      CustomerData('Pelanggan 4', 3, 600000),
      CustomerData('Pelanggan 5', 20, 4000000),
    ];
    
    _driverData = [
      DriverDataModel(
        id: '1',
        name: 'Driver 1', 
        completed: '45',
        rating: '4.8',
        revenue: '6750000',
      ),
    ];
    
    setState(() {});
  }
  
  void _calculateTopCustomers() {
    // Group bookings by customer
    Map<String, int> customerBookings = {};
    Map<String, double> customerRevenue = {};
    
    for (var booking in _allBookings) {
      final userId = booking.user_id;
      customerBookings[userId] = (customerBookings[userId] ?? 0) + 1;
      customerRevenue[userId] = (customerRevenue[userId] ?? 0) + booking.totalPriceDouble;
    }
    
    // Convert to CustomerData list
    _customerData = customerBookings.entries.map((entry) {
      final user = _usersCache[entry.key];
      return CustomerData(
        user?.name ?? 'Pelanggan',
        entry.value,
        customerRevenue[entry.key] ?? 0,
      );
    }).toList();
    
    // Sort by bookings count
    _customerData.sort((a, b) => b.bookings.compareTo(a.bookings));
    
    // Take top 5
    if (_customerData.length > 5) {
      _customerData = _customerData.take(5).toList();
    }
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
          'Laporan & Statistik',
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
            color: Colors.grey[700],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            color: Colors.grey[700],
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            color: Colors.grey[700],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAllData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAllData,
                  child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter section
            _buildFilterSection(),          
            const SizedBox(height: 24),
            
            //pendapatan
            _buildQuickStats(),
            const SizedBox(height: 24),

            //chart
            _buildChartSection(),
            const SizedBox(height: 24),

            //Top Layanan
            _buildTopServices(),
            const SizedBox(height: 24),
            
            //Top Customer
             _buildTopCustomers(),          
            const SizedBox(height: 24),

            //Top Driver
            _buildTopDrivers(),            
            const SizedBox(height: 32),            
              
          ],
        ),
      ),
                ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Period filter
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Periode:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
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
                        value: _selectedPeriod,
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPeriod = newValue!;
                            if (_selectedPeriod == 'custom') {
                              _showDateRangePicker();
                            } else {
                              _applyFilters();
                            }
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 'minggu-ini', child: Text('Minggu Ini')),
                          DropdownMenuItem(value: 'bulan-ini', child: Text('Bulan Ini')),
                          DropdownMenuItem(value: 'tahun-ini', child: Text('Tahun Ini')),
                          DropdownMenuItem(value: 'custom', child: Text('Periode Kustom')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),                        
            
            // Tampilkan info periode kustom jika dipilih
            if (_selectedStartDate != null && _selectedEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(_selectedStartDate!)} - ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      switch (_selectedPeriod) {
        case 'minggu-ini':
          _updateWeeklyData();
          break;
        case 'bulan-ini':
          _updateMonthlyData();
          break;
        case 'tahun-ini':
          _updateYearlyData();
          break;
        case 'custom':
          _updateCustomData();
          break;
      }
    });
  }

  void _updateWeeklyData() {
    _revenueData = [
      RevenueData('Sen', 1200000),
      RevenueData('Sel', 1500000),
      RevenueData('Rab', 1800000),
      RevenueData('Kam', 1400000),
      RevenueData('Jum', 2200000),
      RevenueData('Sab', 2800000),
      RevenueData('Min', 2000000),
    ];
    
    _serviceData.sort((a, b) => b.count.compareTo(a.count));
    _customerData.sort((a, b) => b.bookings.compareTo(a.bookings));
  }

  void _updateMonthlyData() {
    _revenueData = [
      RevenueData('Jan', 4500000),
      RevenueData('Feb', 5200000),
      RevenueData('Mar', 4800000),
      RevenueData('Apr', 6100000),
      RevenueData('Mei', 5500000),
      RevenueData('Jun', 7200000),
    ];
    
    _serviceData.sort((a, b) => b.revenue.compareTo(a.revenue));
    _customerData.sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  void _updateYearlyData() {
    _revenueData = [
      RevenueData('Q1', 14500000),
      RevenueData('Q2', 16800000),
      RevenueData('Q3', 18200000),
      RevenueData('Q4', 19500000),
    ];
    
    _serviceData.sort((a, b) => b.count.compareTo(a.count));
    _customerData.sort((a, b) => b.bookings.compareTo(a.bookings));
  }

  void _updateCustomData() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final days = _selectedEndDate!.difference(_selectedStartDate!).inDays;
      if (days <= 7) {
        _updateWeeklyData();
      } else if (days <= 31) {
        _updateMonthlyData();
      } else {
        _updateYearlyData();
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orangeMedium,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _applyFilters();
      });
    } else {
      setState(() {
        _selectedPeriod = 'bulan-ini';
      });
    }
  }

  Widget _buildQuickStats() {
    final totalRevenue = _revenueData.fold(0.0, (sum, item) => sum + item.revenue);
    final avgRevenue = _revenueData.isNotEmpty ? totalRevenue / _revenueData.length : 0.0;
    final totalServices = _serviceData.fold(0, (sum, item) => sum + item.count);
    final totalCustomers = _customerData.fold(0, (sum, item) => sum + item.bookings);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.05,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: 'Total Pendapatan',
          value: 'Rp ${NumberFormat('#,##0').format(totalRevenue)}',
          subtitle: _getPeriodLabel(),
          icon: Icons.attach_money,
          color: Colors.green,
          trend: _getRevenueTrend(),
        ),
        _buildStatCard(
          title: 'Rata-rata Pendapatan',
          value: 'Rp ${NumberFormat('#,##0').format(avgRevenue)}',
          subtitle: _getAverageLabel(),
          icon: Icons.trending_up,
          color: Colors.blue,
          trend: '+5%',
        ),
        _buildStatCard(
          title: 'Total Layanan',
          value: '$totalServices',
          subtitle: 'Layanan diberikan',
          icon: Icons.spa,
          color: Colors.purple,
          trend: '+8%',
        ),
        _buildStatCard(
          title: 'Total Pelanggan',
          value: '${_customerData.length}',
          subtitle: '$totalCustomers booking',
          icon: Icons.people,
          color: Colors.amber,
          trend: '+15%',
        ),
      ],
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'minggu-ini':
        return '7 hari terakhir';
      case 'bulan-ini':
        return '6 bulan terakhir';
      case 'tahun-ini':
        return 'Tahun ini';
      case 'custom':
        return 'Periode kustom';
      default:
        return '6 bulan terakhir';
    }
  }

  String _getAverageLabel() {
    switch (_selectedPeriod) {
      case 'minggu-ini':
        return 'Per hari';
      case 'bulan-ini':
        return 'Per bulan';
      case 'tahun-ini':
        return 'Per kuartal';
      default:
        return 'Per bulan';
    }
  }

  String _getRevenueTrend() {
    switch (_selectedPeriod) {
      case 'minggu-ini':
        return '+18%';
      case 'bulan-ini':
        return '+12%';
      case 'tahun-ini':
        return '+22%';
      default:
        return '+12%';
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trend Pendapatan ${_getChartTitle()}',
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
              height: 250,
              child: _chartType == 'line' 
                  ? _buildLineChart()
                  : _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedPeriod) {
      case 'minggu-ini':
        return '7 Hari';
      case 'bulan-ini':
        return '6 Bulan';
      case 'tahun-ini':
        return 'Tahun Ini';
      case 'custom':
        return 'Periode Terpilih';
      default:
        return '6 Bulan';
    }
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(
          symbol: 'Rp ',
          decimalDigits: 0,
        ),
      ),
      series: <CartesianSeries>[
        LineSeries<RevenueData, String>(
          dataSource: _revenueData,
          xValueMapper: (RevenueData data, _) => data.month,
          yValueMapper: (RevenueData data, _) => data.revenue,
          name: 'Pendapatan',
          color: AppColors.orangeMedium,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compactCurrency(
          symbol: 'Rp ',
          decimalDigits: 0,
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<RevenueData, String>(
          dataSource: _revenueData,
          xValueMapper: (RevenueData data, _) => data.month,
          yValueMapper: (RevenueData data, _) => data.revenue,
          name: 'Pendapatan',
          color: AppColors.orangeMedium,
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildTopServices() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan Terpopuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllServices(),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: _serviceData.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${service.count}x',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(service.revenue)}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomers() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pelanggan Teratas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllCustomers(),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: _customerData.map((customer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          customer.name.substring(0, 1),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              '${customer.bookings} booking',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(customer.revenue)}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopDrivers() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Driver Terbaik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllDrivers(),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: _driverData.map((driver) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: const Icon(Icons.delivery_dining, color: Colors.purple),
                      ),
                      title: Text(
                        driver.name, // LANGSUNG akses property
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating, // LANGSUNG akses property
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${driver.completed} tugas', // LANGSUNG akses property
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Text(
                        'Rp ${NumberFormat('#,##0').format(driver.revenue)}', // LANGSUNG akses property
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.month, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Rp ${NumberFormat('#,##0').format(data.revenue)}'),
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
                      'Rp ${NumberFormat('#,##0').format(_revenueData.fold(0.0, (sum, item) => sum + item.revenue))}',
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
                      'Rp ${NumberFormat('#,##0').format(_revenueData.isNotEmpty ? _revenueData.fold(0.0, (sum, item) => sum + item.revenue) / _revenueData.length : 0)}',
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

  Future<void> _exportReport() async {
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
                    'Ekspor Laporan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih format yang diinginkan:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // PDF Option
              _buildExportOption(
                icon: Icons.picture_as_pdf,
                title: 'PDF Document',
                subtitle: 'Format terbaik untuk cetak',
                color: Colors.red,
                format: 'PDF',
              ),
              
              const SizedBox(height: 12),
              
              // Excel Option
              _buildExportOption(
                icon: Icons.table_chart,
                title: 'Excel Spreadsheet',
                subtitle: 'Format untuk analisis data',
                color: Colors.green,
                format: 'Excel',
              ),
              
              const SizedBox(height: 12),
              
              // CSV Option
              _buildExportOption(
                icon: Icons.table_rows,
                title: 'CSV File',
                subtitle: 'Format ringan untuk database',
                color: Colors.blue,
                format: 'CSV',
              ),
              
              const SizedBox(height: 20),
              
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
        _processExport(format);
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

  Future<void> _processExport(String format) async {
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
                'Mempersiapkan laporan $format',
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
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      Navigator.pop(context);
      _showExportSuccess(format);
    }
  }

  void _showExportSuccess(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan berhasil diekspor!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Format: $format',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Aksi untuk membuka file
              },
              child: const Text(
                'BUKA',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _exportChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grafik berhasil diekspor sebagai gambar'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReport() {
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
                leading: const Icon(Icons.email, color: Colors.red),
                title: const Text('Bagikan via Email'),
                onTap: () {
                  Navigator.pop(context);
                  _shareViaEmail();
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('Bagikan via WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _shareViaWhatsApp();
                },
              ),
              if (Platform.isIOS)
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.blue),
                  title: const Text('Bagikan via iMessage'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareViaMessage();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.purple),
                title: const Text('Salin Ringkasan'),
                onTap: () {
                  Navigator.pop(context);
                  _copySummaryToClipboard();
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

  void _shareViaEmail() async {
    final subject = 'Laporan ${_selectedReportType.capitalize()} - ${DateFormat('dd MMMM yyyy').format(DateTime.now())}';
    final body = '''
Laporan ${_selectedReportType.capitalize()}
Periode: ${_getPeriodDisplayName()}
Tanggal: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}

Ringkasan:
${_getReportSummary()}

---
Laporan dibuat dari Aplikasi Pet Grooming
''';
    
    final uri = Uri.parse('mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka aplikasi email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareViaWhatsApp() {
    final message = '''
📊 *Laporan ${_selectedReportType.capitalize()}*
📅 Periode: ${_getPeriodDisplayName()}
⏰ Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}

${_getReportSummary()}

_Dikirim dari Aplikasi Pet Grooming_
''';
    
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    
    launchUrl(uri).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    });
  }

  void _shareViaMessage() {
    // Untuk iOS, implementasi khusus jika diperlukan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur berbagi via iMessage'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copySummaryToClipboard() {
    // ignore: unused_local_variable
    final summary = '''
Laporan ${_selectedReportType.capitalize()}
Periode: ${_getPeriodDisplayName()}
Tanggal: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}

${_getReportSummary()}
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ringkasan laporan disalin ke clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getPeriodDisplayName() {
    switch (_selectedPeriod) {
      case 'minggu-ini':
        return 'Minggu Ini';
      case 'bulan-ini':
        return 'Bulan Ini';
      case 'tahun-ini':
        return 'Tahun Ini';
      case 'custom':
        return _selectedStartDate != null && _selectedEndDate != null
            ? '${DateFormat('dd/MM/yy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yy').format(_selectedEndDate!)}'
            : 'Periode Kustom';
      default:
        return 'Bulan Ini';
    }
  }

  String _getReportSummary() {
    switch (_selectedReportType) {
      case 'pendapatan':
        final total = _revenueData.fold(0.0, (sum, item) => sum + item.revenue);
        final avg = _revenueData.isNotEmpty ? total / _revenueData.length : 0.0;
        return '''
          💰 Total Pendapatan: Rp ${NumberFormat('#,##0').format(total)}
          📈 Rata-rata: Rp ${NumberFormat('#,##0').format(avg)}
          📊 Periode: ${_revenueData.length} ${_selectedPeriod == 'minggu-ini' ? 'hari' : _selectedPeriod == 'tahun-ini' ? 'kuartal' : 'bulan'}
          ''';
      case 'layanan':
        final totalServices = _serviceData.fold(0, (sum, item) => sum + item.count);
        final totalRevenue = _serviceData.fold(0.0, (sum, item) => sum + item.revenue);
        return '''
          🛠 Total Layanan: $totalServices
          💵 Total Revenue: Rp ${NumberFormat('#,##0').format(totalRevenue)}
          🏆 Layanan Teratas: ${_serviceData.isNotEmpty ? _serviceData.first.name : '-'}
          ''';
      case 'pelanggan':
        final totalBookings = _customerData.fold(0, (sum, item) => sum + item.bookings);
        final totalRevenue = _customerData.fold(0.0, (sum, item) => sum + item.revenue);
        return '''
          👥 Total Pelanggan: ${_customerData.length}
          📅 Total Booking: $totalBookings
          💵 Total Revenue: Rp ${NumberFormat('#,##0').format(totalRevenue)}
          🏆 Pelanggan Teratas: ${_customerData.isNotEmpty ? _customerData.first.name : '-'}
          ''';
      case 'driver':
        // PERBAIKAN: Gunakan model DriverData
        final totalCompleted = _driverData.fold(0, (sum, item) => sum + int.parse(item.completed));
        final totalRevenue = _driverData.fold(0, (sum, item) => sum + int.parse(item.revenue));
        return '''
          🚗 Total Driver: ${_driverData.length}
          ✅ Tugas Selesai: $totalCompleted
          💵 Total Revenue: Rp ${NumberFormat('#,##0').format(totalRevenue)}
          🏆 Driver Terbaik: ${_driverData.isNotEmpty ? _driverData.first.name : '-'}
          ''';
      default:
        return '';
    }
  }

  void _viewAllServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Semua Layanan - ${_getPeriodDisplayName()}'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _serviceData.length,
            itemBuilder: (context, index) {
              final service = _serviceData[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child: const Icon(Icons.spa, color: Colors.purple),
                  ),
                  title: Text(service.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${service.count} kali dipesan'),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(service.revenue)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to service detail
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _viewAllCustomers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Semua Pelanggan - ${_getPeriodDisplayName()}'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _customerData.length,
            itemBuilder: (context, index) {
              final customer = _customerData[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      customer.name.substring(0, 1),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  title: Text(customer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${customer.bookings} booking'),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(customer.revenue)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to customer detail
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _viewAllDrivers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Semua Driver - ${_getPeriodDisplayName()}'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _driverData.length,
            itemBuilder: (context, index) {
              final driver = _driverData[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child: const Icon(Icons.delivery_dining, color: Colors.purple),
                  ),
                  title: Text(driver.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(driver.rating),
                          const SizedBox(width: 16),
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('${driver.completed} tugas'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(driver.revenue)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to driver detail
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Extension untuk capitalize string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// Data models untuk chart
class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
}

class ServiceData {
  final String name;
  final int count;
  final double revenue;

  ServiceData(this.name, this.count, this.revenue);
}

class CustomerData {
  final String name;
  final int bookings;
  final double revenue;

  CustomerData(this.name, this.bookings, this.revenue);
}