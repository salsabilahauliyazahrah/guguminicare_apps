// lib/presentation/screens/admin/services/admin_services_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:intl/intl.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  
  String _selectedCategory = 'semua';
  bool _showInactive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    
    try {
      final services = await _serviceService.getAllServices();
      
      // Debug: print semua service
      print('📊 Loaded ${services.length} services:');
      
      // Hapus duplikat berdasarkan ID
      final uniqueServices = <ServiceModel>[];
      final seenIds = <String>{};
      
      for (var service in services) {
        if (!seenIds.contains(service.id) && service.id.isNotEmpty) {
          seenIds.add(service.id);
          uniqueServices.add(service);
        }
      }
      
      print('🔄 After removing duplicates: ${uniqueServices.length} services');
      
      setState(() {
        _services = uniqueServices;
        _isLoading = false;
      });
      
      // PERBAIKAN: Show loading success message
      if (uniqueServices.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${uniqueServices.length} layanan berhasil dimuat'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error loading services: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Get filtered services
  List<ServiceModel> get _filteredServices {
    return _services.where((service) {
      // Filter berdasarkan kategori
      final categoryMatch = _selectedCategory == 'semua' || 
                           service.category == _selectedCategory;
      
      // Filter berdasarkan status aktif/tidak aktif
      final isActiveBool = service.is_active == '1' || service.is_active == 'true';

      // Filter berdasarkan status aktif/tidak aktif
      final statusMatch = _showInactive || isActiveBool;      
      
      // Filter berdasarkan search query
      final searchMatch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return categoryMatch && statusMatch && searchMatch;
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
          'Manajemen Layanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            color: AppColors.orangeMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewService(),
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                // Filter section
                _buildFilterSection(),
                
                // Services list
                Expanded(
                  child: _filteredServices.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadServices,
                          child: ListView.builder(
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _buildServiceCard(service);
                            },
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
          CircularProgressIndicator(color: AppColors.orangeMedium),
          const SizedBox(height: 16),
          const Text('Memuat data layanan...'),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final activeCount = _services.where((s) => 
        s.is_active == '1' || s.is_active == 'true').length;
    
    final inactiveCount = _services.where((s) => 
        s.is_active == '0' || s.is_active == 'false').length;


    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari layanan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          
          const SizedBox(height: 16),

          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildServiceStat(
                label: 'Total',
                value: '${_services.length}',
                icon: Icons.spa,
                color: Colors.blue,
              ),
              _buildServiceStat(
                label: 'Aktif',
                value: '$activeCount',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildServiceStat(
                label: 'Nonaktif',
                value: '$inactiveCount',
                icon: Icons.remove_circle,
                color: Colors.orange,
              ),
              _buildServiceStat(
                label: 'Kategori',
                value: '4',
                icon: Icons.category,
                color: Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('Semua', 'semua'),
              _buildCategoryChip('Grooming', 'grooming'),
              _buildCategoryChip('Spa', 'spa'),
              _buildCategoryChip('Paket', 'paket'),
              _buildCategoryChip('Medis', 'medis'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Toggle untuk show inactive
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Switch(
                  value: _showInactive,
                  onChanged: (value) => setState(() => _showInactive = value),
                  activeColor: AppColors.orangeMedium,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tampilkan layanan tidak aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Menampilkan $inactiveCount layanan tidak aktif',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    final count = _services.where((s) => 
        value == 'semua' ? true : s.category == value).length;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedCategory = value),
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.orangeMedium,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final priceValue = double.tryParse(service.price) ?? 0;
    final durationValue = int.tryParse(service.duration) ?? 0;
    final durationText = durationValue >= 60
        ? '${(durationValue / 60).toStringAsFixed(1)} jam'
        : '${durationValue} menit';
    final isActiveBool = service.is_active == '1' || service.is_active == 'true';
    
    return GestureDetector(
      onTap: () => _viewServiceDetails(service),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan GestureDetector untuk seluruh card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icon berdasarkan kategori
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(service.category).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getCategoryIcon(service.category),
                                  size: 18,
                                  color: _getCategoryColor(service.category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Kategori dan status dalam satu baris
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(service.category).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getCategoryLabel(service.category),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getCategoryColor(service.category),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActiveBool ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isActiveBool ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActiveBool ? Icons.check_circle : Icons.remove_circle,
                                      size: 10,
                                      color: isActiveBool ? Colors.green : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isActiveBool ? 'AKTIF' : 'NONAKTIF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isActiveBool ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                if (service.description.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Details dalam Grid untuk layout yang lebih baik
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8, // Adjust untuk proporsi yang lebih baik
                  children: [
                    // Price
                    _buildDetailItem(
                      icon: Icons.attach_money,
                      label: 'Harga',
                      value: currencyFormat.format(priceValue),
                      color: Colors.green,
                    ),
                    
                    // Duration
                    _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'Durasi',
                      value: durationText,
                      color: Colors.blue,
                    ),
                    
                    // Created Date
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: 'Dibuat',
                      value: _formatDate(service.created_at),
                      color: Colors.orange,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons dengan divider
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Detail button
                      OutlinedButton.icon(
                        onPressed: () => _viewServiceDetails(service),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Detail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      // Action buttons group
                      Row(
                        children: [
                          // Edit button
                          IconButton(
                            onPressed: () => _editService(service),
                            icon: const Icon(Icons.edit, size: 18),
                            color: Colors.blue,
                            tooltip: 'Edit',
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Toggle status button
                          Container(
                            decoration: BoxDecoration(
                              color: isActiveBool ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActiveBool ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _toggleServiceStatus(service),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActiveBool ? Icons.toggle_off : Icons.toggle_on,
                                        size: 16,
                                        color: isActiveBool ? Colors.orange : Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isActiveBool ? 'Nonaktifkan' : 'Aktifkan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isActiveBool ? Colors.orange : Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  // PERBAIKAN: Method untuk format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // PERBAIKAN: Helper untuk mendapatkan icon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'grooming':
        return Icons.cleaning_services;
      case 'spa':
        return Icons.spa;
      case 'paket':
        return Icons.assignment;
      case 'medis':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions untuk kategori
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'grooming': return 'Grooming';
      case 'spa': return 'Spa';
      case 'paket': return 'Paket';
      case 'medis': return 'Medis';
      default: return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'grooming': return Colors.blue;
      case 'spa': return Colors.purple;
      case 'paket': return Colors.amber;
      case 'medis': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _addNewService() {
    context.push('/admin/services/add');
  }

  void _editService(ServiceModel service) {
    // PERBAIKAN: Gunakan push dengan then untuk handle result
    context.push<Map<String, dynamic>>(
      '/admin/services/${service.id}/edit',
      extra: service,
    ).then((result) {
      // Ini akan dipanggil ketika kembali dari edit screen
      if (result != null && result['success'] == true) {
        print('🔄 Refresh data setelah edit...');
        _loadServices(); // Simple refresh
      }
    });
  }

  Future<void> _toggleServiceStatus(ServiceModel service) async {
    final isActiveBool = service.is_active == '1' || service.is_active == 'true';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActiveBool ? 'Nonaktifkan Layanan' : 'Aktifkan Layanan'),
        content: Text(
          isActiveBool
              ? 'Apakah Anda yakin ingin menonaktifkan layanan ${service.name}?'
              : 'Apakah Anda yakin ingin mengaktifkan layanan ${service.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActiveBool ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isActiveBool ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // PERBAIKAN: Buat service dengan status yang diubah
        final newStatus = !isActiveBool ? '1' : '0';
        final updatedService = service.copyWith(is_active: newStatus);
        
        // PERBAIKAN: Gunakan updateServiceFull
        await _serviceService.updateServiceFull(updatedService);
        await _loadServices(); // Reload data
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isActiveBool
                  ? 'Layanan ${service.name} telah dinonaktifkan'
                  : 'Layanan ${service.name} telah diaktifkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('💥 Error toggle: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _showInactive
                  ? 'Tidak ada layanan yang sesuai'
                  : 'Tidak ada layanan aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showInactive
                  ? 'Coba ubah filter pencarian atau kategori'
                  : 'Aktifkan "Tampilkan layanan tidak aktif" untuk melihat semua layanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStat({required String label, required String value, required IconData icon, required Color color}) {
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
            fontSize: 14,
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

  // Tambahkan method untuk view details
  void _viewServiceDetails(ServiceModel service) {
    print('👁️ Melihat detail layanan: ${service.name} (ID: ${service.id})');
    
    // Navigasi ke halaman detail
    context.push(
      '/admin/services/${service.id}',
      extra: service,
    );
  }
}