// lib/presentation/screens/admin/settings/security_privacy_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _requirePasswordChange = true;
  int _passwordChangeDays = 90;
  bool _twoFactorAuth = false;
  bool _ipRestriction = false;
  bool _sessionTimeout = true;
  int _sessionTimeoutMinutes = 30;
  bool _privacyMasking = true;

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
          'Keamanan & Privasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSecuritySettings,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan Keamanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSecurityToggle(
                      label: 'Wajib Ganti Password Berkala',
                      value: _requirePasswordChange,
                      onChanged: (value) => setState(() => _requirePasswordChange = value),
                    ),
                    
                    if (_requirePasswordChange)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setiap $_passwordChangeDays hari',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Slider(
                              value: _passwordChangeDays.toDouble(),
                              min: 30,
                              max: 180,
                              divisions: 5,
                              onChanged: (value) => setState(() => _passwordChangeDays = value.toInt()),
                              activeColor: AppColors.orangeMedium,
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSecurityToggle(
                      label: 'Two-Factor Authentication',
                      value: _twoFactorAuth,
                      onChanged: (value) => setState(() => _twoFactorAuth = value),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSecurityToggle(
                      label: 'Restriksi IP Address',
                      value: _ipRestriction,
                      onChanged: (value) => setState(() => _ipRestriction = value),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSecurityToggle(
                      label: 'Session Timeout Otomatis',
                      value: _sessionTimeout,
                      onChanged: (value) => setState(() => _sessionTimeout = value),
                    ),
                    
                    if (_sessionTimeout)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_sessionTimeoutMinutes menit',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Slider(
                              value: _sessionTimeoutMinutes.toDouble(),
                              min: 5,
                              max: 120,
                              divisions: 23,
                              onChanged: (value) => setState(() => _sessionTimeoutMinutes = value.toInt()),
                              activeColor: AppColors.orangeMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan Privasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSecurityToggle(
                      label: 'Masking Data Pribadi',
                      value: _privacyMasking,
                      onChanged: (value) => setState(() => _privacyMasking = value),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Data yang dimasking:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    _buildPrivacyOption('Nomor Telepon', true),
                    _buildPrivacyOption('Alamat Email', true),
                    _buildPrivacyOption('Alamat Rumah', true),
                    _buildPrivacyOption('Nomor KTP', false),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Activity log
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log Aktivitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Catatan aktivitas login dan perubahan pengaturan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _viewActivityLog,
                      icon: const Icon(Icons.history),
                      label: const Text('Lihat Log Aktivitas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSecuritySettings,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengaturan Keamanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeMedium,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityToggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orangeMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) => _togglePrivacyOption(label, value),
            activeColor: AppColors.orangeMedium,
          ),
        ],
      ),
    );
  }

  void _saveSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan keamanan berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewActivityLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Aktivitas'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Activity log items
                _buildActivityItem('Login berhasil', '2023-12-01 14:30'),
                _buildActivityItem('Perubahan password', '2023-11-30 10:15'),
                _buildActivityItem('Backup data', '2023-11-28 09:45'),
                _buildActivityItem('Login gagal', '2023-11-25 16:20'),
                _buildActivityItem('Update pengaturan', '2023-11-20 11:30'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          OutlinedButton(
            onPressed: _exportActivityLog,
            child: const Text('Ekspor Log'),
          ),
        ],
      ),
    );
  }

    Widget _buildActivityItem(String activity, String timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            timestamp,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _exportActivityLog() {
    // Implementasi ekspor log ke file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log aktivitas berhasil diekspor'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // Method untuk mengelola pilihan privasi
  void _togglePrivacyOption(String label, bool value) {
    // Implementasi toggle untuk setiap opsi privasi
    // Anda bisa menggunakan Map atau List untuk menyimpan state masing-masing opsi
    setState(() {
      // Contoh implementasi dengan Map
      // _privacyOptions[label] = value;
    });
  }

  // Method untuk menyimpan pengaturan keamanan ke database
  // ignore: unused_element
  Future<void> _saveToDatabase() async {
    try {
      // Implementasi penyimpanan ke database
      // Contoh:
      // final securitySettings = SecuritySettings(
      //   requirePasswordChange: _requirePasswordChange,
      //   passwordChangeDays: _passwordChangeDays,
      //   twoFactorAuth: _twoFactorAuth,
      //   ipRestriction: _ipRestriction,
      //   sessionTimeout: _sessionTimeout,
      //   sessionTimeoutMinutes: _sessionTimeoutMinutes,
      //   privacyMasking: _privacyMasking,
      // );
      // await DatabaseService().saveSecuritySettings(securitySettings);
      
      await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Validasi input
  // ignore: unused_element
  bool _validateSettings() {
    if (_requirePasswordChange && _passwordChangeDays < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah hari ganti password harus lebih dari 0'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_sessionTimeout && _sessionTimeoutMinutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu timeout sesi harus lebih dari 0 menit'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  // Method untuk memuat pengaturan dari database
  Future<void> _loadSecuritySettings() async {
    try {
      // Implementasi loading dari database
      // Contoh:
      // final settings = await DatabaseService().getSecuritySettings();
      // setState(() {
      //   _requirePasswordChange = settings.requirePasswordChange;
      //   _passwordChangeDays = settings.passwordChangeDays;
      //   _twoFactorAuth = settings.twoFactorAuth;
      //   _ipRestriction = settings.ipRestriction;
      //   _sessionTimeout = settings.sessionTimeout;
      //   _sessionTimeoutMinutes = settings.sessionTimeoutMinutes;
      //   _privacyMasking = settings.privacyMasking;
      // });
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Method untuk mereset pengaturan ke default
  // ignore: unused_element
  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text('Apakah Anda yakin ingin mengembalikan pengaturan keamanan ke default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _requirePasswordChange = true;
                _passwordChangeDays = 90;
                _twoFactorAuth = false;
                _ipRestriction = false;
                _sessionTimeout = true;
                _sessionTimeoutMinutes = 30;
                _privacyMasking = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan keamanan telah direset ke default'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  // Penutupan class _SecurityPrivacyScreenState
}