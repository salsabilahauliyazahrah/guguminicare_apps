// lib/presentation/screens/admin/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final UserModel customer;
  
  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final UserService _userService = UserService();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  
  late Future<List<PetModel>> _petsFuture;
  late Future<List<BookingModel>> _bookingsFuture;
  late Future<Map<String, dynamic>> _statsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _petsFuture = _userService.getPetsByUserId(widget.customer.id);
      _bookingsFuture = _userService.getUserBookings(widget.customer.id); // ✅ Pakai dari service
      _statsFuture = _userService.getUserBookingStats(widget.customer.id); // ✅ Pakai statistik dari service
    });
  }

  // Method untuk mendapatkan statistik pelanggan
  // ignore: unused_element
  Future<Map<String, dynamic>> _loadCustomerStats() async {
    try {
      return await _userService.getUserBookingStats(widget.customer.id);
    } catch (e) {
      return {
        'total_bookings': 0,
        'total_spent': 0,
        'completed_bookings': 0,
        'pending_bookings': 0,
        'has_bookings': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Pelanggan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editCustomer(customer),
          ),
          // Tombol toggle status (tetap sama tampilannya)
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final isActive = snapshot.data?['is_active'] ?? 
                              (widget.customer.role == 'customer'); // ✅
              return IconButton(
                icon: Icon(
                  isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: isActive ? Colors.green : Colors.red,
                ),
                onPressed: () => _toggleCustomerStatus(widget.customer),
              );
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, statsSnapshot) {
                if (statsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final stats = statsSnapshot.data ?? {};
                final currencyFormat = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header (SAMA PERSIS dengan versi lama)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.orangeMedium.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.orangeMedium,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.orangeMedium,
                                ),
                              ),
                              
                              const SizedBox(width: 20),
                              
                              // Customer Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      customer.email,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Status Badge (sama dengan versi lama)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (stats['is_active'] ?? (widget.customer.role == 'customer')) // ✅ Tambah ?? 
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        (stats['is_active'] ?? (widget.customer.role == 'customer')) // ✅
                                            ? 'AKTIF' 
                                            : 'TIDAK AKTIF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: (stats['is_active'] ?? (widget.customer.role == 'customer')) // ✅
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Contact Information (SAMA PERSIS)
                      _buildSection(
                        title: 'Informasi Kontak',
                        icon: Icons.contact_mail,
                        children: [
                          _buildInfoItem(
                            icon: Icons.phone,
                            label: 'Telepon',
                            value: customer.phone,
                          ),
                          _buildInfoItem(
                            icon: Icons.calendar_today,
                            label: 'Bergabung',
                            value: _formatDate(stats['join_date'] ?? customer.created_at),
                          ),
                          _buildInfoItem(
                            icon: Icons.person_pin,
                            label: 'ID Pelanggan',
                            value: customer.id,
                          ),
                          if (customer.birth_date.isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.cake,
                              label: 'Tanggal Lahir',
                              value: _formatDate(customer.birth_date),
                            ),
                          if (customer.gender.isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.person_outline,
                              label: 'Jenis Kelamin',
                              value: customer.gender == 'male' ? 'Laki-laki' : 'Perempuan',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Statistics (SAMA PERSIS)
                      _buildSection(
                        title: 'Statistik',
                        icon: Icons.analytics,
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'Total Booking',
                                value: stats['total_bookings'].toString(),
                                icon: Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _buildStatCard(
                                label: 'Total Pengeluaran',
                                value: currencyFormat.format(stats['total_spent'] ?? 0),
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Pets Information (Dengan data dari database)
                      _buildSection(
                        title: 'Hewan Peliharaan',
                        icon: Icons.pets,
                        children: [
                          FutureBuilder<List<PetModel>>(
                            future: _petsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              
                              final pets = snapshot.data ?? [];
                              
                              if (pets.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        size: 50,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Belum ada hewan peliharaan',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return Column(
                                children: pets.map<Widget>((pet) {
                                  return _buildPetCard(pet);
                                }).toList(),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Add Pet Button (SAMA)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _addNewPet(customer),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Hewan Baru'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orangeMedium,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Recent Activity (Optional - SAMA PERSIS)
                      _buildSection(
                        title: 'Riwayat Booking',
                        icon: Icons.history,
                        children: [
                          FutureBuilder<List<BookingModel>>(
                            future: _bookingsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              
                              if (snapshot.hasError) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Error: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              
                              final bookings = snapshot.data ?? [];
                              
                              if (bookings.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 40,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Belum ada booking',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              // Tampilkan semua booking
                              return Column(
                                children: bookings.map((booking) {
                                  return _buildSimpleBookingItem(booking);
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Action Buttons (SAMA)
                      Row(
                        children: [
                          // Edit Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _editCustomer(customer),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profil'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),                
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Danger Zone (SAMA PERSIS)
                      Card(
                        color: Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Zona Berbahaya',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tindakan ini tidak dapat dibatalkan. Hanya lakukan jika Anda yakin.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deactivateCustomer(customer, stats),
                                      icon: const Icon(Icons.block, size: 18),
                                      label: Text(
                                        (stats['is_active'] ?? true)
                                            ? 'Nonaktifkan'
                                            : 'Aktifkan',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deleteCustomer(customer),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Hapus'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _dateFormat.format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // ============ BUILD METHOD YANG SAMA PERSIS DENGAN VERSI LAMA ============
  
  Widget _buildSimpleBookingItem(BookingModel booking) {
    // Konversi booking_date ke DateTime untuk perhitungan
    final now = DateTime.now();
    final bookingDate = booking.bookingDateOrNull;
    
    String timeAgo = 'Waktu tidak diketahui';
    
    if (bookingDate != null) {
      final difference = now.difference(bookingDate);
      
      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        timeAgo = '$months bulan yang lalu';
      } else if (difference.inDays > 0) {
        timeAgo = '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes} menit yang lalu';
      } else {
        timeAgo = 'Baru saja';
      }
    }
    
    // Warna status
    Color statusColor;
    switch (booking.booking_status) {
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'diproses':
        statusColor = Colors.blue;
        break;
      case 'dibatalkan':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }
    
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point dengan warna status
            Container(
              margin: const EdgeInsets.only(top: 4, right: 12),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris pertama: "Booking" + waktu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Baris kedua: Kode booking
                  Text(
                    '#${booking.booking_code}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Baris ketiga: Info tambahan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(booking.booking_status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                      
                      // Harga menggunakan getter dari model
                      Text(
                        'Rp ${NumberFormat("#,###").format(booking.totalPriceDouble)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  
                  // Baris tambahan: Tanggal booking
                  if (bookingDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.formattedBookingDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk teks status
  String _getStatusText(String status) {
    switch (status) {
      case 'selesai': return 'Selesai';
      case 'diproses': return 'Diproses';
      case 'dibatalkan': return 'Dibatalkan';
      default: return 'Menunggu';
    }
  }

  // Helper untuk mendapatkan icon berdasarkan status
  // ignore: unused_element
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'selesai':
        return Icons.check_circle;
      case 'diproses':
        return Icons.autorenew;
      case 'dibatalkan':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.orangeMedium),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  


  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPetCard(PetModel pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Pet Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.orangeMedium.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pet.type == 'Kucing' ? Icons.pets : Icons.psychology,
              color: AppColors.orangeMedium,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.type} • ${pet.breed ?? "Tidak diketahui"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (pet.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${pet.age} tahun • ${pet.weight ?? 0} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editPet(pet),
                color: Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _deletePet(pet),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // ignore: unused_element
  Widget _buildActivityItem({
    required String activity,
    required String date,
    required String type,
  }) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'booking':
        icon = Icons.calendar_today;
        color = Colors.blue;
        break;
      case 'update':
        icon = Icons.edit;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // ============ ACTION METHODS YANG DIUPDATE DENGAN LOGIC DATABASE ============
  
  void _editCustomer(UserModel customer) async {
    final updatedCustomer = await context.push<UserModel>(
      '/admin/customers/${customer.id}/edit',
      extra: customer,
    );
    
    if (updatedCustomer != null) {
      // Reload data setelah edit
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pelanggan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _toggleCustomerStatus(UserModel customer) async {
    final currentStatus = customer.role == 'customer';
    final newStatus = !currentStatus;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus ? 'Aktifkan Pelanggan' : 'Nonaktifkan Pelanggan'
        ),
        content: Text(
          newStatus
              ? 'Apakah Anda yakin ingin mengaktifkan akun ${customer.name}?'
              : 'Apakah Anda yakin ingin menonaktifkan akun ${customer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() => _isLoading = true);
                
                // Update role di database
                final updatedCustomer = customer.copyWith(
                  role: newStatus ? 'customer' : 'inactive', // atau field lain untuk status
                );
                
                await _userService.updateUser(updatedCustomer);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  // Reload data
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newStatus
                            ? 'Pelanggan ${customer.name} telah diaktifkan'
                            : 'Pelanggan ${customer.name} telah dinonaktifkan',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengubah status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );
  }
  
  void _deactivateCustomer(UserModel customer, Map<String, dynamic> stats) async {
    final bool isActive = stats['is_active'] ?? (customer.role == 'customer');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isActive ? 'Nonaktifkan Pelanggan' : 'Aktifkan Pelanggan'
        ),
        content: Text(
          isActive
              ? 'Apakah Anda yakin ingin menonaktifkan akun ${customer.name}?'
              : 'Apakah Anda yakin ingin mengaktifkan akun ${customer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Tutup dialog
              Navigator.pop(context);
              
              // Simpan status lama untuk fallback
              final bool oldStatus = isActive;
              final bool newStatus = !oldStatus;
              
              // OPTIMISTIC UPDATE: Update UI dulu
              setState(() {
                stats['is_active'] = newStatus;
              });
              
              try {
                // Update ke database
                final updatedCustomer = customer.copyWith(
                  role: newStatus ? 'customer' : 'inactive',
                );
                
                await _userService.updateUser(updatedCustomer);
                
                // Refresh dari server (optional, untuk sinkronisasi)
                _loadData();
                
                // Tampilkan success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newStatus
                          ? '✅ ${customer.name} telah diaktifkan'
                          : '✅ ${customer.name} telah dinonaktifkan',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // ROLLBACK jika error
                setState(() {
                  stats['is_active'] = oldStatus;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Gagal: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
  }

  
  void _addNewPet(UserModel customer) async {
    final newPet = await context.push<PetModel>(
      '/admin/customers/${customer.id}/pets/add',
      extra: customer,
    );
    
    if (newPet != null) {
      // Refresh pets list
      _loadPets();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hewan ${newPet.name} berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _loadPets() {
    setState(() {
      _petsFuture = _userService.getPetsByUserId(widget.customer.id);
    });
  }

  void _editPet(PetModel pet) async {
    final result = await context.push<dynamic>(
      '/admin/customers/${widget.customer.id}/pets/edit',
      extra: {
        'customer': widget.customer,
        'pet': pet,
      },
    );
    
    if (result != null) {
      // Refresh pets list
      _loadPets();
    }
  }
  
  void _deletePet(PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus hewan ${pet.name} dari daftar peliharaan ${widget.customer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() => _isLoading = true);
                await _userService.deletePet(pet.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadPets();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hewan ${pet.name} berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  
  void _deleteCustomer(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pelanggan ${customer.name}? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() => _isLoading = true);
                // Implement delete user dari database
                // await _userService.deleteUser(customer.id);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  context.pop(); // Kembali ke halaman sebelumnya
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pelanggan ${customer.name} berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}