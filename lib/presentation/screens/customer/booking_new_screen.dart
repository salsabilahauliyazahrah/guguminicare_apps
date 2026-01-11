import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:tugas_akhir/presentation/screens/services/booking_service.dart';
import 'package:tugas_akhir/presentation/screens/services/address_service.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';

class BookingNewScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;
  final bool isQuickBooking; // Tambah parameter ini

  const BookingNewScreen({
    super.key, 
    this.extraData,
    this.isQuickBooking = false, // Default false
  });

  @override
  State<BookingNewScreen> createState() => _BookingNewScreenState();
}

class _BookingNewScreenState extends State<BookingNewScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Data pilihan - di-load dari API dan di-map agar UI tetap sama
  final List<Map<String, dynamic>> pets = [];
  final List<Map<String, dynamic>> services = [];

  // Services
  final PetService _petService = PetService();
  final ServiceService _serviceService = ServiceService();
  final BookingService _bookingService = BookingService();
  final AddressService _addressService = AddressService();
  String? _userId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> serviceMethods = [
    {'id': 'salon', 'name': 'Datang ke Salon', 'icon': Icons.store},
    {'id': 'home', 'name': 'Home Service', 'icon': Icons.home},
    {'id': 'pickup', 'name': 'Antar Jemput', 'icon': Icons.directions_car, 'fee': 25000},
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'cod', 'name': 'Cash on Delivery (COD)', 'icon': Icons.money},
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': Icons.account_balance},
    {'id': 'qris', 'name': 'QRIS', 'icon': Icons.qr_code},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': Icons.phone_android},
  ];

  // Form values
  int? _selectedPetId;
  int? _selectedServiceId;
  String? _selectedServiceMethod;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // State untuk expandable sections
  bool _dateExpanded = true;
  bool _timeExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Ambil user id
      final userId = StorageHelper.getString('user_id');
      _userId = userId;
      if (userId == null || userId.isEmpty) {
        _showErrorSnackbar('Sesi tidak ditemukan. Silakan login ulang.');
        setState(() => _isLoading = false);
        return;
      }

      // Ambil data dari API
      final loadedPets = await _petService.getPetsByUserId(userId);
      final loadedServices = await _serviceService.getAllServices();

      // Map ke struktur yang dipakai UI (tanpa ubah tampilan)
      pets.clear();
      for (var i = 0; i < loadedPets.length; i++) {
        final p = loadedPets[i];
        pets.add({
          'id': i + 1, // id tampilan
          'name': p.name,
          'type': p.type,
          'breed': p.breed ?? '-',
          'modelId': p.id, // id asli untuk API
        });
      }

      services.clear();
      for (var i = 0; i < loadedServices.length; i++) {
        final s = loadedServices[i];
        services.add({
          'id': i + 1, // id tampilan
          'name': s.name,
          'price': int.tryParse(s.price) ?? 0,
          'duration': s.duration,
          'modelId': s.id, // id asli untuk API
        });
      }

      // Preselect dari extraData (jika ada)
      if (widget.extraData != null) {
        final petId = widget.extraData!['petId']?.toString();
        if (petId != null && petId.isNotEmpty) {
          final match = pets.firstWhere(
            (p) => p['modelId']?.toString() == petId,
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            _selectedPetId = match['id'] as int?;
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Gagal memuat data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text( // TANPA const
          'Buat Booking Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16), // TANPA const (opsional)
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Pilih Hewan
              _buildSection(
                title: 'Pilih Hewan',
                icon: Icons.pets,
                child: Column(
                  children: pets.map((pet) {
                    final isSelected = _selectedPetId == pet['id'];
                    return _buildSelectableCard(
                      title: pet['name'],
                      subtitle: '${pet['breed']} • ${pet['type']}',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedPetId = pet['id']),
                      icon: pet['type'] == 'Kucing' 
                          ? Icons.pets 
                          : Icons.psychology,
                      iconColor: pet['type'] == 'Kucing' 
                          ? Colors.blue 
                          : Colors.amber,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24), // TANPA const

              // Section 2: Pilih Layanan
              _buildSection(
                title: 'Pilih Layanan',
                icon: Icons.spa,
                child: Column(
                  children: services.map((service) {
                    final isSelected = _selectedServiceId == service['id'];
                    return _buildSelectableCard(
                      title: service['name'],
                      subtitle: 'Rp ${NumberFormat('#,##0').format(service['price'])} • ${service['duration']}',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedServiceId = service['id']),
                      icon: Icons.clean_hands,
                      iconColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24), // TANPA const

              // Section 3: Pilih Metode Layanan
              _buildSection(
                title: 'Metode Layanan',
                icon: Icons.delivery_dining,
                child: Column(
                  children: serviceMethods.map((method) {
                    final isSelected = _selectedServiceMethod == method['id'];
                    return _buildSelectableCard(
                      title: method['name'],
                      subtitle: method['fee'] != null 
                          ? 'Biaya tambahan: Rp ${NumberFormat('#,##0').format(method['fee'])}'
                          : 'Tidak ada biaya tambahan',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedServiceMethod = method['id']),
                      icon: method['icon'],
                      iconColor: Colors.green,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24), // TANPA const

              // Section 4: Pilih Tanggal (Expandable)
              _buildExpandableSection(
                title: 'Tanggal Grooming',
                icon: Icons.calendar_today,
                isExpanded: _dateExpanded,
                onExpansionChanged: (expanded) => setState(() => _dateExpanded = expanded),
                child: Column(
                  children: [
                    // Kalender sederhana
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(14, (index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected = _selectedDate != null &&
                              _selectedDate!.day == date.day &&
                              _selectedDate!.month == date.month;
                          final isToday = index == 0;
                          final isWeekend = date.weekday == 6 || date.weekday == 7;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = date),
                            child: Container(
                              width: 70,
                              margin: EdgeInsets.only(right: 8), // TANPA const
                              padding: EdgeInsets.all(12), // TANPA const
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary
                                      : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE').format(date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isWeekend ? Colors.red : Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4), // TANPA const
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected 
                                          ? AppColors.primary 
                                          : isToday 
                                              ? Colors.green
                                              : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4), // TANPA const
                                  Text(
                                    DateFormat('MMM').format(date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected 
                                          ? AppColors.primary 
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 8), // TANPA const
                    if (_selectedDate != null)
                      Text(
                        'Tanggal dipilih: ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16), // TANPA const

              // Section 5: Pilih Waktu (Expandable)
              _buildExpandableSection(
                title: 'Waktu Grooming',
                icon: Icons.access_time,
                isExpanded: _timeExpanded,
                onExpansionChanged: (expanded) => setState(() => _timeExpanded = expanded),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '08:00', '09:00', '10:00', '11:00', 
                    '13:00', '14:00', '15:00', '16:00',
                  ].map((time) {
                    final isSelected = _selectedTime != null &&
                        '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}' == time;
                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          final parts = time.split(':');
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: int.parse(parts[0]),
                              minute: int.parse(parts[1]),
                            );
                          });
                        }
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24), // TANPA const

              // Section 7: Pilih Metode Pembayaran
              _buildSection(
                title: 'Metode Pembayaran',
                icon: Icons.payment,
                child: Column(
                  children: paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method['id'];
                    return _buildSelectableCard(
                      title: method['name'],
                      subtitle: 'Pembayaran ${method['id'] == 'cod' ? 'saat grooming selesai' : 'online'}',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedPaymentMethod = method['id']),
                      icon: method['icon'],
                      iconColor: Colors.purple,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 32), // TANPA const

              // Summary dan Tombol Submit
              if (_selectedPetId != null && _selectedServiceId != null)
                _buildBookingSummary(),
              SizedBox(height: 16), // TANPA const

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Membuat...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Buat Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 32), // TANPA const
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            SizedBox(width: 8), // TANPA const
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12), // TANPA const
        child,
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // TANPA const
        title: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            SizedBox(width: 12), // TANPA const
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey,
        ),
        initiallyExpanded: true,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16), // TANPA const
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      elevation: 0,
      color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final pet = pets.firstWhere((p) => p['id'] == _selectedPetId!);
    final service = services.firstWhere((s) => s['id'] == _selectedServiceId!);
    final serviceMethod = serviceMethods.firstWhere(
      (m) => m['id'] == _selectedServiceMethod,
      orElse: () => serviceMethods[0],
    );
    final paymentMethod = paymentMethods.firstWhere(
      (p) => p['id'] == _selectedPaymentMethod,
      orElse: () => paymentMethods[0],
    );

    final basePrice = service['price'] as int;
    final additionalFee = (serviceMethod['fee'] as int?) ?? 0;
    final totalPrice = basePrice + additionalFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Booking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Hewan', '${pet['name']} (${pet['breed']})'),
          _buildSummaryRow('Layanan', service['name'] as String),
          _buildSummaryRow('Metode Layanan', serviceMethod['name'] as String),
          if (_selectedDate != null)
            _buildSummaryRow(
              'Tanggal',
              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!),
            ),
          if (_selectedTime != null)
            _buildSummaryRow(
              'Waktu',
              '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
            ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Harga Layanan',
            'Rp ${NumberFormat('#,##0').format(basePrice)}',
            isBold: false,
          ),
          if (additionalFee > 0)
            _buildSummaryRow(
              'Biaya Tambahan',
              'Rp ${NumberFormat('#,##0').format(additionalFee)}',
              isBold: false,
            ),
          _buildSummaryRow(
            'Total Biaya',
            'Rp ${NumberFormat('#,##0').format(totalPrice)}',
            isBold: true,
            color: AppColors.primary,
          ),
          _buildSummaryRow('Metode Bayar', paymentMethod['name'] as String, isBold: false),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      )
    );
  }

  void _submitBooking() {
    // Validasi form
    if (_selectedPetId == null) {
      _showErrorSnackbar('Harap pilih hewan terlebih dahulu');
      return;
    }

    if (_selectedServiceId == null) {
      _showErrorSnackbar('Harap pilih layanan terlebih dahulu');
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackbar('Harap pilih tanggal grooming');
      return;
    }

    if (_selectedTime == null) {
      _showErrorSnackbar('Harap pilih waktu grooming');
      return;
    }

    if (_selectedPaymentMethod == null) {
      _showErrorSnackbar('Harap pilih metode pembayaran');
      return;
    }

    // Ambil data terpilih
    final pet = pets.firstWhere((p) => p['id'] == _selectedPetId);
    final service = services.firstWhere((s) => s['id'] == _selectedServiceId);
    final serviceMethod = serviceMethods.firstWhere((m) => m['id'] == _selectedServiceMethod);
    // ignore: unused_local_variable
    final paymentMethod = paymentMethods.firstWhere((p) => p['id'] == _selectedPaymentMethod);

    // Tampilkan konfirmasi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin membuat booking ini?'),
            const SizedBox(height: 16),
            Text('📅 ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!)}'),
            Text('⏰ ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            Text('🐾 ${pet['name']} - ${service['name']}'),
            Text('💰 Rp ${NumberFormat('#,##0').format((service['price'] as int) + ((serviceMethod['fee'] as int?) ?? 0))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Periksa Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Booking Sekarang'),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking() async {
    try {
      setState(() => _isSubmitting = true);
      // Safety
      if (_userId == null || _userId!.isEmpty) {
        _showErrorSnackbar('Sesi tidak ditemukan. Silakan login ulang.');
        return;
      }

      final pet = pets.firstWhere((p) => p['id'] == _selectedPetId);
      final service = services.firstWhere((s) => s['id'] == _selectedServiceId);
      final serviceMethod = serviceMethods.firstWhere((m) => m['id'] == _selectedServiceMethod);

      final basePrice = (service['price'] as int);
      final additionalFee = (serviceMethod['fee'] as int?) ?? 0;
      final totalPrice = basePrice + additionalFee;

      // Format tanggal & waktu
      final bookingDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final bookingTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Alamat utama jika perlu
      String addressId = '';
      if (_selectedServiceMethod == 'home' || _selectedServiceMethod == 'pickup') {
        final primary = await _addressService.getPrimaryAddress(_userId!);
        if (primary != null) addressId = primary.id;
      }

      final booking = BookingModel(
        id: '',
        booking_code: 'GB-${DateTime.now().millisecondsSinceEpoch}',
        user_id: _userId!,
        pet_id: pet['modelId']?.toString() ?? '',
        service_id: service['modelId']?.toString() ?? '',
        booking_date: bookingDate,
        booking_time: bookingTime,
        service_method: _selectedServiceMethod!,
        address_id: addressId,
        driver_id: '',
        special_notes: '',
        total_price: totalPrice.toString(),
        additional_fee: additionalFee.toString(),
        payment_method: _selectedPaymentMethod!,
        payment_status: 'pending',
        booking_status: 'menunggu',
        created_at: DateTime.now().toIso8601String().split('.')[0],
      );

      await _bookingService.createBooking(booking);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibuat!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke halaman bookings
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) context.go('/bookings');
    } catch (e) {
      _showErrorSnackbar('Gagal membuat booking: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}