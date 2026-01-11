import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class MetodeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> metode;
  
  const MetodeDetailScreen({
    super.key,
    required this.metode,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          metode['name'],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Deskripsi
            _buildSection(
              title: 'Deskripsi',
              content: metode['description'],
            ),
            
            // Detail proses
            _buildSection(
              title: 'Proses Layanan',
              content: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (metode['details'] as List<String>)
                    .map((detail) => _buildDetailItem(detail))
                    .toList(),
              ),
            ),
            
            // Informasi tambahan
            _buildAdditionalInfo(),
            
            // Biaya dan informasi
            _buildFeeInfo(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              metode['icon'],
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metode['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                if (metode['fee'] != null && metode['fee'] > 0)
                  Text(
                    'Biaya tambahan: Rp ${_formatPrice(metode['fee'])}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (metode['fee'] == 0 || metode['fee'] == null)
                  const Text(
                    'Tidak ada biaya tambahan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    String? content,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (content != null)
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        if (child != null) child,
      ],
    );
  }
  
  Widget _buildDetailItem(String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Informasi Tambahan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        
        if (metode['estimatedTime'] != null)
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Waktu Estimasi',
            value: metode['estimatedTime'],
          ),
        
        if (metode['availability'] != null)
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Ketersediaan',
            value: metode['availability'],
          ),
        
        if (metode['additionalInfo'] != null)
          _buildInfoRow(
            icon: Icons.info_outline,
            label: 'Catatan',
            value: metode['additionalInfo'],
          ),
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeeInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Biaya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          if (metode['fee'] != null && metode['fee'] > 0)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya metode layanan:',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(metode['fee'])}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '*Biaya ini akan ditambahkan ke total biaya layanan grooming',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          
          if (metode['fee'] == 0 || metode['fee'] == null)
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Tidak ada biaya tambahan untuk metode ini',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
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