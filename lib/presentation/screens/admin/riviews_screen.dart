// lib/presentation/screens/admin/reviews/admin_reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/models/review_model.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/riview_service.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  
  // Services
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();
  final BookingService _bookingService = BookingService();
  final ServiceService _serviceService = ServiceService();
  
  // State
  bool _isLoading = true;
  String? _errorMessage;
  
  double _averageRating = 0.0;
  int _totalReviews = 0;

  List<ReviewModel> _allReviews = []; // Semua data asli
  List<ReviewModel> _filteredReviews = []; // Data setelah filter
  
  // Caches for lookup
  Map<String, UserModel> _usersCache = {};
  Map<String, BookingModel> _bookingsCache = {};
  Map<String, ServiceModel> _servicesCache = {};
  
  String _selectedFilter = 'semua'; // semua, belum-dibalas, sudah-dibalas, 5-bintang, 1-2-bintang
  String _selectedSort = 'terbaru'; // terbaru, terlama, rating-tinggi, rating-rendah
  
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
        _reviewService.getAllReviews(),
        _userService.getAllUsers(),
        _bookingService.getAllBookings(),
        _serviceService.getAllServices(),
      ]);
      
      _allReviews = results[0] as List<ReviewModel>;
      
      // Build caches
      _usersCache = {};
      for (var user in (results[1] as List<UserModel>)) {
        _usersCache[user.id] = user;
      }
      
      _bookingsCache = {};
      for (var booking in (results[2] as List<BookingModel>)) {
        _bookingsCache[booking.id] = booking;
      }
      
      _servicesCache = {};
      for (var service in (results[3] as List<ServiceModel>)) {
        _servicesCache[service.id] = service;
      }
      
      // Apply filters
      _applyFilters();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }
  
  // Helper methods for data lookup
  String _getCustomerName(String userId) {
    return _usersCache[userId]?.name ?? 'Pelanggan';
  }
  
  String _getServiceName(String bookingId) {
    final booking = _bookingsCache[bookingId];
    if (booking != null) {
      final service = _servicesCache[booking.service_id];
      return service?.name ?? 'Layanan';
    }
    return 'Layanan';
  }
  
  String _getBookingCode(String bookingId) {
    final booking = _bookingsCache[bookingId];
    return booking?.booking_code ?? bookingId;
  }
  
  void _applyFilters() {
    // Reset ke semua data dulu
    _filteredReviews = List.from(_allReviews);
    
    // Apply filter berdasarkan _selectedFilter
    switch (_selectedFilter) {
      case 'belum-dibalas':
        _filteredReviews = _filteredReviews.where((review) => !review.isRespondedBool).toList();
        break;
      case 'sudah-dibalas':
        _filteredReviews = _filteredReviews.where((review) => review.isRespondedBool).toList();
        break;
      case '5-bintang':
        _filteredReviews = _filteredReviews.where((review) => review.ratingInt == 5).toList();
        break;
      case '4-bintang':
        _filteredReviews = _filteredReviews.where((review) => review.ratingInt == 4).toList();
        break;
      case '3-bintang':
        _filteredReviews = _filteredReviews.where((review) => review.ratingInt == 3).toList();
        break;
      case '1-2-bintang':
        _filteredReviews = _filteredReviews.where((review) => review.ratingInt <= 2).toList();
        break;
      case 'semua':
      default:
        // Tidak ada filter tambahan
        break;
    }
    
    // Apply sorting berdasarkan _selectedSort
    _applySorting();
    
    // Update statistics
    _updateStatistics();
    
    setState(() {});
  }
  
  void _applySorting() {
    switch (_selectedSort) {
      case 'terbaru':
        _filteredReviews.sort((a, b) => b.created_at.compareTo(a.created_at));
        break;
      case 'terlama':
        _filteredReviews.sort((a, b) => a.created_at.compareTo(b.created_at));
        break;
      case 'rating-tinggi':
        _filteredReviews.sort((a, b) => b.ratingInt.compareTo(a.ratingInt));
        break;
      case 'rating-rendah':
        _filteredReviews.sort((a, b) => a.ratingInt.compareTo(b.ratingInt));
        break;
    }
  }
  
  void _updateStatistics() {
    if (_filteredReviews.isEmpty) {
      _averageRating = 0;
      _totalReviews = 0;
      return;
    }
    
    // Hitung rating rata-rata dari filtered reviews
    final totalRating = _filteredReviews.fold<double>(0, (sum, review) => sum + review.ratingDouble);
    _averageRating = totalRating / _filteredReviews.length;
    _totalReviews = _filteredReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Ulasan & Rating',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Ulasan & Rating',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: Center(
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
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(), // Kembali ke halaman sebelumnya
        ),        
        title: const Text(
          'Ulasan & Rating',
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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            color: Colors.grey[700],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: Column(
          children: [
            // Rating summary
            _buildRatingSummary(),
            
            // Filter section
            _buildFilterSection(),
            
            // Reviews list
            Expanded(
              child: _filteredReviews.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filteredReviews.length,
                      itemBuilder: (context, index) {
                        final review = _filteredReviews[index];
                        return _buildReviewCard(review);
                      },
                    ),
            ),
          ],
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
            Icons.reviews,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada ulasan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'semua' 
              ? 'Belum ada ulasan untuk ditampilkan'
              : 'Tidak ada ulasan dengan filter "${_getFilterDisplayName()}"',
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
              child: const Text('Tampilkan Semua Ulasan'),
            ),
        ],
      ),
    );
  }

  String _getFilterDisplayName() {
    switch (_selectedFilter) {
      case 'semua': return 'Semua Ulasan';
      case 'belum-dibalas': return 'Belum Dibalas';
      case 'sudah-dibalas': return 'Sudah Dibalas';
      case '5-bintang': return '5 Bintang';
      case '4-bintang': return '4 Bintang';
      case '3-bintang': return '3 Bintang';
      case '1-2-bintang': return '1-2 Bintang';
      default: return _selectedFilter;
    }
  }  

  Widget _buildRatingSummary() {
    // Hitung distribusi rating dari filtered reviews
    final ratingDistribution = _calculateRatingDistribution();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Overall rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 24,
                        color: index < _averageRating.floor()
                            ? Colors.amber
                            : _averageRating - index > 0 && _averageRating - index < 1
                                ? Colors.amber.withOpacity(0.5)
                                : Colors.grey[300],
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalReviews ulasan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating distribution
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatingDistribution(5, ratingDistribution[5] ?? 0),
              _buildRatingDistribution(4, ratingDistribution[4] ?? 0),
              _buildRatingDistribution(3, ratingDistribution[3] ?? 0),
              _buildRatingDistribution(2, ratingDistribution[2] ?? 0),
              _buildRatingDistribution(1, ratingDistribution[1] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Map<int, int> _calculateRatingDistribution() {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    for (var review in _filteredReviews) {
      final rating = review.ratingInt;
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }
    
    // Convert to percentage
    if (_totalReviews > 0) {
      for (var key in distribution.keys) {
        distribution[key] = ((distribution[key]! / _totalReviews) * 100).round();
      }
    }
    
    return distribution;
  }

  Widget _buildRatingDistribution(int stars, int percentage) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stars.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.star, size: 16, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: (percentage / 100) * 80,
                decoration: BoxDecoration(
                  color: stars >= 4 ? Colors.green : stars == 3 ? Colors.amber : Colors.orange,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.filter_list, size: 16),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                      _applyFilters();
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'semua', child: Text('Semua Ulasan')),
                    DropdownMenuItem(value: 'belum-dibalas', child: Text('Belum Dibalas')),
                    DropdownMenuItem(value: '5-bintang', child: Text('5 Bintang')),
                    DropdownMenuItem(value: '1-2-bintang', child: Text('1-2 Bintang')),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                icon: const Icon(Icons.sort, size: 16),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSort = newValue!;
                    _applyFilters();
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                  DropdownMenuItem(value: 'terlama', child: Text('Terlama')),
                  DropdownMenuItem(value: 'rating-tinggi', child: Text('Rating Tertinggi')),
                  DropdownMenuItem(value: 'rating-rendah', child: Text('Rating Terendah')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final reviewDate = review.createdAtOrNull ?? DateTime.now();
    final responseDate = review.responseDateOrNull;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info and rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCustomerName(review.user_id),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getServiceName(review.booking_id),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: index < review.ratingInt
                          ? Colors.amber
                          : Colors.grey[300],
                    );
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Review comment
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Booking info
            Row(
              children: [
                Icon(Icons.receipt, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _getBookingCode(review.booking_id),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(reviewDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Admin response
            if (review.isRespondedBool && review.response_admin.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Balasan Admin',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            const Spacer(),
                            if (responseDate != null)
                              Text(
                                _dateFormat.format(responseDate),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.response_admin,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!review.isRespondedBool)
                  ElevatedButton.icon(
                    onPressed: () => _respondToReview(review),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Balas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                
                if (review.isRespondedBool)
                  OutlinedButton.icon(
                    onPressed: () => _editResponse(review),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Balasan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                IconButton(
                  icon: Icon(
                    review.ratingInt >= 4 ? Icons.thumb_up : Icons.flag,
                    size: 20,
                    color: review.ratingInt >= 4 ? Colors.green : Colors.orange,
                  ),
                  onPressed: () => review.ratingInt >= 4 
                      ? _featureReview(review)
                      : _reportReview(review),
                  tooltip: review.ratingInt >= 4 ? 'Tandai sebagai Favorit' : 'Laporkan Ulasan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Lanjutan'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filter by date range
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rentang Tanggal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDateRangePicker(context, setState),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: const Text('Pilih Tanggal'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Reset filters
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'semua';
                          _selectedSort = 'terbaru';
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
      },
    );
  }

  void _showDateRangePicker(BuildContext context, StateSetter setState) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    
    if (picked != null) {
      // Implement date range filtering
    }
  }


  void _respondToReview(ReviewModel review) {
    final TextEditingController responseController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Ulasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ulasan dari ${_getCustomerName(review.user_id)}:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.comment,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                hintText: 'Ketik balasan Anda di sini...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
              if (responseController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi balasan terlebih dahulu'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await _reviewService.addAdminResponse(
                  reviewId: review.id,
                  adminName: 'Admin',
                  response: responseController.text,
                );
                
                await _loadAllData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ulasan telah dibalas'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal membalas ulasan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim Balasan'),
          ),
        ],
      ),
    );
  }

  void _editResponse(ReviewModel review) {
    final TextEditingController responseController = TextEditingController(text: review.response_admin);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Balasan'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            hintText: 'Edit balasan...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
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
                // Update using the service
                final updatedReview = review.copyWith(
                  response_admin: responseController.text,
                  response_date: DateTime.now().toIso8601String(),
                );
                
                await _reviewService.updateReview(updatedReview);
                await _loadAllData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Balasan telah diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memperbarui balasan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  void _featureReview(ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai sebagai Favorit'),
        content: const Text('Apakah Anda ingin menampilkan ulasan ini sebagai ulasan terpilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ulasan dari ${_getCustomerName(review.user_id)} ditandai sebagai favorit'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Tandai'),
          ),
        ],
      ),
    );
  }

  void _reportReview(ReviewModel review) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Ulasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alasan pelaporan:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan pelaporan',
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
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi alasan pelaporan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ulasan dari ${_getCustomerName(review.user_id)} telah dilaporkan'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }
}