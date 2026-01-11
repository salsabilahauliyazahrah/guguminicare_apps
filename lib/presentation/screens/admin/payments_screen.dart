
import 'dart:io';
import 'dart:math' as math; // TAMBAHKAN INI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TAMBAHKAN INI
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';


class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _fullDateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  
  // Services
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final PetService _petService = PetService();
  final ServiceService _serviceService = ServiceService();
  
  // Data from database
  List<BookingModel> _allBookings = [];
  Map<String, UserModel> _usersCache = {};
  Map<String, PetModel> _petsCache = {};
  Map<String, ServiceModel> _servicesCache = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  
  String _selectedFilter = 'semua'; // semua, pending, lunas, gagal
  String _selectedPeriod = 'hari-ini';
  String _selectedPaymentMethod = 'semua';
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  
  TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  bool _showFilters = false;

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
      // Load all bookings (which contain payment info)
      final bookings = await _bookingService.getAllBookings();
      
      // Load users, pets, services for lookup
      final users = await _userService.getAllUsers();
      final pets = await _petService.getAllPets();
      final services = await _serviceService.getAllServices();
      
      setState(() {
        _allBookings = bookings;
        _usersCache = {for (var u in users) u.id: u};
        _petsCache = {for (var p in pets) p.id: p};
        _servicesCache = {for (var s in services) s.id: s};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  // Helper methods
  String _getCustomerName(String userId) {
    return _usersCache[userId]?.name ?? 'Pelanggan';
  }

  String _getCustomerEmail(String userId) {
    return _usersCache[userId]?.email ?? '-';
  }

  String _getCustomerPhone(String userId) {
    return _usersCache[userId]?.phone ?? '-';
  }

  String _getPetName(String petId) {
    return _petsCache[petId]?.name ?? 'Hewan';
  }

  String _getServiceName(String serviceId) {
    return _servicesCache[serviceId]?.name ?? 'Layanan';
  }

  Map<String, dynamic> _getPaymentStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
      case 'completed':
      case 'paid':
        return {'text': 'Lunas', 'color': Colors.green, 'status': 'completed'};
      case 'pending':
      case 'menunggu':
        return {'text': 'Menunggu Pembayaran', 'color': Colors.orange, 'status': 'pending'};
      case 'gagal':
      case 'failed':
        return {'text': 'Gagal', 'color': Colors.red, 'status': 'failed'};
      default:
        return {'text': status, 'color': Colors.grey, 'status': status.toLowerCase()};
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
      case 'tunai':
      case 'cash':
        return Icons.local_atm;
      case 'transfer':
      case 'transfer bank':
        return Icons.account_balance;
      case 'qris':
        return Icons.qr_code;
      case 'e-wallet':
      case 'ewallet':
        return Icons.wallet;
      case 'kartu kredit':
      case 'credit card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  List<BookingModel> get _filteredPayments {
    var filtered = List<BookingModel>.from(_allBookings);
    
    // Filter by payment status
    if (_selectedFilter != 'semua') {
      filtered = filtered.where((b) {
        final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
        return statusDisplay['status'] == _selectedFilter;
      }).toList();
    }
    
    // Filter by payment method
    if (_selectedPaymentMethod != 'semua') {
      filtered = filtered.where((b) => b.payment_method.toLowerCase() == _selectedPaymentMethod.toLowerCase()).toList();
    }
    
    // Filter by period
    filtered = _filterByPeriod(filtered);
    
    // Filter by date range
    filtered = filtered.where((booking) {
      final bookingDate = DateTime.tryParse(booking.booking_date) ?? DateTime.now();
      return bookingDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
             bookingDate.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((booking) {
        final customerName = _getCustomerName(booking.user_id).toLowerCase();
        return booking.id.toLowerCase().contains(searchText) ||
               customerName.contains(searchText) ||
               booking.booking_code.toLowerCase().contains(searchText);
      }).toList();
    }
    
    return filtered;
  }

  List<BookingModel> _filterByPeriod(List<BookingModel> bookings) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'hari-ini':
        return bookings.where((b) {
          final date = DateTime.tryParse(b.booking_date) ?? DateTime.now();
          return date.day == now.day && 
                 date.month == now.month && 
                 date.year == now.year;
        }).toList();
        
      case 'minggu-ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return bookings.where((b) {
          final date = DateTime.tryParse(b.booking_date) ?? DateTime.now();
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
        }).toList();
        
      case 'bulan-ini':
        return bookings.where((b) {
          final date = DateTime.tryParse(b.booking_date) ?? DateTime.now();
          return date.month == now.month && date.year == now.year;
        }).toList();
        
      default:
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _filteredPayments;
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(), // Kembali ke halaman sebelumnya
        ),       
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportMenu(context),
            tooltip: 'Download Laporan',
            color: Colors.grey[700],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh',
            color: Colors.grey[700],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadAllData,
                  child: Column(
                    children: [
                      // Search bar
                      _buildSearchBar(),
                      
                      // Header dengan statistik
                      _buildStatsHeader(stats),
                      
                      // Filter section
                      _buildFilterSection(),
                      
                      // Date range filter
                      //_buildDateRangeFilter(),//
                      
                      // Payments list atau empty state
                      Expanded(
                        child: filteredPayments.isEmpty
                            ? _buildEmptyState()
                            : _buildPaymentsList(filteredPayments),
                      ),
                    ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Nama Pelanggan, atau Invoice...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildStatsHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentStat(
                label: 'Total Pendapatan',
                value: 'Rp ${NumberFormat('#,##0').format(stats['totalRevenue'])}',
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: '${stats['completedCount']} transaksi',
              ),
              _buildPaymentStat(
                label: 'Pending',
                value: 'Rp ${NumberFormat('#,##0').format(stats['pendingAmount'])}',
                icon: Icons.pending,
                color: Colors.orange,
                subtitle: '${stats['pendingCount']} transaksi',
              ),
              _buildPaymentStat(
                label: 'Gagal',
                value: 'Rp ${NumberFormat('#,##0').format(stats['failedAmount'])}',
                icon: Icons.error,
                color: Colors.red,
                subtitle: '${stats['failedCount']} transaksi',
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPaymentStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
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
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // KURANGI VERTICAL PADDING
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filter Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // KURANGI PADDING
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // KURANGI RADIUS
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.filter_list, size: 14), // PERKECIL IKON
                  iconSize: 14, // PERKECIL UKURAN IKON
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12, // PERKECIL FONT SIZE
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'semua', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2), // KURANGI PADDING ITEM
                        child: Text('Semua Status', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 6, // PERKECIL DOT
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4), // KURANGI SPACING
                            const Text('Pending', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('Lunas', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'failed',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('Gagal', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  isDense: true, // TAMBAHKAN INI UNTUK UKURAN LEBIH KOMPAK
                ),
              ),
            ),
            
            const SizedBox(width: 6), // KURANGI SPACING ANTAR FILTER
            
            // Filter Periode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: const Icon(Icons.calendar_today, size: 14),
                  iconSize: 14,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'hari-ini', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Hari Ini', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'minggu-ini', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Minggu Ini', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'bulan-ini', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Bulan Ini', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'semua', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Semua', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                  isDense: true,
                ),
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Filter Metode Pembayaran
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  icon: const Icon(Icons.payment, size: 14),
                  iconSize: 14,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'semua', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Semua', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'COD', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('COD', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Transfer Bank', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Transfer', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'QRIS', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('QRIS', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'E-Wallet', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('E-Wallet', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Kartu Kredit', 
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Kartu', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDateRangeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rentang Tanggal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.calendar_month, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _startDate = DateTime.now().subtract(const Duration(days: 7));
                _endDate = DateTime.now();
                _selectedPeriod = 'semua';
              });
            },
            tooltip: 'Reset Filter',
            color: Colors.grey,
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
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data pembayaran',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau rentang tanggal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'semua';
                _selectedPeriod = 'semua';
                _selectedPaymentMethod = 'semua';
                _startDate = DateTime.now().subtract(const Duration(days: 30));
                _endDate = DateTime.now();
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Semua Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<BookingModel> payments) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(BookingModel payment) {
    final statusDisplay = _getPaymentStatusDisplay(payment.payment_status);
    final bookingDate = DateTime.tryParse(payment.booking_date) ?? DateTime.now();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewPaymentDetail(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan ID dan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.booking_code.isNotEmpty ? payment.booking_code : payment.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Invoice: ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (statusDisplay['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (statusDisplay['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusDisplay['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusDisplay['text'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusDisplay['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Customer dan service info
              Row(
                children: [
                  // Customer info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCustomerName(payment.user_id),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_getPetName(payment.pet_id)} • ${_getServiceName(payment.service_id)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Metode: ${payment.service_method}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,##0').format(payment.totalPriceDouble)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusDisplay['status'] == 'completed' 
                                ? Colors.green 
                                : statusDisplay['status'] == 'failed'
                                  ? Colors.red
                                  : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Payment method dan tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPaymentMethodIcon(payment.payment_method),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        payment.payment_method.isNotEmpty ? payment.payment_method : 'Belum dipilih',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _dateFormat.format(bookingDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Additional info based on status
              if (statusDisplay['status'] == 'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Menunggu pembayaran',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (statusDisplay['status'] == 'completed')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pembayaran terverifikasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (statusDisplay['status'] == 'failed')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pembayaran gagal',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (payment.special_notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Catatan: ${payment.special_notes}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildPaymentActions(payment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentActions(BookingModel payment) {
    final List<Widget> actions = [];
    final statusDisplay = _getPaymentStatusDisplay(payment.payment_status);
    
    // Detail button untuk semua status
    actions.add(
      OutlinedButton.icon(
        onPressed: () => _viewPaymentDetail(payment),
        icon: const Icon(Icons.visibility, size: 16),
        label: const Text('Detail'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
        ),
      ),
    );
    
    const SizedBox(width: 8);
    
    if (statusDisplay['status'] == 'pending') {
      actions.addAll([
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _markAsPaid(payment),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Tandai Lunas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ]);
    } else if (statusDisplay['status'] == 'completed') {
      actions.addAll([
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _generateInvoice(payment),
          icon: const Icon(Icons.receipt_long, size: 16),
          label: const Text('Invoice'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.purple,
            side: const BorderSide(color: Colors.purple),
          ),
        ),
      ]);
    } else if (statusDisplay['status'] == 'failed') {
      actions.addAll([
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _retryPayment(payment),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Ulangi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ]);
    }
    
    return actions;
  }

  // ignore: unused_element
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Lanjutan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter by amount range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rentang Jumlah:'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Min',
                                prefixText: 'Rp ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Max',
                                prefixText: 'Rp ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter by verification status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Verifikasi:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Terverifikasi'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                          FilterChip(
                            label: const Text('Belum Verifikasi'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                          FilterChip(
                            label: const Text('Otomatis'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sort options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Urutkan Berdasarkan:'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: 'date_desc',
                        items: [
                          DropdownMenuItem(
                            value: 'date_desc',
                            child: Text('Tanggal (Terbaru)'),
                          ),
                          DropdownMenuItem(
                            value: 'date_asc',
                            child: Text('Tanggal (Terlama)'),
                          ),
                          DropdownMenuItem(
                            value: 'amount_desc',
                            child: Text('Jumlah (Terbesar)'),
                          ),
                          DropdownMenuItem(
                            value: 'amount_asc',
                            child: Text('Jumlah (Terkecil)'),
                          ),
                          DropdownMenuItem(
                            value: 'name_asc',
                            child: Text('Nama (A-Z)'),
                          ),
                        ],
                        onChanged: (_) {},
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters
                },
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showExportMenu(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ekspor Data Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Periode: ${_getCurrentFilterPeriod()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Excel Option
              _buildPaymentExportOption(
                icon: Icons.table_chart,
                title: 'Excel Spreadsheet',
                subtitle: 'Format untuk analisis data',
                color: Colors.green,
                format: 'excel',
              ),
              
              const SizedBox(height: 12),
              
              // CSV Option
              _buildPaymentExportOption(
                icon: Icons.table_rows,
                title: 'CSV File',
                subtitle: 'Format ringan untuk database',
                color: Colors.blue,
                format: 'csv',
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Additional Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Opsi Tambahan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Export Settings
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showExportSettings();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.settings, size: 18, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengaturan Export',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Atur format dan kolom yang akan diekspor',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Export History
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _viewExportHistory();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history, size: 18, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat Export',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Lihat file yang telah diekspor sebelumnya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildPaymentExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String format,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleExportFormat(format);
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

  void _handleExportFormat(String format) async {
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sedang mempersiapkan data...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                format == 'excel' 
                  ? 'Membuat file Excel...'
                  : format == 'csv'
                    ? 'Membuat file CSV...'
                    : 'Membuat file PDF...',
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
      
      // Panggil fungsi export sesuai format
      switch (format) {
        case 'excel':
          await _exportToExcel();
          break;
        case 'csv':
          await _exportToCSV();
          break;
      }
    }
  }

  String _getCurrentFilterPeriod() {
    // Fungsi untuk mendapatkan periode filter saat ini
    // Contoh sederhana:
    if (_selectedFilter == 'today') {
      return 'Hari Ini';
    } else if (_selectedFilter == 'week') {
      return 'Minggu Ini';
    } else if (_selectedFilter == 'month') {
      return 'Bulan Ini';
    } else if (_selectedFilter == 'custom') {
      return 'Periode Kustom';
    }
    return 'Semua Waktu';
  }

  // Helper function to format file size
  // ignore: unused_element
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (math.log(bytes) / math.log(1024)).floor(); // PAKAI math.log
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}'; // PAKAI math.pow
  }



  Future<void> _exportToExcel() async {
    try {
      final payments = _filteredPayments;
      
      if (payments.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tidak Ada Data'),
            content: const Text('Tidak ada data pembayaran untuk diexport.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membuat file Excel...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Create CSV content (Excel bisa membuka CSV sebagai Excel)
      String excelContent = 'LAPORAN PEMBAYARAN GUGUMINI\n';
      excelContent += 'Periode: ${_fullDateFormat.format(_startDate)} - ${_fullDateFormat.format(_endDate)}\n';
      excelContent += 'Dibuat pada: ${_fullDateFormat.format(DateTime.now())}\n\n';
      
      // Header
      excelContent += 'No\tID Pembayaran\tInvoice\tPelanggan\tEmail\tTelepon\tHewan\tLayanan\tKategori\tJumlah\tDibayar\tMetode\tStatus\tTanggal\tTanggal Bayar\tDiverifikasi Oleh\tCatatan\n';
      
      // Data
      for (int i = 0; i < payments.length; i++) {
        final payment = payments[i];
        final user = _usersCache[payment.user_id];
        final pet = _petsCache[payment.pet_id];
        final service = _servicesCache[payment.service_id];
        
        final date = _dateFormat.format(DateTime.tryParse(payment.created_at) ?? DateTime.now());
        final paymentDate = payment.payment_status == 'lunas' ? date : '';
        
        excelContent += 
          '${i + 1}\t'
          '${payment.id}\t'
          '${payment.booking_code}\t'
          '${user?.name ?? "Pelanggan"}\t'
          '${user?.email ?? ""}\t'
          '${user?.phone ?? ""}\t'
          '${pet?.name ?? "Hewan"}\t'
          '${service?.name ?? "Layanan"}\t'
          '${_formatCategory(service?.category ?? "")}\t'
          '${payment.total_price}\t'
          '${payment.total_price}\t'
          '${payment.payment_method}\t'
          '${payment.payment_status}\t'
          '$date\t'
          '$paymentDate\t'
          '\t'
          '${payment.special_notes}\n';
      }
      
      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      final String fileName = 'Laporan_Pembayaran_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xls';
      final String filePath = '${exportDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsString(excelContent, flush: true);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Tampilkan dialog dengan opsi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File Excel berhasil dibuat.'),
              const SizedBox(height: 8),
              Text(
                'File: $fileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Data: ${payments.length} pembayaran',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Format: Tab-delimited (dapat dibuka di Excel)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await OpenFile.open(filePath);
              },
              child: const Text('Buka di Excel'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat Excel: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error creating Excel: $e');
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final payments = _filteredPayments;
      
      if (payments.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tidak Ada Data'),
            content: const Text('Tidak ada data pembayaran untuk diexport.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membuat file CSV...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Create CSV content with proper escaping
      String csvContent = 'No,ID Pembayaran,Invoice,Pelanggan,Email,Telepon,Hewan,Layanan,Kategori,Jumlah,Dibayar,Metode,Status,Tanggal,Tanggal Bayar,Diverifikasi Oleh,Catatan\n';
      
      for (int i = 0; i < payments.length; i++) {
        final payment = payments[i];
        final user = _usersCache[payment.user_id];
        final pet = _petsCache[payment.pet_id];
        final service = _servicesCache[payment.service_id];
        
        final date = _dateFormat.format(DateTime.tryParse(payment.created_at) ?? DateTime.now());
        final paymentDate = payment.payment_status == 'lunas' ? date : '';
        
        // Escape quotes and commas in text fields
        String escapeCSV(String? text) {
          if (text == null) return '';
          if (text.contains(',') || text.contains('"') || text.contains('\n')) {
            return '"${text.replaceAll('"', '""')}"';
          }
          return text;
        }
        
        csvContent += 
          '${i + 1},'
          '${escapeCSV(payment.id)},'
          '${escapeCSV(payment.booking_code)},'
          '${escapeCSV(user?.name)},'
          '${escapeCSV(user?.email)},'
          '${escapeCSV(user?.phone)},'
          '${escapeCSV(pet?.name)},'
          '${escapeCSV(service?.name)},'
          '${escapeCSV(_formatCategory(service?.category ?? ''))},'
          '${payment.total_price},'
          '${payment.total_price},'
          '${escapeCSV(payment.payment_method)},'
          '${escapeCSV(payment.payment_status)},'
          '${escapeCSV(date)},'
          '${escapeCSV(paymentDate)},'
          ','
          '${escapeCSV(payment.special_notes)}\n';
      }
      
      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      final String fileName = 'Laporan_Pembayaran_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final String filePath = '${exportDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsString(csvContent, flush: true);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Tampilkan dialog dengan opsi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File CSV berhasil dibuat.'),
              const SizedBox(height: 8),
              Text(
                'File: $fileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Data: ${payments.length} pembayaran',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Lokasi: ${exportDir.path}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await OpenFile.open(filePath);
              },
              child: const Text('Buka File'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Copy CSV content to clipboard
                Clipboard.setData(ClipboardData(text: csvContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data CSV disalin ke clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Salin Data'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat CSV: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error creating CSV: $e');
    }
  }

  void _showExportSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Export'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kolom yang akan diexport:'),
              const SizedBox(height: 8),
              ...['ID', 'Invoice', 'Pelanggan', 'Hewan', 'Layanan', 'Jumlah', 'Metode', 'Status', 'Tanggal', 'Catatan']
                .map((column) => CheckboxListTile(
                      title: Text(column),
                      value: true,
                      onChanged: (_) {},
                    ))
                .toList(),
              
              const SizedBox(height: 16),
              
              const Text('Format Tanggal:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'dd/MM/yyyy',
                items: const [
                  DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('DD/MM/YYYY')),
                  DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/DD/YYYY')),
                  DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('YYYY-MM-DD')),
                  DropdownMenuItem(value: 'dd MMM yyyy', child: Text('DD MMM YYYY')),
                ],
                onChanged: (_) {},
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan disimpan')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _viewExportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Riwayat Export'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [              
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Data Transaksi.csv'),
                subtitle: const Text('25 Des 2024, 10:15 • 0.8 MB'),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
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
        ],
      ),
    );
  }

  void _markAsPaid(BookingModel payment) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool useManualVerification = false;
          String? paymentMethod;
          String? notes;
          
          return AlertDialog(
            title: const Text('Tandai Sebagai Lunas'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Pembayaran: ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id}'),
                  Text('Pelanggan: ${_getCustomerName(payment.user_id)}'),
                  Text('Jumlah: Rp ${NumberFormat('#,##0').format(payment.totalPriceDouble)}'),
                  
                  const SizedBox(height: 16),
                  
                  CheckboxListTile(
                    title: const Text('Verifikasi Manual'),
                    subtitle: const Text('Pembayaran dilakukan di luar sistem'),
                    value: useManualVerification,
                    onChanged: (value) {
                      setDialogState(() => useManualVerification = value!);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  if (useManualVerification) ...[
                    const SizedBox(height: 8),
                    const Text('Metode Pembayaran:'),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Tunai (Cash)')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Transfer Bank Manual')),
                        DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                      ],
                      onChanged: (value) {
                        setDialogState(() => paymentMethod = value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pilih metode',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        hintText: 'Catatan tambahan...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => notes = value,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  try {
                    // Update payment status in database
                    Map<String, dynamic> updateData = {
                      'payment_status': 'completed',
                      'notes': notes ?? 'Ditandai lunas oleh admin',
                    };
                    
                    if (useManualVerification && paymentMethod != null) {
                      updateData['payment_method'] = 'Manual ($paymentMethod)';
                    }
                    
                    await _bookingService.updateBooking(payment.id, updateData);
                    
                    // Reload data
                    await _loadAllData();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pembayaran ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id} ditandai lunas'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengupdate pembayaran: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Konfirmasi'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ignore: unused_element
  void _uploadPaymentProof(BookingModel payment) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Pilih File'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengupload bukti pembayaran...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      try {
        // Update booking with payment proof info
        await _bookingService.updateBooking(payment.id, {
          'special_notes': '${payment.special_notes}\nBukti pembayaran diupload pada ${DateTime.now()}',
        });
        
        await _loadAllData();
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti pembayaran berhasil diupload'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupload bukti: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewPaymentDetail(BookingModel payment) {
    // ignore: unused_local_variable
    final statusDisplay = _getPaymentStatusDisplay(payment.payment_status);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Detail Pembayaran ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id}'),
          ),
          body: _buildPaymentDetail(payment),
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(BookingModel payment) {
    final statusDisplay = _getPaymentStatusDisplay(payment.payment_status);
    final bookingDate = DateTime.tryParse(payment.booking_date) ?? DateTime.now();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (statusDisplay['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (statusDisplay['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (statusDisplay['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusDisplay['text'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusDisplay['color'] as Color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusDisplay['status'] == 'pending'
                      ? 'Menunggu pembayaran dari pelanggan'
                      : statusDisplay['status'] == 'completed'
                        ? 'Pembayaran telah lunas dan diverifikasi'
                        : 'Pembayaran gagal, perlu tindak lanjut',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment Information
          const Text(
            'Informasi Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailItem('ID Pembayaran', payment.id),
          _buildDetailItem('Nomor Invoice', payment.booking_code.isNotEmpty ? payment.booking_code : payment.id),
          _buildDetailItem('Tanggal', _fullDateFormat.format(bookingDate)),
          _buildDetailItem('Waktu', payment.booking_time),
          
          const SizedBox(height: 16),
          
          // Amount Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Jumlah Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${NumberFormat('#,##0').format(payment.totalPriceDouble)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Customer Information
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailItem('Nama', _getCustomerName(payment.user_id)),
          _buildDetailItem('Email', _getCustomerEmail(payment.user_id)),
          _buildDetailItem('Telepon', _getCustomerPhone(payment.user_id)),
          _buildDetailItem('Nama Hewan', _getPetName(payment.pet_id)),
          _buildDetailItem('Layanan', _getServiceName(payment.service_id)),
          _buildDetailItem('Metode Layanan', payment.service_method),
          
          const SizedBox(height: 24),
          
          // Payment Method
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_getPaymentMethodIcon(payment.payment_method), size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.payment_method.isNotEmpty ? payment.payment_method : 'Belum dipilih',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline Information
          const Text(
            'Timeline Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildTimelineItem(
                'Pembayaran Dibuat',
                bookingDate,
                true,
              ),
              if (statusDisplay['status'] == 'completed')
                _buildTimelineItem(
                  'Pembayaran Diverifikasi',
                  bookingDate,
                  true,
                ),
            ],
          ),
          
          if (payment.special_notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(payment.special_notes),
            ),
          ],
          
          const SizedBox(height: 40),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateInvoice(payment),
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300]!,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? Colors.green : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              Container(
                width: 2,
                height: 24,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_dateFormat.format(date)} • ${_timeFormat.format(date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateInvoice(BookingModel payment) {
    final bookingDate = DateTime.tryParse(payment.booking_date) ?? DateTime.now();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cetak Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih format invoice yang ingin dicetak:'),
            const SizedBox(height: 16),
            Text('Invoice: ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id}'),
            Text('Pelanggan: ${_getCustomerName(payment.user_id)}'),
            Text('Jumlah: Rp ${NumberFormat('#,##0').format(payment.totalPriceDouble)}'),
            Text('Tanggal: ${_fullDateFormat.format(bookingDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),          
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice berhasil dibuat'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Cetak'),
          ),
        ],
      ),
    );
  }


  // ignore: unused_element
  void _sharePayment(BookingModel payment) {
    final bookingDate = DateTime.tryParse(payment.booking_date) ?? DateTime.now();
    // ignore: unused_local_variable
    final paymentInfo = '''
Informasi Pembayaran
====================
Invoice: ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id}
Pelanggan: ${_getCustomerName(payment.user_id)}
Layanan: ${_getServiceName(payment.service_id)}
Jumlah: Rp ${NumberFormat('#,##0').format(payment.totalPriceDouble)}
Tanggal: ${_fullDateFormat.format(bookingDate)}
Status: ${_getPaymentStatusDisplay(payment.payment_status)['text']}
''';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Pembayaran'),
        content: const Text('Bagikan informasi pembayaran melalui:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membagikan via WhatsApp...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('WhatsApp'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membagikan via Email...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app: Clipboard.setData(ClipboardData(text: paymentInfo));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informasi pembayaran disalin ke clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Salin'),
          ),
        ],
      ),
    );
  }

  void _retryPayment(BookingModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ulangi Pembayaran'),
        content: Text('Apakah Anda ingin mengirim ulang pembayaran untuk ${_getCustomerName(payment.user_id)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _bookingService.updateBooking(payment.id, {
                  'payment_status': 'pending',
                  'special_notes': '${payment.special_notes}\nPembayaran dikirim ulang pada ${DateTime.now()}',
                });
                
                await _loadAllData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pembayaran ${payment.booking_code.isNotEmpty ? payment.booking_code : payment.id} dikirim ulang'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengirim ulang pembayaran: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Kirim Ulang'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _addManualPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pembayaran Manual'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fitur ini akan segera tersedia'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      helpText: 'Pilih Rentang Tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      saveText: 'Simpan',
      fieldStartLabelText: 'Tanggal Mulai',
      fieldEndLabelText: 'Tanggal Akhir',
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'custom';
      });
    }
  }

  // ignore: unused_element
  void _filterByCategory(String category) {
    // This is a simplified version - implement actual filtering logic
    setState(() {
      // For demo purposes, we're just showing a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filter kategori: $category'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Map<String, dynamic> _calculateStats() {
    final filtered = _filteredPayments;
    
    final totalRevenue = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'completed';
        })
        .fold(0.0, (sum, b) => sum + b.totalPriceDouble);
    
    final pendingAmount = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'pending';
        })
        .fold(0.0, (sum, b) => sum + b.totalPriceDouble);
    
    final failedAmount = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'failed';
        })
        .fold(0.0, (sum, b) => sum + b.totalPriceDouble);
    
    final completedCount = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'completed';
        })
        .length;
    
    final pendingCount = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'pending';
        })
        .length;
    
    final failedCount = filtered
        .where((b) {
          final statusDisplay = _getPaymentStatusDisplay(b.payment_status);
          return statusDisplay['status'] == 'failed';
        })
        .length;
    
    final totalTransactions = filtered.length;
    final completionRate = totalTransactions > 0 
        ? completedCount / totalTransactions 
        : 0.0;
    
    return {
      'totalRevenue': totalRevenue,
      'pendingAmount': pendingAmount,
      'failedAmount': failedAmount,
      'completedCount': completedCount,
      'pendingCount': pendingCount,
      'failedCount': failedCount,
      'completionRate': completionRate,
    };
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'grooming':
        return 'Grooming';
      case 'spa':
        return 'Spa Treatment';
      case 'medical':
        return 'Medical Grooming';
      default:
        return 'Lainnya';
    }
  }

  // ignore: unused_element
  Future<void> _shareFile(File file) async {
    // Implement file sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membagikan file...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}