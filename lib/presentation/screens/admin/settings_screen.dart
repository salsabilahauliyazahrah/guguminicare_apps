// lib/presentation/screens/admin/settings/admin_settings_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/salon_setting_model.dart';
import 'package:tugas_akhir/presentation/screens/services/settings_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Service
  final SettingsService _settingsService = SettingsService();
  
  // State
  bool _isLoading = true;
  // ignore: unused_field
  bool _isSaving = false;
  String? _errorMessage;
  SalonSettingModel? _currentSettings;
  
  // Salon settings
  String _salonName = 'Gugumini Care';
  String _salonAddress = 'Jl. Pet Salon No. 123, Jakarta';
  String _salonPhone = '021-1234567';
  String _salonEmail = 'info@gugumini.com';
  String _salonWebsite = 'www.gugumini.com';
  
  // Business hours
  Map<String, Map<String, dynamic>> _businessHours = {
    'senin': {'open': '08:00', 'close': '20:00', 'isOpen': true},
    'selasa': {'open': '08:00', 'close': '20:00', 'isOpen': true},
    'rabu': {'open': '08:00', 'close': '20:00', 'isOpen': true},
    'kamis': {'open': '08:00', 'close': '20:00', 'isOpen': true},
    'jumat': {'open': '08:00', 'close': '20:00', 'isOpen': true},
    'sabtu': {'open': '09:00', 'close': '18:00', 'isOpen': true},
    'minggu': {'open': '09:00', 'close': '17:00', 'isOpen': false},
  };
  
  // System settings
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _autoConfirmBookings = false;
  bool _requireDeposit = false;
  double _depositPercentage = 20.0;
  
  // Payment settings
  bool _codEnabled = true;
  bool _bankTransferEnabled = true;
  bool _qrisEnabled = true;
  bool _ewalletEnabled = true;
  
  // Service methods
  bool _salonServiceEnabled = true;
  bool _homeServiceEnabled = true;
  bool _pickupServiceEnabled = true;
  double _pickupServiceFee = 25000.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final settings = await _settingsService.getSalonSettings();
      
      if (settings != null) {
        _currentSettings = settings;
        _applySettingsToUI(settings);
      } else {
        // Use default settings
        _currentSettings = _settingsService.getDefaultSettings();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat pengaturan: $e';
      });
    }
  }
  
  void _applySettingsToUI(SalonSettingModel settings) {
    _salonName = settings.salon_name;
    _salonAddress = settings.salon_address;
    _salonPhone = settings.salon_phone;
    _salonEmail = settings.salon_email;
    _salonWebsite = settings.salon_website;
    
    // Parse business hours
    final hoursMap = settings.businessHoursMap;
    if (hoursMap != null) {
      _businessHours = {};
      hoursMap.forEach((day, hours) {
        if (hours is Map) {
          _businessHours[day] = {
            'open': hours['open']?.toString() ?? '08:00',
            'close': hours['close']?.toString() ?? '20:00',
            'isOpen': hours['isOpen'] == true || hours['isOpen'] == 'true',
          };
        }
      });
    }
    
    _notificationsEnabled = settings.isNotificationsEnabled;
    _emailNotifications = settings.isEmailNotifications;
    _smsNotifications = settings.isSmsNotifications;
    _autoConfirmBookings = settings.isAutoConfirmBooking;
    _requireDeposit = settings.isRequireDeposit;
    _depositPercentage = settings.depositPercentageDouble;
    
    _salonServiceEnabled = settings.salon_service_enabled == 'true' || settings.salon_service_enabled == '1';
    _homeServiceEnabled = settings.home_service_enabled == 'true' || settings.home_service_enabled == '1';
    _pickupServiceEnabled = settings.pickup_service_enabled == 'true' || settings.pickup_service_enabled == '1';
    _pickupServiceFee = settings.pickupServiceFeeDouble;
    
    _codEnabled = settings.cod_enabled == 'true' || settings.cod_enabled == '1';
    _bankTransferEnabled = settings.bank_transfer_enabled == 'true' || settings.bank_transfer_enabled == '1';
    _qrisEnabled = settings.qris_enabled == 'true' || settings.qris_enabled == '1';
    _ewalletEnabled = settings.ewallet_enabled == 'true' || settings.ewallet_enabled == '1';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSettings,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(), // Kembali ke halaman sebelumnya
        ),        
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salon information section
            _buildSection(
              title: 'Informasi Salon',
              icon: Icons.store,
              children: [
                _buildTextFieldSetting(
                  label: 'Nama Salon',
                  value: _salonName,
                  onChanged: (value) => _salonName = value,
                ),
                _buildTextFieldSetting(
                  label: 'Alamat',
                  value: _salonAddress,
                  onChanged: (value) => _salonAddress = value,
                  maxLines: 2,
                ),
                _buildTextFieldSetting(
                  label: 'Telepon',
                  value: _salonPhone,
                  onChanged: (value) => _salonPhone = value,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextFieldSetting(
                  label: 'Email',
                  value: _salonEmail,
                  onChanged: (value) => _salonEmail = value,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextFieldSetting(
                  label: 'Website',
                  value: _salonWebsite,
                  onChanged: (value) => _salonWebsite = value,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Business hours section
            _buildSection(
              title: 'Jam Operasional',
              icon: Icons.access_time,
              children: [
                ..._businessHours.entries.map((entry) {
                  final day = entry.key;
                  final hours = entry.value;
                  return _buildBusinessHourSetting(
                    day: _capitalizeFirst(day),
                    openTime: hours['open']!,
                    closeTime: hours['close']!,
                    isOpen: hours['isOpen']!,
                    onToggle: (value) => setState(() {
                      _businessHours[day]!['isOpen'] = value;
                    }),
                    onTimeChanged: (open, close) => setState(() {
                      _businessHours[day]!['open'] = open;
                      _businessHours[day]!['close'] = close;
                    }),
                  );
                }).toList(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Service methods section
            _buildSection(
              title: 'Metode Layanan',
              icon: Icons.delivery_dining,
              children: [
                _buildToggleSetting(
                  label: 'Layanan di Salon',
                  value: _salonServiceEnabled,
                  onChanged: (value) => setState(() => _salonServiceEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'Home Service',
                  value: _homeServiceEnabled,
                  onChanged: (value) => setState(() => _homeServiceEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'Antar Jemput',
                  value: _pickupServiceEnabled,
                  onChanged: (value) => setState(() => _pickupServiceEnabled = value),
                ),
                if (_pickupServiceEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 8),
                    child: _buildSliderSetting(
                      label: 'Biaya Antar Jemput',
                      value: _pickupServiceFee,
                      min: 0,
                      max: 100000,
                      divisions: 20,
                      unit: 'Rp',
                      onChanged: (value) => setState(() => _pickupServiceFee = value),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment settings section
            _buildSection(
              title: 'Pengaturan Pembayaran',
              icon: Icons.payment,
              children: [
                _buildToggleSetting(
                  label: 'Cash on Delivery (COD)',
                  value: _codEnabled,
                  onChanged: (value) => setState(() => _codEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'Transfer Bank',
                  value: _bankTransferEnabled,
                  onChanged: (value) => setState(() => _bankTransferEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'QRIS',
                  value: _qrisEnabled,
                  onChanged: (value) => setState(() => _qrisEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'E-Wallet',
                  value: _ewalletEnabled,
                  onChanged: (value) => setState(() => _ewalletEnabled = value),
                ),
                _buildToggleSetting(
                  label: 'Wajib Deposit',
                  value: _requireDeposit,
                  onChanged: (value) => setState(() => _requireDeposit = value),
                ),
                if (_requireDeposit)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 8),
                    child: _buildSliderSetting(
                      label: 'Persentase Deposit',
                      value: _depositPercentage,
                      min: 10,
                      max: 50,
                      divisions: 8,
                      unit: '%',
                      onChanged: (value) => setState(() => _depositPercentage = value),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification settings section
            _buildSection(
              title: 'Pengaturan Notifikasi',
              icon: Icons.notifications,
              children: [
                _buildToggleSetting(
                  label: 'Aktifkan Notifikasi',
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                if (_notificationsEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: _buildToggleSetting(
                      label: 'Notifikasi Email',
                      value: _emailNotifications,
                      onChanged: (value) => setState(() => _emailNotifications = value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: _buildToggleSetting(
                      label: 'Notifikasi SMS',
                      value: _smsNotifications,
                      onChanged: (value) => setState(() => _smsNotifications = value),
                    ),
                  ),
                ],
                _buildToggleSetting(
                  label: 'Konfirmasi Booking Otomatis',
                  value: _autoConfirmBookings,
                  onChanged: (value) => setState(() => _autoConfirmBookings = value),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // System settings section
            _buildSection(
              title: 'Pengaturan Sistem',
              icon: Icons.settings,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Kelola Admin'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin/settings/admins'),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Template Nota/Struk'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin/settings/receipts'),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup & Restore Data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin/settings/backup'),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Keamanan & Privasi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/admin/settings/security'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Danger zone section
            _buildDangerZone(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengaturan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeMedium,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.orangeMedium),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSetting({
    required String label,
    required String value,
    required void Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
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

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              '$value$unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.orangeMedium,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: AppColors.orangeMedium,
          inactiveColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildBusinessHourSetting({
    required String day,
    required String openTime,
    required String closeTime,
    required bool isOpen,
    required void Function(bool) onToggle,
    required void Function(String, String) onTimeChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: onToggle,
                activeColor: AppColors.orangeMedium,
              ),
            ],
          ),
          
          if (isOpen)
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Buka',
                    time: openTime,
                    onTimeSelected: (time) => onTimeChanged(time, closeTime),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('sampai'),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Tutup',
                    time: closeTime,
                    onTimeSelected: (time) => onTimeChanged(openTime, time),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required void Function(String) onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () => _showTimePicker(label, time, onTimeSelected),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Zona Berbahaya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Tindakan ini tidak dapat dibatalkan. Hanya lakukan jika Anda yakin.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCache,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Bersihkan Cache'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetSettings,
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Reset Pengaturan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(String label, String currentTime, Function(String) onTimeSelected) {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((selectedTime) {
      if (selectedTime != null) {
        final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        onTimeSelected(formattedTime);
      }
    });
  }

  void _saveSettings() async {
    // Build settings model from current UI values
    final settingsToSave = SalonSettingModel(
      id: _currentSettings?.id ?? '',
      salon_id: _currentSettings?.salon_id ?? '',
      salon_name: _salonName,
      salon_address: _salonAddress,
      salon_phone: _salonPhone,
      salon_email: _salonEmail,
      salon_website: _salonWebsite,
      business_hours: jsonEncode(_businessHours),
      notifications_enabled: _notificationsEnabled.toString(),
      email_notifications: _emailNotifications.toString(),
      sms_notifications: _smsNotifications.toString(),
      auto_confirm_booking: _autoConfirmBookings.toString(),
      require_deposit: _requireDeposit.toString(),
      deposit_percentage: _depositPercentage.toString(),
      salon_service_enabled: _salonServiceEnabled.toString(),
      home_service_enabled: _homeServiceEnabled.toString(),
      pickup_service_enabled: _pickupServiceEnabled.toString(),
      pickup_service_fee: _pickupServiceFee.toString(),
      cod_enabled: _codEnabled.toString(),
      bank_transfer_enabled: _bankTransferEnabled.toString(),
      qris_enabled: _qrisEnabled.toString(),
      ewallet_enabled: _ewalletEnabled.toString(),
      created_at: _currentSettings?.created_at ?? DateTime.now().toIso8601String(),
      updated_at: DateTime.now().toIso8601String(),
    );
    
    setState(() => _isSaving = true);
    
    try {
      await _settingsService.saveAllSettings(settingsToSave);
      _currentSettings = settingsToSave;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengaturan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bersihkan Cache'),
        content: const Text('Apakah Anda yakin ingin membersihkan cache? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache berhasil dibersihkan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text('Apakah Anda yakin ingin mengembalikan pengaturan ke default? Semua perubahan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset settings to default using service
              final defaultSettings = _settingsService.getDefaultSettings();
              _applySettingsToUI(defaultSettings);
              _currentSettings = defaultSettings;
              
              setState(() {});
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan telah direset ke default'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}