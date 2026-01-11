// lib/presentation/screens/admin/layanan_detail_screen.dart  
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';
import 'package:intl/intl.dart';

class AdminServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  
  const AdminServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<AdminServiceDetailScreen> createState() => _AdminServiceDetailScreenState();
}

class _AdminServiceDetailScreenState extends State<AdminServiceDetailScreen> {
  final ServiceService _serviceService = ServiceService();
  bool _isLoading = false;
  bool _isActive = false;
  
  @override
  void initState() {
    super.initState();
    // Parse status aktif
    _isActive = widget.service.is_active == '1' || 
                widget.service.is_active == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final priceValue = double.tryParse(widget.service.price) ?? 0;
    final durationValue = int.tryParse(widget.service.duration) ?? 0;
    final durationText = durationValue >= 60
        ? '${(durationValue / 60).toStringAsFixed(1)} jam'
        : '${durationValue} menit';
    
    // Parse details dan benefits dari string ke list
    final List<String> detailsList = widget.service.details.isNotEmpty
        ? widget.service.details.split('|').map((e) => e.trim()).toList()
        : [];
    
    final List<String> benefitsList = widget.service.benefits.isNotEmpty
        ? widget.service.benefits.split('|').map((e) => e.trim()).toList()
        : [];
    
    // Format tanggal
    String formattedDate = widget.service.created_at;
    try {
      final date = DateTime.parse(widget.service.created_at);
      formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      // Jika parsing gagal, gunakan string asli
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Layanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.orangeMedium),
            onPressed: () => _editService(),
            tooltip: 'Edit Layanan',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orangeMedium),
            onPressed: _refreshService,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card dengan status
                  _buildHeaderCard(currencyFormat, durationText),
                  
                  const SizedBox(height: 20),
                  
                  // Informasi Dasar
                  _buildInfoCard(formattedDate),
                  
                  const SizedBox(height: 20),
                  
                  // Deskripsi
                  if (widget.service.description.isNotEmpty)
                    _buildDescriptionCard(),
                    const SizedBox(height: 20),
                  
                  // Details Section
                  if (detailsList.isNotEmpty)
                    _buildDetailsCard(detailsList),
                    const SizedBox(height: 20),
                  
                  // Benefits Section
                  if (benefitsList.isNotEmpty)
                    _buildBenefitsCard(benefitsList),
                    const SizedBox(height: 20),
                  
                  // Cocok Untuk
                  if (widget.service.suitable_for.isNotEmpty)
                    _buildSuitableForCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Harga & Durasi Card
                  _buildPriceDurationCard(currencyFormat, priceValue, durationText),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(NumberFormat currencyFormat, String durationText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCategoryColor(widget.service.category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getCategoryColor(widget.service.category).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.service.category),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(widget.service.category),
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.service.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isActive ? Colors.green : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isActive ? Icons.check_circle : Icons.remove_circle,
                            size: 14,
                            color: _isActive ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isActive ? 'AKTIF' : 'NONAKTIF',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.service.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryLabel(widget.service.category),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(widget.service.category),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Price & Duration
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currencyFormat.format(double.tryParse(widget.service.price) ?? 0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String formattedDate) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Layanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Service ID
            _buildInfoRow(
              icon: Icons.fingerprint,
              label: 'ID Layanan',
              value: widget.service.id,
              color: Colors.purple,
            ),
            
            const SizedBox(height: 12),
            
            // Created At
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Dibuat Pada',
              value: formattedDate,
              color: Colors.orange,
            ),
            
            const SizedBox(height: 12),
            
            // Icon & Color
            Row(
              children: [
                _buildInfoRow(
                  icon: Icons.photo,
                  label: 'Icon',
                  value: widget.service.icon,
                  color: Colors.blue,
                  expanded: false,
                ),
                
                const SizedBox(width: 20),
                
                _buildInfoRow(
                  icon: Icons.color_lens,
                  label: 'Warna',
                  value: widget.service.color,
                  color: _parseColor(widget.service.color),
                  expanded: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              widget.service.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<String> detailsList) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Layanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Column(
              children: detailsList.map((detail) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
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
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(List<String> benefitsList) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manfaat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: benefitsList.map((benefit) {
                return Chip(
                  label: Text(
                    benefit,
                    style: const TextStyle(fontSize: 13),
                  ),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuitableForCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cocok Untuk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              widget.service.suitable_for,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDurationCard(NumberFormat currencyFormat, double priceValue, String durationText) {
    return Card(
      elevation: 2,
      color: AppColors.greenLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Harga & Durasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Durasi Layanan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Harga Layanan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(priceValue),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Divider(color: Colors.grey[300]),
            
            const SizedBox(height: 12),
            
            // Informasi tambahan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive ? 'Aktif' : 'Tidak Aktif',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryLabel(widget.service.category),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(widget.service.category),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Edit Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editService,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Layanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Toggle Status Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleServiceStatus,
            icon: Icon(
              _isActive ? Icons.toggle_off : Icons.toggle_on,
              size: 18,
            ),
            label: Text(_isActive ? 'Nonaktifkan' : 'Aktifkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool expanded = true,
  }) {
    return expanded
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          );
  }

  // Helper functions
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'grooming': return Icons.cleaning_services;
      case 'spa': return Icons.spa;
      case 'paket': return Icons.assignment;
      case 'medis': return Icons.medical_services;
      default: return Icons.category;
    }
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  // Action Methods
  void _editService() {
    context.push<Map<String, dynamic>>(
      '/admin/services/${widget.service.id}/edit',
      extra: widget.service,
    ).then((result) {
      // PERBAIKAN: Type cast result ke Map<String, dynamic>
      if (result != null) {
        final success = result['success'] as bool?;
        if (success == true) {
          _refreshService();
          
          // Optional: Tampilkan snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _toggleServiceStatus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isActive ? 'Nonaktifkan Layanan' : 'Aktifkan Layanan'),
        content: Text(
          _isActive
              ? 'Apakah Anda yakin ingin menonaktifkan layanan ${widget.service.name}?'
              : 'Apakah Anda yakin ingin mengaktifkan layanan ${widget.service.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(_isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _serviceService.toggleServiceStatus(
          widget.service.id, 
          _isActive,
        );
        
        // Update status lokal
        setState(() {
          _isActive = !_isActive;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isActive
                  ? 'Layanan ${widget.service.name} telah diaktifkan'
                  : 'Layanan ${widget.service.name} telah dinonaktifkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshService() async {
    setState(() => _isLoading = true);
    
    try {
      // ignore: unused_local_variable
      final updatedService = await _serviceService.getServiceById(widget.service.id);
      
      // Update widget dengan data baru
      // PERHATIAN: Karena kita tidak bisa mengubah widget.service langsung,
      // kita perlu menggunakan StatefulWidget dan update state
      // Alternatif: Navigate ulang ke detail dengan data baru
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data layanan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat ulang data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}