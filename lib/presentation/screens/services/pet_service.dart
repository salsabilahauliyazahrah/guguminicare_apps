// lib/data/services/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/pet_medical_note_model.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class PetService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ CREATE PET - TAMBAH KE DATABASE ============
  Future<PetModel> createPet(PetModel pet) async {
    print('🐕 Membuat pet baru: ${pet.name}');
    
    // ============ VALIDASI USER ID ============
    String finalUserId = pet.user_id;
    
    if (finalUserId.isEmpty) {
      print('⚠️ Pet user_id is empty, checking storage...');
      
      final storedUserId = StorageHelper.getString('user_id');
      
      if (storedUserId == null || storedUserId.isEmpty) {
        print('❌ CRITICAL: No user_id found in storage!');
        throw Exception('User tidak ditemukan. Silakan login ulang.');
      }
      
      finalUserId = storedUserId;
      print('✅ Using user_id from storage: $finalUserId');
    }
    
    // Pastikan pet punya user_id yang valid
    final petWithUserId = pet.copyWith(user_id: finalUserId);
    
    print('🔍 Pet data before sending:');
    print('  name: ${petWithUserId.name}');
    print('  type: ${petWithUserId.type}');
    print('  user_id: ${petWithUserId.user_id}');
    print('  age: ${petWithUserId.age}');
    print('  weight: ${petWithUserId.weight}');
    print('  is_safe: ${petWithUserId.is_safe}');
    
    // ============ PERBAIKAN URL ============
    // Coba URL yang berbeda untuk 247GO
    final url = '${_baseUrl}insert/';
    
    // ============ PERBAIKAN BODY DATA ============
    // API 247GO biasanya butuh parameter tertentu di root
    final Map<String, String> bodyData = {
      'token': _token,
      'project': _project,
      'collection': 'pet',
      'appid': _appId,
      'user_id': petWithUserId.user_id,
      'name': petWithUserId.name,
      'type': petWithUserId.type,
    };
    
    // Tambahkan field opsional hanya jika ada nilai
    if (petWithUserId.breed != null && petWithUserId.breed!.isNotEmpty) {
      bodyData['breed'] = petWithUserId.breed!;
    }
    
    if (petWithUserId.age != null && petWithUserId.age!.isNotEmpty) {
      bodyData['age'] = petWithUserId.age!;
    }
    
    if (petWithUserId.weight != null && petWithUserId.weight!.isNotEmpty) {
      bodyData['weight'] = petWithUserId.weight!;
    }
    
    if (petWithUserId.photo != null && petWithUserId.photo!.isNotEmpty) {
      bodyData['photo'] = petWithUserId.photo!;
    }
    
    // Handle is_safe dengan benar
    String isSafeValue = 'true'; // default
    if (petWithUserId.is_safe != null) {
      String rawValue = petWithUserId.is_safe!;
      // Clean value
      if (rawValue.toLowerCase() == 'true' || rawValue == '1') {
        isSafeValue = 'true';
      } else if (rawValue.toLowerCase() == 'false' || rawValue == '0') {
        isSafeValue = 'false';
      }
    }
    bodyData['is_safe'] = isSafeValue;
    
    // Tambahkan created_at jika diperlukan
    bodyData['created_at'] = petWithUserId.created_at;
    
    // Debug: print semua data
    print('🔗 URL: $url');
    print('📦 Body data to send:');
    bodyData.forEach((key, value) {
      print('   $key: "$value"');
    });
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyData,
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Cek format response 247GO
        if (responseData is Map) {
          if (responseData['status'] == '1' || responseData['status'] == 1) {
            print('✅ Pet berhasil dibuat');
            
            // Dapatkan ID jika ada
            if (responseData.containsKey('inserted_id')) {
              final newId = responseData['inserted_id'].toString();
              print('🎯 New pet ID: $newId');
              return petWithUserId.copyWith(id: newId);
            } else if (responseData.containsKey('id')) {
              final newId = responseData['id'].toString();
              print('🎯 New pet ID: $newId');
              return petWithUserId.copyWith(id: newId);
            }
            
            return petWithUserId;
          } else {
            // Status 0 = gagal
            final errorMsg = responseData['message'] ?? 'Unknown error';
            print('❌ API Error: $errorMsg');
            throw Exception('Gagal membuat pet: $errorMsg');
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          // Format lain: array dengan data
          print('✅ Pet berhasil dibuat (array format)');
          if (responseData[0] is Map && responseData[0].containsKey('_id')) {
            final newId = responseData[0]['_id'].toString();
            return petWithUserId.copyWith(id: newId);
          }
          return petWithUserId;
        } else {
          print('❌ Unexpected response format');
          throw Exception('Format response tidak dikenali');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error creating pet: $e');
      print('Stack trace: ${e.toString()}');
      throw Exception('Gagal membuat hewan: $e');
    }
  }

  // ============ UPDATE PET - UPDATE KE DATABASE ============
  Future<PetModel> updatePet(PetModel pet) async {
    print('✏️ Update pet: ${pet.name} (${pet.id})');
    
    final url = '${_baseUrl}update_id/token/$_token/project/$_project/collection/pet/appid/$_appId/id/${pet.id}';
    
    // ✅ BUAT MAP DENGAN SEMUA VALUE STRING
    final Map<String, dynamic> petData = {
      'id': pet.id,
      'user_id': pet.user_id,
      'name': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'age': pet.age, // ✅ Langsung pakai String
      'weight': pet.weight, // ✅ Langsung pakai String
      'photo': pet.photo,
      'is_safe': pet.is_safe, // ✅ Langsung pakai String, TANPA .toString()
      'last_grooming': pet.last_grooming,
      'created_at': pet.created_at,
    };
    
    print('🔗 URL: $url');
    print('📦 Data untuk update: $petData');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'update_field': 'data',
          'update_value': jsonEncode(petData),
        },
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Pet berhasil di-update');
        return pet;
      } else {
        throw Exception('Gagal update pet: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error updating pet: $e');
      throw Exception('Gagal mengupdate hewan: $e');
    }
  }

  // ============ DELETE PET - HAPUS DARI DATABASE ============
  Future<void> deletePet(String petId) async {
    print('🗑️ Delete pet: $petId');
    
    final url = '${_baseUrl}remove_id/token/$_token/project/$_project/collection/pet/appid/$_appId/id/$petId';
    
    print('🔗 URL: $url');
    
    try {
      final response = await http.delete(Uri.parse(url));

      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Pet berhasil dihapus');
      } else {
        throw Exception('Gagal menghapus pet: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error deleting pet: $e');
      throw Exception('Gagal menghapus hewan: $e');
    }
  }

  // ============ GET ALL PETS (ADMIN) ============
  Future<List<PetModel>> getAllPets() async {
    print('🐕 Mengambil semua pets...');
    
    final url = '${_baseUrl}select/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'pet',
          'appid': _appId,
        },
      );
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        print('📊 Jumlah semua pets: ${rawData.length}');
        
        final List<PetModel> pets = [];
        
        for (var item in rawData) {
          try {
            final petMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final pet = PetModel.fromJson(petMap);
            pets.add(pet);
          } catch (e) {
            print('⚠️ Error parsing pet: $e');
          }
        }
        
        return pets;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil semua pets: $e');
      throw Exception('Gagal mengambil data hewan: $e');
    }
  }

  // ============ GET PETS BY USER ID - AMBIL DARI DATABASE ============
  Future<List<PetModel>> getPetsByUserId(String userId) async {
    print('🔍 Mengambil pets untuk user: $userId');
    
    final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/pet/appid/$_appId/where_field/user_id/where_value/$userId';
    
    print('🔗 URL: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      print('📡 Status: ${response.statusCode}');
      print('📦 Response: ${response.body.length > 200 ? "${response.body.substring(0, 200)}..." : response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        // Ekstrak data dari berbagai format API 247GO
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data')) {
            rawData = responseData['data'] is List ? responseData['data'] : [];
          } else if (responseData.containsKey('result')) {
            rawData = responseData['result'] is List ? responseData['result'] : [];
          } else if (responseData.containsKey('pets')) {
            rawData = responseData['pets'] is List ? responseData['pets'] : [];
          }
        }
        
        print('📊 Jumlah data mentah: ${rawData.length}');
        
        if (rawData.isEmpty) {
          print('ℹ️ Tidak ada pets untuk user: $userId');
          return [];
        }
        
        // Convert to PetModel
        final List<PetModel> pets = [];
        
        for (var item in rawData) {
          try {
            final petMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            print('📋 Raw pet data: ${petMap.keys}');
            
            final pet = PetModel.fromJson(petMap);
            pets.add(pet);
            
            print('✅ Pet loaded: ${pet.name} (${pet.type})');
          } catch (e) {
            print('⚠️ Error parsing pet: $e');
            print('⚠️ Raw item: $item');
          }
        }
        
        print('🎯 Total pets yang berhasil di-load: ${pets.length}');
        return pets;
        
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to get pets: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error mengambil pets: $e');
      throw Exception('Gagal mengambil data hewan: $e');
    }
  }

  // ============ GET PET BY ID - AMBIL DARI DATABASE ============
  Future<PetModel?> getPetById(String petId) async {
    print('🔎 Mengambil pet by ID: $petId');
    
    final url = '${_baseUrl}select_id/token/$_token/project/$_project/collection/pet/appid/$_appId/id/$petId';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        if (rawData.isNotEmpty) {
          final petMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          final pet = PetModel.fromJson(petMap);
          print('✅ Pet ditemukan: ${pet.name}');
          return pet;
        }
      }
      
      print('ℹ️ Pet dengan ID $petId tidak ditemukan');
      return null;
      
    } catch (e) {
      print('💥 Error getting pet by ID: $e');
      throw Exception('Gagal mengambil data hewan: $e');
    }
  }

  // ============ MEDICAL NOTES (OPSIONAL) ============
  Future<PetMedicalNoteModel?> getMedicalNoteByPetId(String petId) async {
    print('🏥 Mengambil medical note untuk pet: $petId');
    
    final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/pet_medical_notes/appid/$_appId/where_field/pet_id/where_value/$petId';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        if (rawData.isNotEmpty) {
          final noteMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return PetMedicalNoteModel.fromJson(noteMap);
        }
      }
      
      print('ℹ️ Tidak ada medical note untuk pet: $petId');
      return null;
      
    } catch (e) {
      print('💥 Error getting medical note: $e');
      return null;
    }
  }

  Future<void> saveMedicalNote(PetMedicalNoteModel note) async {
    print('💾 Menyimpan medical note untuk pet: ${note.petId}');
    
    final url = '${_baseUrl}insert/token/$_token/project/$_project/collection/pet_medical_notes/appid/$_appId';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: note.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ Medical note berhasil disimpan');
      } else {
        print('❌ Gagal menyimpan medical note: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error saving medical note: $e');
    }
  }

  // ============ TEST KONEKSI ============
  Future<bool> testConnection() async {
    print('🔌 Testing PetService connection...');
    
    try {
      final url = '${_baseUrl}select_all/token/$_token/project/$_project/collection/pet/appid/$_appId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        print('✅ PetService Connection: SUCCESS');
        return true;
      } else {
        print('❌ PetService Connection: FAILED (${response.statusCode})');
        return false;
      }
      
    } catch (e) {
      print('❌ PetService Connection: FAILED - $e');
      return false;
    }
  }
}