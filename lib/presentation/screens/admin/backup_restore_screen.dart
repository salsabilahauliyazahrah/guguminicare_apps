// lib/presentation/screens/admin/settings/backup_restore_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  List<Map<String, dynamic>> _backups = [
    {
      'name': 'Backup_20231201',
      'date': '2023-12-01 14:30',
      'size': '15.2 MB',
      'type': 'Full Backup',
    },
    {
      'name': 'Backup_20231125',
      'date': '2023-11-25 10:15',
      'size': '14.8 MB',
      'type': 'Full Backup',
    },
    {
      'name': 'Backup_20231118',
      'date': '2023-11-18 09:45',
      'size': '14.5 MB',
      'type': 'Full Backup',
    },
  ];

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
          'Backup & Restore Data',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup options
            _buildBackupOptions(),
            
            const SizedBox(height: 24),
            
            // Restore section
            _buildRestoreSection(),
            
            const SizedBox(height: 24),
            
            // Backup list
            _buildBackupList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backup Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Buat salinan data untuk keamanan. Disarankan melakukan backup secara berkala.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Buat Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeMedium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scheduleBackup,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Jadwalkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restore Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih file backup untuk mengembalikan data.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectBackupFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pilih File Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importFromCloud,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Import Cloud'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Backup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_backups.isEmpty)
              const Center(
                child: Text('Belum ada backup tersedia'),
              )
            else
              Column(
                children: _backups.map((backup) {
                  return _buildBackupItem(backup);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(Map<String, dynamic> backup) {
    return ListTile(
      leading: const Icon(Icons.backup, color: Colors.green),
      title: Text(
        backup['name'],
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tanggal: ${backup['date']}'),
          Text('Ukuran: ${backup['size']} | Tipe: ${backup['type']}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () => _downloadBackup(backup),
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () => _deleteBackup(backup),
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Sedang membuat backup...'),
            const SizedBox(height: 8),
            Text(
              'Jangan tutup aplikasi selama proses ini.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _scheduleBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jadwalkan Backup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih frekuensi backup:'),
            SizedBox(height: 16),
            // Add schedule options
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jadwal backup berhasil diset'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _selectBackupFile() {
    // Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur pilih file backup'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _importFromCloud() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur import dari cloud'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadBackup(Map<String, dynamic> backup) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download backup ${backup['name']}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteBackup(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Backup'),
        content: Text('Apakah Anda yakin ingin menghapus backup "${backup['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _backups.remove(backup);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
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