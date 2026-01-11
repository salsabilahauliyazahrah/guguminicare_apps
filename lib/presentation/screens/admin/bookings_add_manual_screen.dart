import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AddManualBookingScreen extends StatefulWidget {
  const AddManualBookingScreen({super.key});

  @override
  State<AddManualBookingScreen> createState() => _AddManualBookingScreenState();
}

class _AddManualBookingScreenState extends State<AddManualBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MMM/yyyy');
  // ignore: unused_field
  final DateFormat _timeFormat = DateFormat('HH:mm');
  
  // Form controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _petTypeController = TextEditingController();
  final TextEditingController _petWeightController = TextEditingController();
  final TextEditingController _specialNotesController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  
  // Form state
  String _selectedService = 'Premium Grooming';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedMethod = 'Datang ke Salon';
  String _selectedDriver = '-';
  String _selectedPaymentMethod = 'COD';
  String _selectedPaymentStatus = 'pending';
  
  // Dummy data untuk dropdown
  final List<String> _services = [
    'Premium Grooming',
    'Basic Grooming',
    'Spa Treatment',
    'Special Package',
    'Medical Grooming',
  ];
  
  final List<String> _serviceMethods = [
    'Datang ke Salon',
    'Home Service',
    'Antar Jemput',
  ];
  
  final List<String> _drivers = [
    '-',
    'Ahmad Santoso',
    'Budi Wijaya',
    'Cici Amelia',
    'Dodi Pratama',
  ];
  
  final List<String> _paymentMethods = [
    'COD',
    'Transfer Bank',
    'QRIS',
    'E-Wallet',
  ];
  
  final List<String> _paymentStatuses = [
    'pending',
    'lunas',
    'dibatalkan',
  ];

  // Tambahkan di atas class atau di dalam state class
  final Map<String, int> _servicePrices = {
    'Premium Grooming': 180000,
    'Basic Grooming': 120000,
    'Spa Treatment': 200000,
    'Special Package': 250000,
    'Medical Grooming': 300000,
  };

  // Tambahkan juga untuk biaya tambahan berdasarkan metode
  final Map<String, int> _methodAdditionalFees = {
    'Datang ke Salon': 0,
    'Home Service': 50000,
    'Antar Jemput': 25000,
  };

  // List untuk dropdown hewan
  final List<String> _petTypes = ['Kucing', 'Anjing', 'Kelinci'];
  final Map<String, List<String>> _breedsByType = {
    'Kucing': ['Persia', 'Anggora', 'Siam', 'Domestik', 'British Shorthair', 'Maine Coon'],
    'Anjing': ['Golden Retriever', 'Poodle', 'Bulldog', 'Chihuahua', 'Husky', 'Beagle'],
    'Kelinci': ['Holland Lop', 'Netherland Dwarf', 'Flemish Giant'],
  };
  
  // State untuk dropdown hewan
  String _selectedPetType = 'Kucing';
  String _selectedBreed = 'Persia';  

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _petNameController.dispose();
    _petTypeController.dispose();
    _petWeightController.dispose();
    _specialNotesController.dispose();
    _totalPriceController.dispose();
    super.dispose();
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
          'Tambah Booking Manual',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBooking,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nama Pelanggan
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan*',
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Budi Santoso',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pelanggan harus diisi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Nomor Telepon
                      TextFormField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon*',
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 081234567890',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon harus diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pet Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Hewan Peliharaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Nama Hewan
                          Expanded(
                            child: TextFormField(
                              controller: _petNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Hewan*',
                                border: OutlineInputBorder(),
                                hintText: 'Contoh: Rocky',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama hewan harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Jenis Hewan - DROPDOWN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedPetType,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _petTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPetType = value;
                                        // Reset breed ke default untuk jenis yang dipilih
                                        _selectedBreed = _breedsByType[value]?.first ?? '';
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih jenis hewan';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Breed/Ras Hewan - DROPDOWN
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ras Hewan*',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedBreed,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _breedsByType[_selectedPetType]?.map((breed) {
                              return DropdownMenuItem(
                                value: breed,
                                child: Text(breed),
                              );
                            }).toList() ?? [],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedBreed = value;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih ras hewan';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),                      

                      // Berat Hewan
                      TextFormField(
                        controller: _petWeightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Berat Hewan (kg)',
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                          hintText: 'Contoh: 5',
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Catatan Khusus
                      TextFormField(
                        controller: _specialNotesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Khusus',
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Alergi, penyakit khusus, dll.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Service & Schedule Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Layanan & Jadwal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Pilih Layanan
                      const Text(
                        'Pilih Layanan*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _services.map((service) {
                          return DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedService = value!;
                            // Auto set harga berdasarkan layanan
                            _setPriceBasedOnService(value);
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih layanan';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Tanggal Booking
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Booking*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_dateFormat.format(_selectedDate)),
                                        const Icon(Icons.calendar_today, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Waktu Booking
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Waktu Booking*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_selectedTime.format(context)),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Metode Layanan
                      const Text(
                        'Metode Layanan*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _serviceMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMethod = value!;
                            // Jika pilih "Datang ke Salon", set driver ke "-"
                            if (value == 'Datang ke Salon') {
                              _selectedDriver = '-';
                            } else if (_selectedDriver == '-') {
                              // Jika belum pilih driver, set ke driver pertama
                              _selectedDriver = 'Ahmad Santoso';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih metode layanan';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Driver (hanya tampil jika metode bukan "Datang ke Salon")
                      if (_selectedMethod != 'Datang ke Salon')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Driver*',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedDriver,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _drivers.where((driver) => driver != '-').map((driver) {
                                return DropdownMenuItem(
                                  value: driver,
                                  child: Text(driver),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDriver = value!;
                                });
                              },
                              validator: (value) {
                                if (_selectedMethod != 'Datang ke Salon' && (value == null || value == '-')) {
                                  return 'Pilih driver';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Payment Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Total Harga
                      TextFormField(
                        controller: _totalPriceController,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Total Harga (Rp)*',
                          border: const OutlineInputBorder(),
                          prefixText: 'Rp ',
                          hintText: '180000',
                          filled: true,                          
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Metode Pembayaran
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Metode Pembayaran*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                DropdownButtonFormField<String>(
                                  value: _selectedPaymentMethod,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  ),
                                  items: _paymentMethods.map((method) {
                                    return DropdownMenuItem(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMethod = value!;
                                      // Jika pilih "Datang ke Salon", set driver ke "-"
                                      if (value == 'Datang ke Salon') {
                                        _selectedDriver = '-';
                                      } else if (_selectedDriver == '-') {
                                        // Jika belum pilih driver, set ke driver pertama
                                        _selectedDriver = 'Ahmad Santoso';
                                      }
                                      
                                      // UPDATE HARGA SETELAH GANTI METODE
                                      _updateTotalPrice();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih metode pembayaran';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Status Pembayaran
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Pembayaran*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedPaymentStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _paymentStatuses.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(_getPaymentStatusLabel(status)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentStatus = value!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih status pembayaran';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),                          
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Harga:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Harga Layanan
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Harga Layanan:'),
                                Text(
                                  'Rp ${_formatCurrency(_servicePrices[_selectedService] ?? 0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Biaya Tambahan
                            if (_methodAdditionalFees[_selectedMethod]! > 0)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Biaya ${_selectedMethod}:'),
                                      Text(
                                        'Rp ${_formatCurrency(_methodAdditionalFees[_selectedMethod] ?? 0)}',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            
                            // Garis pemisah
                            const Divider(height: 1),
                            const SizedBox(height: 4),
                            
                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rp ${_getFormattedTotalPrice()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),                                        
                      
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveBooking,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper untuk mendapatkan label status pembayaran
  String _getPaymentStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'lunas': return 'Lunas';
      case 'dibatalkan': return 'Dibatalkan';
      default: return status;
    }
  }
  
  // Auto set harga berdasarkan layanan
  void _setPriceBasedOnService(String service) {
    final basePrice = _servicePrices[service] ?? 0;
    final additionalFee = _methodAdditionalFees[_selectedMethod] ?? 0;
    final totalPrice = basePrice + additionalFee;
    
    // Format dengan separator ribuan
    final formattedPrice = NumberFormat('#,##0', 'id_ID').format(totalPrice);
    _totalPriceController.text = formattedPrice;
  }
  
  // Pilih tanggal
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orangeMedium,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // Pilih waktu
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orangeMedium,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  // Simpan booking
  void _saveBooking() {
    if (_formKey.currentState!.validate()) {
      // Generate ID booking baru
      final now = DateTime.now();
      final bookingId = 'BOOK-${DateFormat('yyyyMMdd').format(now)}${_allBookings.length + 1}';
      
      // Parse total price (hapus separator jika ada)
      final priceText = _totalPriceController.text.replaceAll('.', '');
      final totalPrice = int.tryParse(priceText) ?? _getTotalPrice();
      
      // Buat booking baru
      // ignore: unused_local_variable
      final newBooking = {
        'id': bookingId,
        'customer_name': _customerNameController.text,
        'pet_name': _petNameController.text,
        'pet_type': _selectedPetType, // Simpan jenis hewan
        'pet_breed': _selectedBreed,  // Simpan ras hewan
        'service': _selectedService,
        'date': _selectedDate,
        'time': _selectedTime.format(context),
        'method': _selectedMethod,
        'driver_name': _selectedDriver,
        'status': 'pending',
        'status_text': 'Menunggu Konfirmasi',
        'status_color': Colors.orange,
        'total_price': totalPrice,
        'payment_status': _selectedPaymentStatus,
        'payment_method': _selectedPaymentMethod,
        'phone': _customerPhoneController.text,
        'pet_weight': _petWeightController.text,
        'special_notes': _specialNotesController.text,
      };
      
      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking $bookingId berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Kembali ke halaman sebelumnya
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Dummy data untuk contoh (harusnya diambil dari state management)
  List<Map<String, dynamic>> get _allBookings {
    return []; // Ini akan diisi dari Provider/state management
  }

  // Method untuk update harga total
  void _updateTotalPrice() {
    if (_selectedService.isNotEmpty) {
      final basePrice = _servicePrices[_selectedService] ?? 0;
      final additionalFee = _methodAdditionalFees[_selectedMethod] ?? 0;
      final totalPrice = basePrice + additionalFee;
      
      // Update controller
      _totalPriceController.text = _formatCurrency(totalPrice);
      
      // Optional: Tampilkan detail breakdown
      _showPriceBreakdown(basePrice, additionalFee);
    }
  }

  // Optional: Tampilkan detail harga
  void _showPriceBreakdown(int basePrice, int additionalFee) {
    // Bisa ditampilkan sebagai snackbar atau di UI
    if (additionalFee > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga: Rp${NumberFormat('#,##0').format(basePrice)} '
            '+ Biaya ${_selectedMethod}: Rp${NumberFormat('#,##0').format(additionalFee)} '
            '= Total: Rp${NumberFormat('#,##0').format(basePrice + additionalFee)}',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Buat method untuk format currency
  String _formatCurrency(int amount) {
    return NumberFormat('#,##0', 'id_ID').format(amount);
  }  

  // Helper untuk mendapatkan total price yang sudah diformat
  String _getFormattedTotalPrice() {
    final basePrice = _servicePrices[_selectedService] ?? 0;
    final additionalFee = _methodAdditionalFees[_selectedMethod] ?? 0;
    final totalPrice = basePrice + additionalFee;
    return _formatCurrency(totalPrice);
  }

  // Helper untuk mendapatkan total price sebagai int
  int _getTotalPrice() {
    final basePrice = _servicePrices[_selectedService] ?? 0;
    final additionalFee = _methodAdditionalFees[_selectedMethod] ?? 0;
    return basePrice + additionalFee;
  }  
}