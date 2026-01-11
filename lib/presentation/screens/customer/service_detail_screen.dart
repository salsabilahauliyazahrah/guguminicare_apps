import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isMethod; // true untuk metode, false untuk layanan

  const ServiceDetailScreen({
    super.key,
    required this.service,
    this.isMethod = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          service['name'],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan icon dan harga
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Deskripsi
            _buildSection(
              title: 'Deskripsi',
              content: service['description'],
            ),
            
            // Detail layanan/metode
            _buildSection(
              title: isMethod ? 'Proses Layanan' : 'Apa yang termasuk?',
              content: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (service['details'] as List<String>)
                    .map((detail) => _buildDetailItem(detail))
                    .toList(),
              ),
            ),
            
            // Untuk layanan: Manfaat
            if (!isMethod && service['benefits'] != null)
              _buildSection(
                title: 'Manfaat',
                content: null,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (service['benefits'] as List<String>)
                      .map((benefit) => _buildBenefitChip(benefit))
                      .toList(),
                ),
              ),
            
            // Informasi tambahan berdasarkan jenis
            _buildAdditionalInfo(),
            
            // Harga dan durasi
            _buildPriceDuration(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(service['color'] ?? 0xFFFFA726).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(service['color'] ?? 0xFFFFA726).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(service['color'] ?? 0xFFFFA726),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service['icon'],
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isMethod)
                  Text(
                    '${service['duration']} • Rp ${_formatPrice(service['price'])}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                if (isMethod && service['fee'] > 0)
                  Text(
                    'Biaya tambahan: Rp ${_formatPrice(service['fee'])}',
                    style: TextStyle(
                      fontSize: 16,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String benefit) {
    return Chip(
      label: Text(
        benefit,
        style: const TextStyle(fontSize: 13),
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildAdditionalInfo() {
    if (isMethod) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Informasi Tambahan',
            content: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Waktu Estimasi', service['estimatedTime']),
                _buildInfoRow('Ketersediaan', service['availability']),
                if (service['additionalInfo'] != null)
                  _buildInfoRow('Catatan', service['additionalInfo']),
              ],
            ),
          ),
        ],
      );
    } else {
      return _buildSection(
        title: 'Cocok untuk',
        content: service['suitableFor'],
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDuration() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Durasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                service['duration'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Harga',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Rp ${_formatPrice(service['price'] ?? service['fee'])}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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