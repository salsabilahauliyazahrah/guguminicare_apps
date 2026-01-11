import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/dummy_layanan_salon.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class MetodeLayananScreen extends ConsumerStatefulWidget {
  const MetodeLayananScreen({super.key});
  
  @override
  ConsumerState<MetodeLayananScreen> createState() => _MetodeLayananScreenState();
}

class _MetodeLayananScreenState extends ConsumerState<MetodeLayananScreen> {
  int? selectedIndex;
  
  @override
  Widget build(BuildContext context) {
    final serviceMethods = ServiceConstants.serviceMethods;
    
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
        title: const Text(
          'Metode Layanan',
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
      body: serviceMethods.isEmpty
        ? const Center(
            child: Text(
              'Belum ada metode layanan yang tersedia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: serviceMethods.length,
            itemBuilder: (context, index) {
              final method = serviceMethods[index];
              final isSelected = selectedIndex == index;
              
              return _buildMethodCard(
                method: method,
                index: index,
                isSelected: isSelected,
              );
            },
          ),
    );
  }
  
  Widget _buildMethodCard({
    required Map<String, dynamic> method,
    required int index,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.primary.withOpacity(0.1) 
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? AppColors.primary 
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
            
            // Navigasi ke detail metode
            context.push('/profile/metode-layanan/detail', extra: method);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    method['icon'],
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Deskripsi singkat
                      if (method['description'] != null)
                        Text(
                          method['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Biaya tambahan jika ada
                      if (method['fee'] != null && method['fee'] > 0)
                        Text(
                          'Biaya tambahan: Rp ${_formatPrice(method['fee'])}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Panah atau checkmark
                Icon(
                  isSelected ? Icons.check_circle : Icons.chevron_right,
                  color: isSelected ? AppColors.primary : Colors.grey[500],
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