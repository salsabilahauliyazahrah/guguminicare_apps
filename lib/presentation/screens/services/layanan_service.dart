// lib/presentation/screens/services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/restapi.dart';

class ServiceService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';
  
  // ============ GET ALL SERVICES ============
  Future<List<ServiceModel>> getAllServices() async {
    print('🔍 Mengambil semua layanan dari database...');
    
    final url = '${_baseUrl}select_all/token/$_token/project/$_project/collection/service/appid/$_appId';
    
    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        // Ekstrak data dari berbagai format API
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data')) {
            rawData = responseData['data'] is List ? responseData['data'] : [];
          } else if (responseData.containsKey('result')) {
            rawData = responseData['result'] is List ? responseData['result'] : [];
          } else if (responseData.containsKey('services')) {
            rawData = responseData['services'] is List ? responseData['services'] : [];
          }
        }
        
        print('📊 Jumlah layanan ditemukan: ${rawData.length}');
        
        // Convert ke ServiceModel
        final List<ServiceModel> services = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> serviceMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final service = ServiceModel.fromJson(serviceMap);
            services.add(service);
            
            print('✅ Loaded: ${service.name} (${service.category})');
          } catch (e) {
            print('⚠️ Error parsing service: $e');
          }
        }
        
        return services;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil layanan: $e');
      throw Exception('Gagal mengambil data layanan dari database: $e');
    }
  }
  
  // ============ CREATE NEW SERVICE ============
  Future<ServiceModel> createService(ServiceModel service) async {
    print('➕ Membuat layanan baru: ${service.name}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      // PERBAIKAN: Format tanggal tanpa milidetik untuk kompatibilitas
      final createdAt = service.created_at.contains('.') 
          ? service.created_at.split('.')[0]
          : service.created_at;
      
      // Bersihkan semua teks sebelum dikirim
      final name = service.name.replaceAll('\n', ' ').trim();
      final description = service.description.replaceAll('\n', ' ').trim();
      final details = service.details.replaceAll('\n', ' ').trim();
      final benefits = service.benefits.replaceAll('\n', ' ').trim();
      final suitableFor = service.suitable_for.replaceAll('\n', ' ').trim();
      
      // Persiapkan body sesuai format yang benar
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'service',
        'appid': _appId,
        'name': name,
        'description': description,
        'price': service.price,
        'duration': service.duration,
        'category': service.category,
        'icon': service.icon,
        'color': service.color,
        'details': details,
        'benefits': benefits,
        'suitable_for': suitableFor,
        'is_active': service.is_active,
        'created_at': createdAt, // PERBAIKAN: Gunakan variabel yang sudah didefinisikan
      };
      
      // Print data yang akan dikirim
      print('📋 Request Data:');
      bodyData.forEach((key, value) {
        print('   $key: ${value.length > 50 ? '${value.substring(0, 50)}...' : value}');
      });
      
      // Kirim request dengan format yang benar
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyData,
      );
      
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // PERBAIKAN: Cek jika response adalah List
        if (responseData is List && responseData.isNotEmpty) {
          print('✅ Layanan berhasil dibuat!');
          
          // Ambil ID dari item pertama
          final firstItem = responseData[0];
          if (firstItem is Map) {
            final String? newId = firstItem['_id']?.toString();
            if (newId != null && newId.isNotEmpty) {
              return service.copyWith(id: newId);
            }
          }
          return service;
        } 
        // Jika response adalah Map dengan status
        else if (responseData is Map) {
          final dynamic status = responseData['status'];
          if (status == 1 || status == '1' || responseData.containsKey('_id')) {
            print('✅ Layanan berhasil dibuat!');
            final String? newId = responseData['_id']?.toString();
            if (newId != null && newId.isNotEmpty) {
              return service.copyWith(id: newId);
            }
            return service;
          } else {
            final errorMsg = responseData['message'] ?? 'Unknown error';
            print('❌ API Error: $errorMsg');
            throw Exception('API Error: $errorMsg');
          }
        }
        else {
          throw Exception('Format response tidak dikenali');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error: $e');
      print('💥 Stack trace: ${e.toString()}');
      throw Exception('Gagal membuat layanan: $e');
    }
  }

  // PERBAIKAN: Method untuk create service menggunakan DataService
  Future<ServiceModel> createServiceUsingDataService(ServiceModel service) async {
    try {
      final dataService = DataService();
      
      // Format tanggal
      final createdAt = DateTime.now().toIso8601String().split('.')[0];
      
      // Bersihkan teks
      final cleanedName = service.name.replaceAll('\n', ' ').trim();
      final cleanedDesc = service.description.replaceAll('\n', ' ').trim();
      final cleanedDetails = service.details.replaceAll('\n', ' ').trim();
      final cleanedBenefits = service.benefits.replaceAll('\n', ' ').trim();
      final cleanedSuitableFor = service.suitable_for.replaceAll('\n', ' ').trim();
      
      // Panggil method insertService dari DataService
      final response = await dataService.insertService(
        _appId,
        cleanedName,
        cleanedDesc,
        service.price,
        service.duration,
        service.category,
        service.icon,
        service.color,
        cleanedDetails,
        cleanedBenefits,
        cleanedSuitableFor,
        service.is_active,
        createdAt,
      );
      
      print('📦 DataService Response: $response');
      
      // Parse response
      final responseData = json.decode(response);
      
      if (responseData is Map && responseData['status'] == '1') {
        final newId = responseData['_id']?.toString();
        if (newId != null) {
          return service.copyWith(id: newId);
        }
        return service;
      }
      
      throw Exception('Failed to create service');
      
    } catch (e) {
      throw Exception('Gagal membuat layanan: $e');
    }
  }
  
  // ============ UPDATE SERVICE (SINGLE FIELD) ============
  Future<void> updateService(ServiceModel service) async {
    print('✏️ Update layanan: ${service.name} (${service.id})');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      // Bersihkan semua teks
      final cleanedName = service.name.replaceAll('\n', ' ').trim();
      // ignore: unused_local_variable
      final cleanedDesc = service.description.replaceAll('\n', ' ').trim();
      // ignore: unused_local_variable
      final cleanedDetails = service.details.replaceAll('\n', ' ').trim();
      // ignore: unused_local_variable
      final cleanedBenefits = service.benefits.replaceAll('\n', ' ').trim();
      // ignore: unused_local_variable
      final cleanedSuitableFor = service.suitable_for.replaceAll('\n', ' ').trim();
      
      // PERBAIKAN: Format update sesuai API 247GO
      final bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'service',
        'appid': _appId,
        'id': service.id,
        // PERBAIKAN: Kirim field satu per satu
        'update_field': 'name',
        'update_value': cleanedName,
      };
      
      print('📤 Update Data:');
      print('   ID: ${service.id}');
      print('   Name: $cleanedName');
      
      // PERBAIKAN: Update satu field dulu sebagai tes
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyData,
      );
      
      print('📡 Update Response Status: ${response.statusCode}');
      print('📦 Update Response Body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      // PERBAIKAN: Handle berbagai format response
      if (response.statusCode == 200) {
        if (responseData is Map) {
          if (responseData['status'] == '0') {
            final errorMsg = responseData['message'] ?? 'Unknown error';
            throw Exception('API Update Error: $errorMsg');
          }
        } else if (responseData is List) {
          // Response sebagai List berarti sukses
          print('✅ Layanan berhasil diupdate');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error update: $e');
      throw Exception('Gagal mengupdate layanan: $e');
    }
  }
  
  // PERBAIKAN: Tambahkan method updateServiceFull untuk update semua field
  Future<void> updateServiceFull(ServiceModel service) async {
    print('✏️ Update layanan (full): ${service.name} (ID: ${service.id})');
    
    try {
      // Update field satu per satu dengan delay kecil
      await _updateField(service.id, 'name', service.name);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'description', service.description);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'price', service.price);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'duration', service.duration);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'category', service.category);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'icon', service.icon);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'color', service.color);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'details', service.details);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'benefits', service.benefits);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'suitable_for', service.suitable_for);
      await Future.delayed(const Duration(milliseconds: 100));
      await _updateField(service.id, 'is_active', service.is_active);
      
      print('✅ Semua field berhasil diupdate');
    } catch (e) {
      print('💥 Error updateServiceFull: $e');
      throw Exception('Gagal mengupdate layanan: $e');
    }
  }

  // Helper untuk update single field
  Future<void> _updateField(String id, String field, String value) async {
    final url = '${_baseUrl}update_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'service',
          'appid': _appId,
          'id': id,
          'update_field': field,
          'update_value': value,
        },
      );
      
      print('📡 Update $field Response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        final errorMsg = responseData is Map ? responseData['message'] : 'Unknown error';
        throw Exception('Gagal update field $field: $errorMsg');
      }
      
      print('✅ Field $field berhasil diupdate');
    } catch (e) {
      print('💥 Error update field $field: $e');
      throw Exception('Gagal update field $field: $e');
    }
  }

  // ============ GET SERVICE BY ID ============
  Future<ServiceModel> getServiceById(String serviceId) async {
    print('🔎 Mengambil layanan by ID: $serviceId');
    
    final url = '${_baseUrl}select_id/token/$_token/project/$_project/collection/service/appid/$_appId/id/$serviceId';
    
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
          final serviceMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return ServiceModel.fromJson(serviceMap);
        }
      }
      
      throw Exception('Layanan dengan ID $serviceId tidak ditemukan');
    } catch (e) {
      print('💥 Error get service by ID: $e');
      throw Exception('Gagal mengambil data layanan: $e');
    }
  }
  
  // ============ TOGGLE SERVICE STATUS ============
  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    print('🔄 Toggle status layanan $serviceId ke: ${!isActive}');
    
    try {
      final service = await getServiceById(serviceId);
      
      // PERBAIKAN: Gunakan updateServiceFull untuk toggle status
      final newStatus = !isActive ? '1' : '0';
      
      final updatedService = service.copyWith(
        is_active: newStatus,
      );
      
      // PERBAIKAN: Gunakan updateServiceFull, bukan updateService
      await updateServiceFull(updatedService);
      
      print('✅ Status layanan berhasil diubah menjadi: $newStatus');
    } catch (e) {
      print('💥 Error toggle status: $e');
      throw Exception('Gagal mengubah status layanan: $e');
    }
  }

  // Tambahkan method ini di ServiceService
  // ignore: unused_element
  void _printRequestDetails(String url, Map<String, String> body) {
    print('🌐 URL: $url');
    print('📦 Request Body:');
    body.forEach((key, value) {
      print('   $key: ${value.length > 50 ? '${value.substring(0, 50)}...' : value}');
    });
    
    // Print full JSON jika ada
    if (body.containsKey('insert_data')) {
      print('📋 Full JSON Data:');
      try {
        final jsonData = jsonDecode(body['insert_data']!);
        print(jsonData);
      } catch (e) {
        print('Cannot parse JSON: $e');
      }
    }
  }  

  // ============ DELETE SERVICE ============
  Future<void> deleteService(String serviceId) async {
    print('🗑️ Delete layanan: $serviceId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'service',
          'appid': _appId,
          'id': serviceId,
        },
      );
      
      print('📡 Delete Response Status: ${response.statusCode}');
      print('📦 Delete Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle response format
        if (responseData is Map && responseData['status'] == '0') {
          final errorMsg = responseData['message'] ?? 'Unknown error';
          throw Exception('API Delete Error: $errorMsg');
        }
        
        print('✅ Layanan berhasil dihapus');
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error delete layanan: $e');
      throw Exception('Gagal menghapus layanan: $e');
    }
  }

  // ============ SEARCH SERVICES ============
  Future<List<ServiceModel>> searchServices(String query) async {
    print('🔍 Mencari layanan: $query');
    
    try {
      final allServices = await getAllServices();
      
      return allServices.where((service) {
        return service.name.toLowerCase().contains(query.toLowerCase()) ||
               service.description.toLowerCase().contains(query.toLowerCase()) ||
               service.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('💥 Error search services: $e');
      throw Exception('Gagal mencari layanan: $e');
    }
  }
}