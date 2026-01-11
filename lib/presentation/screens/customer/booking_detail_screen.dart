import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  
  const BookingDetailScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState(); // ✅ PERBAIKI INI
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  // Data booking yang bisa di-update
  late Map<String, dynamic> _bookingData;
  
  @override
  void initState() {
    super.initState();
    // Copy data dari widget ke state
    _bookingData = Map<String, dynamic>.from(widget.bookingData);
  }
  
  // ========================================
  // HELPER FUNCTIONS (PINDAHKAN KE SINI)
  // ========================================
  
  String _mapToDetailStatus(String statusCode, String statusText) {
    // Priority: status_text > status (code)
    if (statusText.isNotEmpty) {
      switch (statusText) {
        case 'Menunggu Konfirmasi':
          return 'Menunggu';
        case 'Diterima':
          return 'Menuju Lokasi';
        case 'Sedang Diproses':
          return 'Dalam Proses';
        case 'Selesai':
          return 'Hewan Diantar Kembali';
        case 'Dibatalkan':
          return 'Dibatalkan';
        default:
          return statusText;
      }
    }
    
    // Fallback to status code
    switch (statusCode) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Menuju Lokasi';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Hewan Diantar Kembali';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }
  
  bool isBookingCancellable(String status) {
    return status == 'Menunggu' || status == 'Menuju Lokasi';
  }

  bool isBookingEditable(String status) {
    return status == 'Menunggu' || status == 'Menuju Lokasi';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Menuju Lokasi':
      case 'Hewan Diantar Kembali':
        return Colors.green;
      case 'Dalam Proses':
        return Colors.blue;
      case 'Menunggu':
        return Colors.orange;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // ========================================
  // RATING DIALOG FUNCTION
  // ========================================
  void _showRatingDialog(BuildContext context) {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();
    bool isSubmitting = false;
    
    final bookingId = _bookingData['id'] ?? 'BOOK-002';
    final serviceName = _bookingData['service_name'] ?? 'Basic Grooming';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Beri Rating',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bagaimana pengalaman grooming $serviceName?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 40,
                          color: index < selectedRating ? Colors.amber : Colors.grey[300],
                        ),
                        padding: const EdgeInsets.all(4),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedRating == 0 ? 'Pilih rating' : '$selectedRating / 5',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedRating == 0 ? Colors.grey : Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Review Text
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      labelText: 'Ulasan (opsional)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Bagikan pengalaman Anda...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber, width: 2),
                      ),
                    ),
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (selectedRating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap pilih rating terlebih dahulu'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  setState(() {
                    isSubmitting = true;
                  });
                  
                  // Simulasi API call untuk submit rating
                  await Future.delayed(const Duration(seconds: 1));
                  
                  // ✅ UPDATE STATE DENGAN RATING BARU
                  this.setState(() {
                    _bookingData['rating'] = selectedRating;
                    _bookingData['review'] = reviewController.text.trim();
                  });
                  
                  // Tambahkan juga tanggal review
                  _bookingData['review_date'] = DateTime.now();
                  
                  setState(() {
                    isSubmitting = false;
                  });
                  
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terima kasih atas ulasan Anda!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  print('Rating submitted: $selectedRating');
                  print('Review: ${reviewController.text}');
                  print('Booking ID: $bookingId');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Ulasan'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // ========================================
  // BUILD METHOD - GUNAKAN _bookingData
  // ========================================
  @override
  Widget build(BuildContext context) {
    // Debug: print data yang diterima
    print('=== BOOKING DATA RECEIVED ===');
    print('Data: $_bookingData'); // ✅ GUNAKAN _bookingData
    print('Keys: ${_bookingData.keys.toList()}');
    print('============================');

    // Mapping data dari berbagai format ke format yang diharapkan
    // ✅ GUNAKAN _bookingData, BUKAN bookingData
    final bookingId = _bookingData['id'] ?? 'BOOK-002';
    final serviceName = _bookingData['service_name'] ?? 'Basic Grooming';
    final petName = _bookingData['pet_name'] ?? 'Rocky';
    final petType = _bookingData['pet_type'] ?? 'Anjing';
    
    // Handle date dari berbagai format (service_date atau date)
    final dynamic dateData = _bookingData['date'] ?? _bookingData['service_date']; // ✅
    final date = dateData is String 
        ? DateTime.tryParse(dateData) ?? DateTime(2025, 12, 26)
        : (dateData is DateTime ? dateData : DateTime(2025, 12, 26));
    
    // Handle time dari berbagai format (service_time atau time)
    final time = _bookingData['time'] ?? _bookingData['service_time'] ?? '14:00 - 15:30'; // ✅
    final serviceMethod = _bookingData['service_method'] ?? 'Antar Jemput'; // ✅
    final paymentMethod = _bookingData['payment_method'] ?? 'Online'; // ✅

    // Riview dan rating    
    final int? rating = _bookingData['rating'] is int 
        ? _bookingData['rating'] // ✅
        : (_bookingData['rating'] is num 
            ? (_bookingData['rating'] as num).toInt() 
            : null);
            
    final String? reviewComment = _bookingData['review'] as String?; // ✅
    final bool hasReviewed = rating != null && reviewComment != null && reviewComment.isNotEmpty;    

    // Mapping status dari berbagai format
    final String statusText = _bookingData['status_text'] ?? ''; // ✅
    final String status = _mapToDetailStatus(
      _bookingData['status'] ?? '', // ✅
      statusText
    );
    
    final statusDetail = _bookingData['status_detail'] ?? // ✅
                        _bookingData['estimated_pickup'] ?? 
                        (_bookingData['driver_status'] ?? '');
    
    final totalPrice = (_bookingData['total_price'] is int // ✅
        ? _bookingData['total_price'] 
        : (_bookingData['total_price'] is num 
            ? (_bookingData['total_price'] as num).toInt() 
            : 180000));
    
    final hasDriver = _bookingData['has_driver'] ?? // ✅
                     (_bookingData['service_method'] == 'Antar Jemput' ||
                      _bookingData['service_method'] == 'Antar Jemput');
    final driverFee = _bookingData['driver_fee'] is int // ✅
        ? _bookingData['driver_fee'] 
        : (_bookingData['service_method'] == 'Antar Jemput' ? 25000 : 0);
    
    // ignore: unused_local_variable
    final invoiceNumber = _bookingData['invoice_number'] ?? // ✅
                         'INV-${bookingId.replaceAll("BOOK-", "")}';

    // Widget untuk detail row
    Widget buildDetailRow({
      required IconData icon,
      required String title,
      required String value,
      bool showCheck = false,
      bool showCross = false,
    }) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (showCheck) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
          ],
          if (showCross) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.cancel,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ],
      );
    }

    // Widget untuk review section
    Widget _buildReviewSection() {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ulasan Anda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '$rating/5',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reviewComment != null && reviewComment.isNotEmpty)
              Text(
                reviewComment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Dikirim pada ${DateFormat('dd MMM yyyy').format(date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Widget untuk rating button
    Widget _buildRatingButton() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _showRatingDialog(context),
            icon: const Icon(Icons.star, size: 20),
            label: const Text(
              'Beri Rating & Ulasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookingId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: getStatusColor(status).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor(status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statusDetail != null && statusDetail.toString().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· $statusDetail',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Kartu detail booking
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                petType == 'Kucing' 
                                    ? Icons.pets 
                                    : Icons.psychology,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  petType,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  
                  // Detail waktu dan metode
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        buildDetailRow(
                          icon: Icons.calendar_today,
                          title: 'Tanggal',
                          value: DateFormat('dd MMM yyyy').format(date),
                        ),
                        const SizedBox(height: 12),
                        buildDetailRow(
                          icon: Icons.access_time,
                          title: 'Waktu',
                          value: time,
                        ),
                        const SizedBox(height: 12),
                        buildDetailRow(
                          icon: Icons.directions_car,
                          title: 'Metode Layanan',
                          value: serviceMethod,
                          showCheck: true,
                        ),
                        const SizedBox(height: 12),
                        buildDetailRow(
                          icon: Icons.payment,
                          title: 'Pembayaran',
                          value: paymentMethod,
                          showCross: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Informasi driver (jika ada)
            if (hasDriver && driverFee > 0) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Driver Lokal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat('#,##0').format(driverFee)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Total biaya
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Biaya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(totalPrice - driverFee)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (driverFee > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Biaya Driver',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,##0').format(driverFee)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0').format(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ TAMBAHKAN BAGIAN INI: Rating & Review Section
            const SizedBox(height: 8),
            
            // Tampilkan review jika sudah ada
            if (hasReviewed)
              _buildReviewSection(),
            
            // Tampilkan tombol rating jika belum ada review dan booking selesai
            if (!hasReviewed && status == 'Hewan Diantar Kembali')
              _buildRatingButton(),
            
            const SizedBox(height: 8),

            // Tombol aksi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Hanya tampilkan "Kelola Booking" jika ada aksi yang tersedia
                  if (isBookingCancellable(status) || isBookingEditable(status))
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _showBookingActions(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Kelola Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  if (isBookingCancellable(status) || isBookingEditable(status))
                    const SizedBox(height: 12),
                
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  // ========================================
  // OTHER HELPER FUNCTIONS (PINDAHKAN KE SINI)
  // ========================================
  
  void _showBookingActions(BuildContext context) {
    // ignore: unused_local_variable
    final bookingId = _bookingData['id'] ?? 'BOOK-002';
    // ignore: unused_local_variable
    final date = _bookingData['date'] is DateTime 
        ? _bookingData['date'] 
        : DateTime(2025, 12, 26);
    // ignore: unused_local_variable
    final totalPrice = (_bookingData['total_price'] is int 
        ? _bookingData['total_price'] 
        : 180000);
    
    // ... implementasi fungsi showBookingActions ...
  }
}