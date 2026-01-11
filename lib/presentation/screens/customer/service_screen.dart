import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

// Metode layanan tetap konstanta karena tidak disimpan di database
class ServiceMethodConstants {
  static const List<Map<String, dynamic>> serviceMethods = [
    {
      'id': 'salon',
      'name': 'Datang ke Salon',
      'description': 'Anda mengantar hewan peliharaan langsung ke salon kami',
      'icon': Icons.storefront,
      'color': 0xFF4CAF50,
    },
    {
      'id': 'pickup',
      'name': 'Antar Jemput',
      'description': 'Driver kami akan menjemput dan mengantar kembali hewan Anda',
      'icon': Icons.local_shipping,
      'color': 0xFF2196F3,
    },
    {
      'id': 'home',
      'name': 'Home Service',
      'description': 'Groomer kami datang ke rumah Anda',
      'icon': Icons.home,
      'color': 0xFFFF9800,
    },
  ];
}

class ServiceScreen extends ConsumerStatefulWidget {
  final String screenType; // 'layanan' atau 'metode'
  
  const ServiceScreen({super.key, required this.screenType});
  
  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  int? selectedIndex;
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ServiceService _serviceService = ServiceService();

  @override
  void initState() {
    super.initState();
    if (widget.screenType == 'layanan') {
      _loadServices();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _serviceService.getAllServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading services: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Convert ServiceModel to Map for UI compatibility  
  Map<String, dynamic> _serviceToMap(ServiceModel service) {
    // Parse color from hex string or use default
    int colorValue = 0xFFFFA726; // Default orange
    try {
      if (service.color.isNotEmpty) {
        colorValue = int.parse(service.color.replaceAll('#', '0xFF'));
      }
    } catch (e) {
      // Use default color
    }

    // Parse icon name to IconData
    IconData iconData = Icons.spa; // Default icon
    switch (service.icon.toLowerCase()) {
      case 'pets':
        iconData = Icons.pets;
        break;
      case 'content_cut':
        iconData = Icons.content_cut;
        break;
      case 'spa':
        iconData = Icons.spa;
        break;
      case 'shower':
        iconData = Icons.shower;
        break;
      case 'health_and_safety':
        iconData = Icons.health_and_safety;
        break;
      default:
        iconData = Icons.spa;
    }

    return {
      'id': service.id,
      'name': service.name,
      'description': service.description,
      'price': int.tryParse(service.price) ?? 0,
      'duration': service.duration,
      'category': service.category,
      'icon': iconData,
      'color': colorValue,
      'details': service.details,
      'benefits': service.benefits,
      'suitable_for': service.suitable_for,
    };
  }

  List<Map<String, dynamic>> get _servicesList => 
      _services.map((s) => _serviceToMap(s)).toList();
  
  @override
  Widget build(BuildContext context) {
    final isServiceScreen = widget.screenType == 'layanan';
    final dataList = isServiceScreen 
      ? _servicesList 
      : ServiceMethodConstants.serviceMethods;
    final title = isServiceScreen ? 'Pilihan Layanan' : 'Metode Layanan';
    final emptyMessage = isServiceScreen 
      ? 'Belum ada layanan yang tersedia' 
      : 'Belum ada metode layanan yang tersedia';
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && isServiceScreen
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('Memuat layanan...'),
              ],
            ),
          )
        : _errorMessage != null && isServiceScreen
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal Memuat Layanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadServices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : dataList.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: isServiceScreen ? _loadServices : () async {},
            color: AppColors.primary,
            child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index];
              final isSelected = selectedIndex == index;
              
              return _buildServiceItem(
                item: item,
                index: index,
                isSelected: isSelected,
                isServiceScreen: isServiceScreen,
              );
            },
          ),
          ),
    );
  }
  
  Widget _buildServiceItem({
    required Map<String, dynamic> item,
    required int index,
    required bool isSelected,
    required bool isServiceScreen,
  }) {
    final color = Color(item['color'] ?? 0xFFFFA726);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected 
          ? color.withOpacity(0.1) 
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? color 
            : AppColors.grey500,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            
            // Navigasi ke halaman detail
            final routePath = isServiceScreen
              ? '/profile/layanan/detail'  // Ganti ini
              : '/profile/metode-layanan/${item['id']}';
            
            context.push(routePath, extra: item);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon dengan warna yang sesuai
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'],
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      if (isServiceScreen)
                        Text(
                          'Rp ${_formatPrice(item['price'])} - ${item['duration']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      
                      if (!isServiceScreen)
                        Text(
                          item['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Checkmark jika dipilih
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}