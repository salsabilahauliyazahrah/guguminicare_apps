// lib/presentation/screens/admin/pet_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class ManagePetsScreen extends StatefulWidget {
  final UserModel customer;
  
  const ManagePetsScreen({
    super.key,
    required this.customer,
  });

  @override
  State<ManagePetsScreen> createState() => _ManagePetsScreenState();
}

class _ManagePetsScreenState extends State<ManagePetsScreen> {
  final UserService _userService = UserService();
  late Future<List<PetModel>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    setState(() {
      _petsFuture = _userService.getPetsByUserId(widget.customer.id);
    });
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
          'Hewan Peliharaan - ${customer.name}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewPet(),
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Info Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.orangeMedium.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppColors.orangeMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customer.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<PetModel>>(
                  future: _petsFuture,
                  builder: (context, snapshot) {
                    final petCount = snapshot.hasData ? snapshot.data!.length : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orangeMedium.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$petCount Hewan',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.orangeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Pets List
          Expanded(
            child: FutureBuilder<List<PetModel>>(
              future: _petsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                
                final pets = snapshot.data ?? [];
                
                if (pets.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return _buildPetListItem(pet);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewPet(),
        backgroundColor: AppColors.orangeMedium,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada hewan peliharaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan hewan peliharaan pertama untuk pelanggan ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addNewPet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah Hewan Baru'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPetListItem(PetModel pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Pet Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getPetColor(pet.type).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getPetIcon(pet.type),
                          color: _getPetColor(pet.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Pet Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 18,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handlePetAction(value, pet),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Additional Info
            if (pet.age != null || pet.weight != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (pet.age != null)
                      _buildPetDetailItem(
                        label: 'Usia',
                        value: '${pet.age} tahun',
                        icon: Icons.cake,
                      ),
                    if (pet.weight != null)
                      _buildPetDetailItem(
                        label: 'Berat',
                        value: '${pet.weight} kg',
                        icon: Icons.scale,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPetDetailItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Helper Methods
  Color _getPetColor(String type) {
    switch (type.toLowerCase()) {
      case 'kucing': return Colors.orange;
      case 'anjing': return Colors.blue;
      case 'kelinci': return Colors.purple;
      case 'burung': return Colors.green;
      case 'hamster': return Colors.brown;
      default: return Colors.grey;
    }
  }
  
  IconData _getPetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kucing': return Icons.pets;
      case 'anjing': return Icons.psychology;
      case 'kelinci': return Icons.health_and_safety;
      case 'burung': return Icons.flight;
      case 'hamster': return Icons.mouse;
      default: return Icons.pets;
    }
  }
  
  void _handlePetAction(String action, PetModel pet) {
    switch (action) {
      case 'edit':
        _editPet(pet);
        break;
      case 'delete':
        _deletePet(pet);
        break;
    }
  }
  
  void _addNewPet() async {
    final newPet = await context.push<PetModel>(
      '/admin/customers/${widget.customer.id}/pets/add',
      extra: widget.customer,
    );
    
    if (newPet != null) {
      _loadPets();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hewan ${newPet.name} berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
      _loadPets();
    }
  }
  
  void _deletePet(PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus hewan ${pet.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.deletePet(pet.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadPets();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hewan ${pet.name} berhasil dihapus'),
                      backgroundColor: Colors.red,
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
