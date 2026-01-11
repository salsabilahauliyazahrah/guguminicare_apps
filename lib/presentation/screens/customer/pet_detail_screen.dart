import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel petData;

  const PetDetailScreen({
    super.key,
    required this.petData,
  });

  // Helper untuk konversi is_safe ke bool
  bool get _isSafe =>
      petData.is_safe == 'true' || petData.is_safe == true.toString();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 44) / 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.black87),
                ),
                onPressed: _sharePetProfile,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.black87),
                ),
                onPressed: () => context.push(
                  '/edit-pet/${petData.id}',
                  extra: petData,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: petData.photo != null && petData.photo!.isNotEmpty
                  ? Image.network(
                      petData.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.pets,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Konten detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan nama dan status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petData.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            petData.breed ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isSafe ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isSafe
                                ? Colors.green[200]!
                                : Colors.orange[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSafe ? Icons.check_circle : Icons.warning,
                              size: 16,
                              color: _isSafe ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isSafe ? 'Aman' : 'Perhatian',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isSafe
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Jenis hewan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: petData.type == 'Kucing'
                          ? Colors.blue[50]
                          : Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      petData.type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: petData.type == 'Kucing'
                            ? Colors.blue[800]
                            : Colors.amber[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info dasar menggunakan Wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildInfoCard(
                          icon: Icons.cake,
                          title: 'Umur',
                          value: '${petData.age ?? '-'} tahun',
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildInfoCard(
                          icon: Icons.monitor_weight,
                          title: 'Berat',
                          value: '${petData.weight ?? '-'} kg',
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildInfoCard(
                          icon: Icons.calendar_today,
                          title: 'Terakhir Grooming',
                          value: petData.last_grooming ?? 'Belum pernah',
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildInfoCard(
                          icon: Icons.pets,
                          title: 'ID Hewan',
                          value: petData.id,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CATATAN MEDIS - PERBAIKAN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Medis untuk Grooming',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[100]!),
                        ),
                        child: Text(
                          _getMedicalNotesText(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[900],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  // Tombol aksi untuk grooming
                  // Tombol aksi untuk grooming - BAGIAN YANG DIPERBAIKI
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/booking-quick', extra: {
                            'petId': petData.id,
                            'petName': petData.name,
                            'petType': petData.type,
                            'petBreed': petData.breed ?? 'Mixed',
                            'isQuickBooking': true,
                          }),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Booking Grooming Cepat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[100]!),
                        ),
                        child: IconButton(
                          onPressed: () => _showDeleteDialog(context),
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          tooltip: 'Hapus hewan',
                        ),
                      ),
                    ],
                  ),

                  // Informasi tambahan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Tanggal Ditambahkan',
                          _formatDate(petData.created_at),
                        ),
                        _buildInfoRow(
                          'Terakhir Diupdate',
                          _formatDate(petData.created_at),
                        ),
                        _buildInfoRow(
                          'Status',
                          _isSafe ? 'Aktif' : 'Perlu Perhatian',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk format tanggal
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Method baru untuk mendapatkan text medical notes
  String _getMedicalNotesText() {
    // Karena PetModel tidak memiliki field medical_notes, tampilkan pesan default
    // atau bisa di-fetch terpisah dari PetMedicalNoteModel jika diperlukan
    return 'Tidak ada catatan medis';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final PetService petService = PetService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan?'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${petData.name} dari daftar hewan?'),
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
                await petService.deletePet(petData.id);

                // Dismiss loading
                if (context.mounted) Navigator.pop(context);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${petData.name} berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // Kembali ke halaman sebelumnya dengan result true untuk refresh
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                // Dismiss loading
                if (context.mounted) Navigator.pop(context);

                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus ${petData.name}'),
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

  void _sharePetProfile() {
    print('Share pet profile: ${petData.name}');
  }
}
