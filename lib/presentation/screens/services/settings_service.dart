// lib/presentation/screens/services/settings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/salon_setting_model.dart';

class SettingsService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET ALL SETTINGS ============
  Future<SalonSettingModel?> getSalonSettings() async {
    print('⚙️ Mengambil pengaturan salon');
    
    final url = '${_baseUrl}select_all/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'salon_setting',
          'appid': _appId,
        },
      );
      
      print('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        print('📊 Jumlah settings ditemukan: ${rawData.length}');
        
        if (rawData.isNotEmpty) {
          final Map<String, dynamic> settingMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return SalonSettingModel.fromJson(settingMap);
        }
        
        return null;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil settings: $e');
      throw Exception('Gagal mengambil data settings: $e');
    }
  }

  // ============ CREATE SETTINGS ============
  Future<SalonSettingModel> createSettings(SalonSettingModel setting) async {
    print('➕ Membuat settings baru');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final settingJson = setting.toJson();
      settingJson.remove('_id'); // Remove id for insert
      settingJson.remove('id');
      
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'salon_setting',
        'appid': _appId,
      };
      
      // Add all setting fields
      settingJson.forEach((key, value) {
        bodyData[key] = value?.toString() ?? '';
      });
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyData,
      );
      
      print('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is List && responseData.isNotEmpty) {
          final createdData = responseData[0];
          final newId = createdData['_id']?.toString() ?? '';
          
          print('✅ Settings created with ID: $newId');
          return setting.copyWith(id: newId);
        }
        
        return setting;
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating settings: $e');
      rethrow;
    }
  }

  // ============ UPDATE SETTINGS ============
  Future<void> updateSettings(String settingId, Map<String, dynamic> updateData) async {
    print('✏️ Mengupdate settings: $settingId');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'salon_setting',
          'appid': _appId,
          'id': settingId,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      print('📡 Update Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Settings updated successfully');
      } else {
        throw Exception('Update failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating settings: $e');
      rethrow;
    }
  }

  // ============ SAVE ALL SETTINGS ============
  Future<void> saveAllSettings(SalonSettingModel settings) async {
    print('💾 Menyimpan semua settings');
    
    try {
      if (settings.id.isEmpty) {
        // Create new settings
        await createSettings(settings);
      } else {
        // Update existing settings
        await updateSettings(settings.id, settings.toJson());
      }
      
      print('✅ Semua settings berhasil disimpan');
    } catch (e) {
      print('💥 Error menyimpan settings: $e');
      rethrow;
    }
  }

  // ============ GET DEFAULT SETTINGS ============
  SalonSettingModel getDefaultSettings() {
    return SalonSettingModel(
      id: '',
      salon_id: _appId,
      salon_name: 'Gugumini Care',
      salon_address: 'Jl. Pet Salon No. 123, Jakarta',
      salon_phone: '021-1234567',
      salon_email: 'info@gugumini.com',
      salon_website: 'www.gugumini.com',
      business_hours: jsonEncode({
        'senin': {'open': '08:00', 'close': '20:00', 'isOpen': true},
        'selasa': {'open': '08:00', 'close': '20:00', 'isOpen': true},
        'rabu': {'open': '08:00', 'close': '20:00', 'isOpen': true},
        'kamis': {'open': '08:00', 'close': '20:00', 'isOpen': true},
        'jumat': {'open': '08:00', 'close': '20:00', 'isOpen': true},
        'sabtu': {'open': '09:00', 'close': '18:00', 'isOpen': true},
        'minggu': {'open': '09:00', 'close': '17:00', 'isOpen': false},
      }),
      notifications_enabled: 'true',
      email_notifications: 'true',
      sms_notifications: 'false',
      auto_confirm_booking: 'false',
      require_deposit: 'false',
      deposit_percentage: '20.0',
      salon_service_enabled: 'true',
      home_service_enabled: 'true',
      pickup_service_enabled: 'true',
      pickup_service_fee: '25000',
      cod_enabled: 'true',
      bank_transfer_enabled: 'true',
      qris_enabled: 'true',
      ewallet_enabled: 'true',
      created_at: DateTime.now().toIso8601String(),
      updated_at: DateTime.now().toIso8601String(),
    );
  }
}
