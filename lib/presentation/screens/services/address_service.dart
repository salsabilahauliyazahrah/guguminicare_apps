// lib/presentation/screens/services/address_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/address_model.dart';

class AddressService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET ADDRESSES BY USER ID ============
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    print('📍 Mengambil alamat untuk user: $userId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'address',
          'appid': _appId,
          'where_field': 'userid',
          'where_value': userId,
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
        
        print('📊 Jumlah alamat ditemukan: ${rawData.length}');
        
        final List<AddressModel> addresses = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> addressMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final address = AddressModel.fromJson(addressMap);
            addresses.add(address);
            
            print('✅ Loaded: ${address.jenis_alamat} - ${address.kota}');
          } catch (e) {
            print('⚠️ Error parsing address: $e');
          }
        }
        
        // Urutkan: alamat utama di depan
        addresses.sort((a, b) {
          if (a.isUtamaBool && !b.isUtamaBool) return -1;
          if (!a.isUtamaBool && b.isUtamaBool) return 1;
          return 0;
        });
        
        return addresses;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil alamat: $e');
      throw Exception('Gagal mengambil data alamat: $e');
    }
  }

  // ============ CREATE NEW ADDRESS ============
  Future<AddressModel> createAddress(AddressModel address) async {
    print('➕ Membuat alamat baru: ${address.jenis_alamat}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'address',
        'appid': _appId,
        'userid': address.userid,
        'jenis_alamat': address.jenis_alamat,
        'alamat_lengkap': address.alamat_lengkap,
        'kota': address.kota,
        'is_utama': address.is_utama,
        'catatan': address.catatan,
        'kode_pos': address.kode_pos,
        'created_at': address.created_at,
      };
      
      print('📋 Address Data:');
      bodyData.forEach((key, value) {
        print('   $key: ${value.isNotEmpty ? value : "(kosong)"}');
      });
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyData,
      );
      
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is List && responseData.isNotEmpty) {
          final createdData = responseData[0];
          final newId = createdData['_id']?.toString() ?? '';
          
          print('✅ Address created with ID: $newId');
          return address.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return address;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating address: $e');
      rethrow;
    }
  }

  // ============ UPDATE ADDRESS ============
  Future<AddressModel> updateAddress(AddressModel address) async {
    print('✏️ Update alamat: ${address.jenis_alamat} (${address.id})');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final updateData = {
        'jenis_alamat': address.jenis_alamat,
        'alamat_lengkap': address.alamat_lengkap,
        'kota': address.kota,
        'is_utama': address.is_utama,
        'catatan': address.catatan,
        'kode_pos': address.kode_pos,
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'address',
          'appid': _appId,
          'id': address.id,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      print('📡 Update Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Address updated successfully');
        return address;
      } else {
        throw Exception('Update failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating address: $e');
      rethrow;
    }
  }

  // ============ DELETE ADDRESS ============
  Future<void> deleteAddress(String addressId) async {
    print('🗑️ Delete alamat: $addressId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'address',
          'appid': _appId,
          'id': addressId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Address deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting address: $e');
      rethrow;
    }
  }

  // ============ SET AS PRIMARY ADDRESS ============
  Future<void> setAsPrimary(String addressId, String userId) async {
    print('⭐ Set alamat utama: $addressId');
    
    try {
      // 1. Get semua alamat user
      final addresses = await getAddressesByUserId(userId);
      
      // 2. Set semua alamat ke tidak utama
      for (var address in addresses) {
        if (address.isUtamaBool) {
          await updateAddress(address.setAsNotPrimary());
        }
      }
      
      // 3. Set alamat yang dipilih sebagai utama
      final selectedAddress = addresses.firstWhere((a) => a.id == addressId);
      await updateAddress(selectedAddress.setAsPrimary());
      
      print('✅ Primary address set successfully');
    } catch (e) {
      print('💥 Error setting primary address: $e');
      rethrow;
    }
  }

  // ============ GET PRIMARY ADDRESS ============
  Future<AddressModel?> getPrimaryAddress(String userId) async {
    try {
      final addresses = await getAddressesByUserId(userId);
      return addresses.firstWhere(
        (a) => a.isUtamaBool,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw Exception('No address found'),
      );
    } catch (e) {
      print('⚠️ No primary address found: $e');
      return null;
    }
  }
}
