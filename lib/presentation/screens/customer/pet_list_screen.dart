import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final PetService _petService = PetService();
  Future<List<PetModel>>? _petsFuture; // ✅ Nullable
  String? _userId;
  bool _isLoading = true; // ✅ Tambah loading state

  @override
  void initState() {
    super.initState();
    print('🚀 initState() called');
    _loadPets(); // ✅ Panggil langsung
  }

  Future<void> _loadPets() async {
    print('🔄 _loadPets() called');
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      // ============ AMBIL USER_ID ============
      _userId = StorageHelper.getString('user_id');
      
      print('🔍 Checking storage for user data:');
      print('  user_id from storage: "$_userId"');
      
      // Debug: print semua keys di storage
      final allKeys = StorageHelper.getKeys();
      print('  All storage keys (${allKeys.length}): $allKeys');
      
      for (var key in allKeys) {
        final value = StorageHelper.getString(key);
        print('    "$key": "$value"');
      }
      
      if (_userId != null && _userId!.isNotEmpty) {
        print('✅ User ID found: $_userId, loading pets...');
        
        // ✅ GUNAKAN METHOD YANG BENAR
        final pets = await _petService.getPetsByUserId(_userId!);
        
        print('📊 Pets loaded: ${pets.length}');
        for (var pet in pets) {
          print('   - ${pet.name} (${pet.id})');
        }
        
        if (mounted) {
          setState(() {
            _petsFuture = Future.value(pets); // ✅ Set future dengan data
            _isLoading = false;
          });
        }
        
      } else {
        print('❌ No user_id found! Cannot load pets.');
        
        if (mounted) {
          setState(() {
            _petsFuture = Future.value([]);
            _isLoading = false;
          });
        }
        
        // Tampilkan error
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi login tidak valid. Silakan login ulang.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
      }
      
    } catch (e) {
      print('❌ Error loading pets: $e');
      
      if (mounted) {
        setState(() {
          _petsFuture = Future.error(e); // ✅ Set error
          _isLoading = false;
        });
      }
    }
  }

  // Refresh data setelah kembali dari halaman lain
  void _refreshPets() {
    print('🔄 Manual refresh triggered');
    _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 Widget rebuild, isLoading: $_isLoading');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Hewan Peliharaan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMedium,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => context.go('/notification'),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.orangeMedium,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.redVibrant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBody() {
    // Loading state saat pertama kali
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.orangeMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data hewan...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    // Jika _petsFuture masih null (seharusnya tidak terjadi)
    if (_petsFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(
              'Data belum dimuat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshPets,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return FutureBuilder<List<PetModel>>(
      future: _petsFuture,
      builder: (context, snapshot) {
        print('📊 FutureBuilder snapshot state: ${snapshot.connectionState}');
        print('📊 FutureBuilder has data: ${snapshot.hasData}');
        print('📊 FutureBuilder has error: ${snapshot.hasError}');
        
        // Loading state di FutureBuilder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.orangeMedium,
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          print('❌ FutureBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Periksa koneksi internet Anda',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshPets,
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

        // Data loaded
        final pets = snapshot.data ?? [];
        print('🎯 Pets list length: ${pets.length}');
        
        // Debug: Print semua pets
        for (var i = 0; i < pets.length; i++) {
          print('   [$i] ${pets[i].name} - ${pets[i].type} - ${pets[i].id}');
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan statistik
              _buildStatsHeader(pets),
              const SizedBox(height: 24),

              // Header list hewan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Hewan (${pets.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await context.push('/add-pet');
                      if (result == true) {
                        _refreshPets();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeRedGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.redVibrant.withOpacity(0.3),
                            blurRadius: 8,
                            // offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 20, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List hewan
              Expanded(
                child: pets.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadPets();
                          return;
                        },
                        color: AppColors.orangeMedium,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: pets.length,
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            print('📱 Building card for: ${pet.name}');
                            return _buildPetCard(context, pet, index);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
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
        currentIndex: 1,
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
              child: const Icon(Icons.calendar_today,
                  size: 24, color: Colors.white),
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
        context.go('/bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  Widget _buildStatsHeader(List<PetModel> pets) {
    int safeCount = pets
        .where((pet) => pet.is_safe == 'true' || pet.is_safe == true.toString())
        .length;
    int warningCount = pets
        .where((pet) => pet.is_safe != 'true' && pet.is_safe != true.toString())
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // GRADIASI ORANGE-MERAH YANG CERAH DARI PALET
        gradient:
            AppColors.homePrimaryGradient, // Atau AppColors.orangeRedGradient
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.redVibrant.withOpacity(0.3), // Shadow merah
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Hewan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                value: pets.length.toString(),
                label: 'Total Hewan',
                icon: Icons.pets,
                color: Colors.white,
              ),
              _buildStatItem(
                value: safeCount.toString(),
                label: 'Aman',
                icon: Icons.check_circle,
                color: Colors.white, // Tetap putih agar kontras
              ),
              _buildStatItem(
                value: warningCount.toString(),
                label: 'Perhatian',
                icon: Icons.warning,
                color: Colors.white, // Tetap putih agar kontras
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color ?? Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet, int index) {
    final bool isSafe = pet.is_safe == 'true' || pet.is_safe == true.toString();

    return Container(
        key: ValueKey(pet.id), // ✅ Key unik untuk setiap pet
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
          onTap: () async {
            final result = await context.push(
              '/pet-detail/${pet.id}',
              extra: pet,
            );
            if (result == true) {
              _refreshPets();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Foto hewan dengan badge
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: pet.photo != null && pet.photo!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(pet.photo!),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {},
                              )
                            : null,
                      ),
                      child: pet.photo == null || pet.photo!.isEmpty
                          ? Icon(Icons.pets, size: 40, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSafe ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isSafe ? '✓' : '!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Info hewan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pet.type == 'Kucing'
                                  ? Colors.blue[50]
                                  : Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pet.type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pet.type == 'Kucing'
                                    ? Colors.blue[700]
                                    : Colors.amber[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.breed ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.cake,
                            text: '${pet.age ?? '-'} tahun',
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.monitor_weight,
                            text: '${pet.weight ?? '-'} kg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.last_grooming != null
                            ? 'Terakhir grooming: ${pet.last_grooming}'
                            : 'Belum pernah grooming',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tombol aksi
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) => _handleMenuAction(context, value, pet),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'book',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18),
                          SizedBox(width: 8),
                          Text('Booking'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Hewan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan hewan peliharaan Anda untuk memulai booking grooming dan perawatan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push('/add-pet');
              if (result == true) {
                _refreshPets();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Hewan Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value, PetModel pet) {
    switch (value) {
      case 'edit':
        context
            .push(
          '/edit-pet/${pet.id}',
          extra: pet,
        )
            .then((result) {
          if (result == true) {
            _refreshPets();
          }
        });
        break;
      case 'book':
        context.go('/booking?petId=${pet.id}');
        break;
      case 'delete':
        _showDeleteDialog(context, pet);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan?'),
        content: Text('Apakah Anda yakin ingin menghapus ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await _petService.deletePet(pet.id);

                // Dismiss loading
                if (context.mounted) Navigator.pop(context);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // Refresh list
                _refreshPets();
              } catch (e) {
                // Dismiss loading
                if (context.mounted) Navigator.pop(context);

                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus ${pet.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
