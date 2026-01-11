// lib/presentation/screens/admin/customers/admin_customers_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _customersFuture;
  String _searchQuery = '';
  String _filterStatus = 'semua';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCustomers();
  }

  void _loadCustomers() {
    setState(() {
      _customersFuture = _userService.getUsersByRole('customer');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _filterCustomers(List<UserModel> customers) async {
    return customers.where((customer) {
      // Filter berdasarkan status
      final isActive = customer.role == 'customer' && 
                      customer.id.isNotEmpty; // Anda bisa tambahkan field is_active di UserModel jika perlu
      
      final statusMatch = _filterStatus == 'semua' ||
          (_filterStatus == 'aktif' && isActive) ||
          (_filterStatus == 'tidak-aktif' && !isActive);
      
      // Filter berdasarkan search query
      final searchMatch = _searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phone.contains(_searchQuery);
      
      return statusMatch && searchMatch;
    }).toList();
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
          'Pelanggan & Hewan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),
          
          // Customers list
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }
                
                return FutureBuilder<List<UserModel>>(
                  future: _filterCustomers(snapshot.data!),
                  builder: (context, filteredSnapshot) {
                    if (!filteredSnapshot.hasData || filteredSnapshot.data!.isEmpty) {
                      return _buildEmptySearchState();
                    }
                    
                    final filteredCustomers = filteredSnapshot.data!;
                    return ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getCustomerWithPets(customer),
                          builder: (context, customerSnapshot) {
                            if (customerSnapshot.connectionState == ConnectionState.waiting) {
                              return _buildCustomerCardLoading(customer);
                            }
                            
                            if (customerSnapshot.hasData) {
                              return _buildCustomerCard(customerSnapshot.data!);
                            }
                            
                            return _buildCustomerCard({
                              'user': customer,
                              'pets': [],
                              'total_bookings': 0,
                              'total_spent': 0,
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return FutureBuilder<List<UserModel>>(
      future: _customersFuture,
      builder: (context, snapshot) {
        final customers = snapshot.data ?? [];
        final activeCustomers = customers.where((c) => c.role == 'customer').length;
        final totalPets = 0; // Anda bisa hitung dari database
        
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCustomerStat(
                    label: 'Total',
                    value: '${customers.length}',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _buildCustomerStat(
                    label: 'Aktif',
                    value: '$activeCustomers',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildCustomerStat(
                    label: 'Hewan',
                    value: '$totalPets',
                    icon: Icons.pets,
                    color: Colors.amber,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Search and filter
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pelanggan, email, telepon...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _searchQuery = value);
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Status filter
              Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _filterStatus == 'semua',
                    onSelected: (selected) => setState(() => _filterStatus = 'semua'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Aktif'),
                    selected: _filterStatus == 'aktif',
                    onSelected: (selected) => setState(() => _filterStatus = 'aktif'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Tidak Aktif'),
                    selected: _filterStatus == 'tidak-aktif',
                    onSelected: (selected) => setState(() => _filterStatus = 'tidak-aktif'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getCustomerWithPets(UserModel customer) async {
    try {
      // Fetch pets for this customer
      final pets = await _userService.getPetsByUserId(customer.id);
      
      // Fetch booking statistics (implement this in your service)
      final totalBookings = 0; // await _bookingService.getTotalBookings(customer.id);
      final totalSpent = 0; // await _bookingService.getTotalSpent(customer.id);
      
      return {
        'user': customer,
        'pets': pets,
        'total_bookings': totalBookings,
        'total_spent': totalSpent,
        'is_active': customer.role == 'customer',
        'join_date': customer.createdAtOrNull ?? DateTime.now(),
      };
    } catch (e) {
      return {
        'user': customer,
        'pets': [],
        'total_bookings': 0,
        'total_spent': 0,
        'is_active': customer.role == 'customer',
        'join_date': customer.createdAtOrNull ?? DateTime.now(),
      };
    }
  }

  Widget _buildCustomerCard(Map<String, dynamic> customerData) {
    final customer = customerData['user'] as UserModel;
    final pets = customerData['pets'] as List<PetModel>;
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final joinDate = customer.createdAtOrNull ?? DateTime.now();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewCustomerDetail(customer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.role == 'customer' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      customer.role == 'customer' ? 'AKTIF' : 'TIDAK AKTIF',
                      style: TextStyle(
                        fontSize: 12,
                        color: customer.role == 'customer' ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Contact info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Bergabung: ${dateFormat.format(joinDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildCompactStatItem(
                      label: 'Booking',
                      value: '${customerData['total_bookings']}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildCompactStatItem(
                      label: 'Pengeluaran',
                      value: currencyFormat.format(customerData['total_spent']),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildCompactStatItem(
                      label: 'Hewan',
                      value: pets.length.toString(),
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Pets list
              Text(
                'Hewan Peliharaan:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: pets.map<Widget>((pet) {
                  return Chip(
                    label: Text('${pet.name} (${pet.type})'),
                    avatar: Icon(
                      pet.type == 'Kucing' ? Icons.pets : Icons.psychology,
                      size: 16,
                    ),
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _viewCustomerDetail(customer),
                    child: const Text('Lihat Detail'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _viewCustomerPets(customer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kelola Hewan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCardLoading(UserModel customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 20,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 16,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 30,
                  color: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 150,
              height: 16,
              color: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.orangeMedium),
          const SizedBox(height: 16),
          const Text('Memuat data pelanggan...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
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
              Icons.people_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pelanggan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pelanggan yang mendaftar akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada hasil ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coba gunakan kata kunci pencarian lain',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Pencarian'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStat({required String label, required String value, required IconData icon, required Color color}) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatItem({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _viewCustomerDetail(UserModel customer) {
    context.push('/admin/customers/${customer.id}', extra: customer);
  }

  void _viewCustomerPets(UserModel customer) {
    context.push('/admin/customers/${customer.id}/pets', extra: customer);
  }
}