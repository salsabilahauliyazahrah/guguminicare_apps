// lib/presentation/screens/profile/address_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/address_model.dart';
import 'package:tugas_akhir/presentation/screens/customer/address_manager.dart';
import 'package:tugas_akhir/presentation/screens/services/address_service.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Gunakan List<AddressModel> bukan List<Map>
  List<AddressModel> addresses = [];
  final addressManager = AddressManager();
  final AddressService _addressService = AddressService();
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = StorageHelper.getString('user_id');
      if (userId == null || userId.isEmpty) {
        throw Exception('User belum login');
      }

      final loadedAddresses = await _addressService.getAddressesByUserId(userId);
      
      setState(() {
        addresses = loadedAddresses;
        isLoading = false;
      });

      // Simpan ke AddressManager agar bisa diakses dari halaman lain
      addressManager.updateAddresses(addresses);
    } catch (e) {
      print('❌ Error loading addresses: $e');
      setState(() {
        _errorMessage = e.toString();
        isLoading = false;
      });
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
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List Alamat
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : addresses.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadAddresses,
                            color: AppColors.primary,
                            child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return _buildAddressCard(address, context);
                            },
                          ),
                          ),
          ),
          
          // Tombol Tambah Alamat
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _goToAddAddress(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Alamat Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Memuat alamat...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Alamat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAddresses,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
            Icons.location_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Alamat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan alamat untuk penjemputan grooming',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => _goToAddAddress(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah Alamat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // ✅ PERBAIKAN: Gunakan getter isUtamaBool
          color: address.isUtamaBool 
              ? AppColors.primary 
              : Colors.grey[200]!,
          width: address.isUtamaBool ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama alamat dan status utama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getAddressIcon(address.jenis_alamat), // ✅ gunakan jenis_alamat
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.jenis_alamat,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // ✅ PERBAIKAN: Gunakan getter isUtamaBool
                if (address.isUtamaBool)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Utama',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Alamat lengkap
            Text(
              address.alamat_lengkap,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            
            // Kota dan Kode Pos
            Text(
              '${address.kota} • ${address.kode_pos}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // Catatan (jika ada)
            // ✅ PERBAIKAN: Cek apakah catatan kosong, bukan null
            if (address.catatan.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Catatan: ${address.catatan}',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _goToEditAddress(address),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setAsMainAddress(address),
                    icon: const Icon(Icons.star_border, size: 18),
                    label: const Text('Jadikan Utama'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteAddress(address, context),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAddressIcon(String jenis) {
    switch (jenis) {
      case 'rumah': return Icons.home;
      case 'kantor': return Icons.work;
      case 'apartemen': return Icons.apartment;
      default: return Icons.location_on;
    }
  }

  void _goToAddAddress() async {
    final result = await context.push<AddressModel?>(
      '/address/add',
    );
    
    if (result != null) {
      setState(() {
        // Tambahkan alamat baru dengan copy ID
        final newAddress = result.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          // Tidak perlu copy userid karena sudah ada dari result
        );
        
        addresses.add(newAddress);
        
        // ✅ PERBAIKAN: Jika alamat baru dijadikan utama
        if (newAddress.isUtamaBool) {
          addresses = addresses.map((addr) {
            return addr.id == newAddress.id 
                ? addr 
                // Set alamat lain menjadi bukan utama ('0')
                : addr.copyWith(is_utama: '0');
          }).toList();
        }
        
        // Update AddressManager
        addressManager.updateAddresses(addresses);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _goToEditAddress(AddressModel address) async {
    final result = await context.push<AddressModel?>(
      '/address/edit',
      extra: address,
    );
    
    if (result != null) {
      setState(() {
        final index = addresses.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          addresses[index] = result;
          
          // ✅ PERBAIKAN: Jika dijadikan utama
          if (result.isUtamaBool) {
            addresses = addresses.map((addr) {
              return addr.id == result.id 
                  ? addr 
                  // Set alamat lain menjadi bukan utama ('0')
                  : addr.copyWith(is_utama: '0');
            }).toList();
          }
          
          // Update AddressManager
          addressManager.updateAddresses(addresses);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _setAsMainAddress(AddressModel address) {
    print('🔄 [AddressScreen] Mengubah alamat utama ke: ${address.jenis_alamat} (ID: ${address.id})');

    setState(() {
      // ✅ PERBAIKAN: Set semua alamat bukan utama, set alamat ini sebagai utama
      addresses = addresses.map((addr) {
        return addr.id == address.id 
            ? addr.copyWith(is_utama: '1')  // Set sebagai utama
            : addr.copyWith(is_utama: '0'); // Set lainnya sebagai bukan utama
      }).toList();
      
      // Update AddressManager
      addressManager.updateAddresses(addresses);
    });

    // Cari alamat utama yang baru
    final newPrimaryAddress = addresses.firstWhere((a) => a.isUtamaBool);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address.jenis_alamat} dijadikan alamat utama'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Setelah snackbar, pop dengan data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('↪️ [AddressScreen] Mengembalikan alamat utama ke halaman sebelumnya');
      context.pop(newPrimaryAddress);
    });
  }

  void _deleteAddress(AddressModel address, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: Text('Apakah Anda yakin ingin menghapus alamat "${address.jenis_alamat}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                addresses.removeWhere((a) => a.id == address.id);
                
                // ✅ PERBAIKAN: Jika yang dihapus adalah alamat utama dan masih ada alamat lain
                if (address.isUtamaBool && addresses.isNotEmpty) {
                  // Set alamat pertama sebagai utama
                  addresses[0] = addresses[0].copyWith(is_utama: '1');
                }
                
                // Update AddressManager
                addressManager.updateAddresses(addresses);
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alamat berhasil dihapus'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
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

  // Method untuk refresh data jika diperlukan
  Future<void> refreshData() async {
    await _loadAddresses();
  }
}