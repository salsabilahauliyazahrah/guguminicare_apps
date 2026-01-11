// lib/presentation/screens/services/driver_data_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/drivers_model.dart';

class DriverDataService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET ALL DRIVER DATA ============
  Future<List<DriverDataModel>> getAllDriverData() async {
    print('🚗 Mengambil data semua driver...');
    
    final url = '${_baseUrl}select_all/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'driver_data',
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
        
        print('📊 Jumlah driver ditemukan: ${rawData.length}');
        
        final List<DriverDataModel> drivers = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> driverMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final driver = DriverDataModel.fromJson(driverMap);
            drivers.add(driver);
            
            print('✅ Loaded: ${driver.name} - ${driver.completed} jobs');
          } catch (e) {
            print('⚠️ Error parsing driver: $e');
          }
        }
        
        // Urutkan berdasarkan completed jobs (terbanyak duluan)
        drivers.sort((a, b) => b.completedInt.compareTo(a.completedInt));
        
        return drivers;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil data driver: $e');
      throw Exception('Gagal mengambil data driver: $e');
    }
  }

  // ============ CREATE NEW DRIVER DATA ============
  Future<DriverDataModel> createDriverData(DriverDataModel driver) async {
    print('➕ Membuat data driver baru: ${driver.name}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'driver_data',
        'appid': _appId,
        'name': driver.name,
        'completed': driver.completed,
        'rating': driver.rating,
        'revenue': driver.revenue,
      };
      
      print('📋 Driver Data:');
      bodyData.forEach((key, value) {
        print('   $key: $value');
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
          
          print('✅ Driver data created with ID: $newId');
          return driver.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return driver;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating driver data: $e');
      rethrow;
    }
  }

  // ============ UPDATE DRIVER DATA ============
  Future<void> updateDriverData(DriverDataModel driver) async {
    print('✏️ Update data driver: ${driver.name}');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final Map<String, dynamic> updateData = {
        'name': driver.name,
        'completed': driver.completed,
        'rating': driver.rating,
        'revenue': driver.revenue,
      };
      
      final bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'driver_data',
        'appid': _appId,
        'id': driver.id,
        'update_field': 'data',
        'update_value': jsonEncode(updateData),
      };
      
      print('📤 Update Data: $updateData');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyData,
      );
      
      print('📡 Update Response: ${response.statusCode}');
      print('📦 Update Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is Map && responseData['status'] == '0') {
          throw Exception('API Update Error: ${responseData['message']}');
        }
        
        print('✅ Driver data updated successfully');
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating driver data: $e');
      rethrow;
    }
  }

  // ============ INCREMENT DRIVER COMPLETED JOBS ============
  Future<void> incrementDriverCompleted(String driverId) async {
    print('➕ Increment completed jobs for driver: $driverId');
    
    try {
      final driver = await getDriverById(driverId);
      final updatedDriver = driver.incrementCompleted();
      await updateDriverData(updatedDriver);
      print('✅ Driver completed jobs incremented');
    } catch (e) {
      print('💥 Error incrementing completed jobs: $e');
      rethrow;
    }
  }

  // ============ ADD DRIVER REVENUE ============
  Future<void> addDriverRevenue(String driverId, int amount) async {
    print('💰 Add revenue for driver: $driverId - Amount: $amount');
    
    try {
      final driver = await getDriverById(driverId);
      final updatedDriver = driver.addRevenue(amount);
      await updateDriverData(updatedDriver);
      print('✅ Driver revenue added');
    } catch (e) {
      print('💥 Error adding driver revenue: $e');
      rethrow;
    }
  }

  // ============ UPDATE DRIVER RATING ============
  Future<void> updateDriverRating(String driverId, String newRating) async {
    print('⭐ Update rating for driver: $driverId - Rating: $newRating');
    
    try {
      final driver = await getDriverById(driverId);
      final updatedDriver = driver.updateRating(newRating);
      await updateDriverData(updatedDriver);
      print('✅ Driver rating updated');
    } catch (e) {
      print('💥 Error updating driver rating: $e');
      rethrow;
    }
  }

  // ============ GET DRIVER BY ID ============
  Future<DriverDataModel> getDriverById(String driverId) async {
    print('🔎 Mengambil data driver by ID: $driverId');
    
    final url = '${_baseUrl}select_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'driver_data',
          'appid': _appId,
          'id': driverId,
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
        if (rawData.isNotEmpty) {
          final driverMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return DriverDataModel.fromJson(driverMap);
        }
      }
      
      throw Exception('Driver dengan ID $driverId tidak ditemukan');
    } catch (e) {
      print('💥 Error getting driver by ID: $e');
      throw Exception('Gagal mengambil data driver: $e');
    }
  }

  // ============ GET DRIVER STATISTICS ============
  Future<Map<String, dynamic>> getDriverStatistics() async {
    print('📊 Getting driver statistics...');
    
    try {
      final drivers = await getAllDriverData();
      
      if (drivers.isEmpty) {
        return {
          'total_drivers': 0,
          'total_completed': 0,
          'total_revenue': 0,
          'average_rating': 0.0,
          'top_driver': null,
          'has_data': false,
        };
      }
      
      final totalDrivers = drivers.length;
      final totalCompleted = drivers.fold(0, (sum, driver) => sum + driver.completedInt);
      final totalRevenue = drivers.fold(0, (sum, driver) => sum + driver.revenueInt);
      final averageRating = drivers.isEmpty 
          ? 0.0 
          : drivers.map((d) => d.ratingDouble).reduce((a, b) => a + b) / totalDrivers;
      
      // Find top performer
      final topDriver = drivers.isNotEmpty 
          ? drivers.reduce((a, b) => a.completedInt > b.completedInt ? a : b)
          : null;
      
      return {
        'total_drivers': totalDrivers,
        'total_completed': totalCompleted,
        'total_revenue': totalRevenue,
        'average_rating': double.parse(averageRating.toStringAsFixed(1)),
        'top_driver': topDriver?.name,
        'top_driver_completed': topDriver?.completedInt ?? 0,
        'top_driver_rating': topDriver?.ratingDouble ?? 0.0,
        'has_data': true,
      };
    } catch (e) {
      print('💥 Error getting driver statistics: $e');
      return {
        'total_drivers': 0,
        'total_completed': 0,
        'total_revenue': 0,
        'average_rating': 0.0,
        'top_driver': null,
        'top_driver_completed': 0,
        'top_driver_rating': 0.0,
        'has_data': false,
      };
    }
  }

  // ============ DELETE DRIVER DATA ============
  Future<void> deleteDriverData(String driverId) async {
    print('🗑️ Delete driver data: $driverId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'driver_data',
          'appid': _appId,
          'id': driverId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Driver data deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting driver data: $e');
      rethrow;
    }
  }
}