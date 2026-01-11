// lib/presentation/screens/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class UserService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET USERS BY ROLE - MURNI DARI DATABASE ============
  Future<List<UserModel>> getUsersByRole(String role) async {
    print('🔍 Mengambil users dengan role: $role');
    
    // 1. BUAT URL ENDPOINT SESUAI API 247GO
    final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/user/appid/$_appId/where_field/role/where_value/$role';
    
    print('🔗 API Endpoint: $url');
    
    try {
      // 2. LAKUKAN HTTP GET REQUEST
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          // Untuk menghindari CORS di web development
          'Origin': 'http://localhost:8080',
          'Access-Control-Request-Method': 'GET',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      );
      
      print('📡 Status Response: ${response.statusCode}');
      print('📦 Body Response: ${response.body}');
      
      // 3. VALIDASI RESPONSE
      if (response.statusCode != 200) {
        throw Exception('❌ API Error ${response.statusCode}: ${response.body}');
      }
      
      // 4. PARSE RESPONSE JSON
      final dynamic responseData = json.decode(response.body);
      
      // 5. EKSTRAK DATA DARI BERBAGAI FORMAT RESPONSE
      List<dynamic> rawData = [];
      
      if (responseData is List) {
        // Format 1: Langsung array
        rawData = responseData;
      } else if (responseData is Map) {
        // Format 2: { "data": [...] }
        if (responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        } else if (responseData.containsKey('result')) {
          // Format 3: { "result": [...] }
          rawData = responseData['result'] is List ? responseData['result'] : [];
        } else if (responseData.containsKey('users')) {
          // Format 4: { "users": [...] }
          rawData = responseData['users'] is List ? responseData['users'] : [];
        } else {
          // Coba ambil semua values yang mungkin array
          for (var value in responseData.values) {
            if (value is List) {
              rawData = value;
              break;
            }
          }
        }
      } else if (responseData is String) {
        // Format 5: String JSON
        try {
          final parsed = json.decode(responseData);
          rawData = parsed is List ? parsed : [];
        } catch (e) {
          print('⚠️ Error parsing string response: $e');
        }
      }
      
      // 6. VALIDASI DATA
      if (rawData.isEmpty) {
        print('ℹ️ Tidak ada data ditemukan untuk role: $role');
        return []; // Return array kosong, bukan error
      }
      
      print('✅ Ditemukan ${rawData.length} users dengan role: $role');
      
      // 7. KONVERSI KE UserModel
      final List<UserModel> users = [];
      
      for (var item in rawData) {
        try {
          final Map<String, dynamic> userMap = item is Map<String, dynamic> 
              ? item 
              : Map<String, dynamic>.from(item as Map);
          
          // Debug: print raw data
          print('📋 Raw user data: $userMap');
          
          final user = UserModel.fromJson(userMap);
          users.add(user);
          
          print('👤 Berhasil load: ${user.name} (${user.email})');
        } catch (e) {
          print('⚠️ Gagal parse user data: $e');
          print('⚠️ Raw item: $item');
        }
      }
      
      // 8. RETURN DATA ASLI DARI DATABASE
      print('🎯 Total users yang berhasil di-load: ${users.length}');
      return users;
      
    } catch (e) {
      // 9. ERROR HANDLING - THROW EXCEPTION (TANPA FALLBACK)
      print('💥 Error mengambil data dari database: $e');
      throw Exception('Gagal mengambil data pelanggan dari database: $e');
    }
  }

  // ============ GET ALL USERS - MURNI DARI DATABASE ============
  Future<List<UserModel>> getAllUsers() async {
    print('🔍 Mengambil semua users...');
    
    final url = '${_baseUrl}select/token/$_token/project/$_project/collection/user/appid/$_appId';
    
    print('🔗 API Endpoint: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      print('📡 Status Response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('❌ API Error ${response.statusCode}: ${response.body}');
      }
      
      final dynamic responseData = json.decode(response.body);
      
      List<dynamic> rawData = [];
      
      if (responseData is List) {
        rawData = responseData;
      } else if (responseData is Map) {
        if (responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        } else if (responseData.containsKey('result')) {
          rawData = responseData['result'] is List ? responseData['result'] : [];
        } else {
          for (var value in responseData.values) {
            if (value is List) {
              rawData = value;
              break;
            }
          }
        }
      }
      
      print('✅ Ditemukan ${rawData.length} users');
      
      final List<UserModel> users = [];
      
      for (var item in rawData) {
        try {
          final Map<String, dynamic> userMap = item is Map<String, dynamic> 
              ? item 
              : Map<String, dynamic>.from(item as Map);
          
          final user = UserModel.fromJson(userMap);
          users.add(user);
        } catch (e) {
          print('⚠️ Gagal parse user data: $e');
        }
      }
      
      print('🎯 Total users yang berhasil di-load: ${users.length}');
      return users;
      
    } catch (e) {
      print('💥 Error mengambil semua users dari database: $e');
      throw Exception('Gagal mengambil data users dari database: $e');
    }
  }

  // ============ GET PETS BY USER ID - MURNI DARI DATABASE ============
  Future<List<PetModel>> getPetsByUserId(String userId) async {
    print('🐕 Mengambil pets untuk user: $userId');
    
    final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/pet/appid/$_appId/where_field/user_id/where_value/$userId';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];
        
        // Ekstrak data dari berbagai format
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        }
        
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
            
            final pet = PetModel.fromJson(petMap);
            pets.add(pet);
          } catch (e) {
            print('⚠️ Error parsing pet: $e');
          }
        }
        
        print('✅ Ditemukan ${pets.length} pets untuk user: $userId');
        return pets;
        
      } else {
        throw Exception('API Error ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error mengambil pets: $e');
      throw Exception('Gagal mengambil data pets: $e');
    }
  }

  // ============ UPDATE USER - UPDATE KE DATABASE ============
  Future<UserModel> updateUser(UserModel user) async {
    print('✏️ Update user: ${user.name} (${user.id})');
    
    // Format URL yang benar untuk API 247GO update
    final url = '${_baseUrl}update_id/token/$_token/project/$_project/collection/user/appid/$_appId/id/${user.id}';
    
    print('🔗 Update URL: $url');
    
    try {
      // 247GO biasanya menggunakan POST untuk update
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'update_field': 'data',
          'update_value': jsonEncode(user.toJson()),
        },
      );

      print('📡 Update Response Status: ${response.statusCode}');
      print('📦 Update Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ User berhasil di-update: $responseData');
        return user;
      } else {
        print('❌ Update failed: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal update user: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error updating user: $e');
      throw Exception('Gagal mengupdate user: $e');
    }
  }

  // ============ DELETE PET - HAPUS DARI DATABASE ============
  Future<void> deletePet(String petId) async {
    print('🗑️ Delete pet: $petId');
    
    final url = '${_baseUrl}remove_id/token/$_token/project/$_project/collection/pet/appid/$_appId/id/$petId';
    
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('✅ Pet berhasil dihapus');
      } else {
        throw Exception('Failed to delete pet: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error deleting pet: $e');
      throw Exception('Gagal menghapus pet: $e');
    }
  }

  // ============ GET USER BY ID - AMBIL DARI DATABASE ============
  Future<UserModel> getUserById(String userId) async {
    print('🔎 Mengambil user by ID: $userId');
    
    final url = '${_baseUrl}select_id/token/$_token/project/$_project/collection/user/appid/$_appId/id/$userId';
    
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
          final userMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          final user = UserModel.fromJson(userMap);
          print('✅ User ditemukan: ${user.name}');
          return user;
        }
      }
      
      throw Exception('User dengan ID $userId tidak ditemukan');
      
    } catch (e) {
      print('💥 Error getting user by ID: $e');
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // ============ SEARCH USERS - CARI DI DATABASE ============
  Future<List<UserModel>> searchUsers(String query) async {
    print('🔎 Search users: $query');
    
    final url = '${_baseUrl}select_where_like/token/$_token/project/$_project/collection/user/appid/$_appId/wlike_field/name/wlike_value/$query';
    
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
        
        final List<UserModel> users = [];
        
        for (var item in rawData) {
          try {
            final userMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            users.add(UserModel.fromJson(userMap));
          } catch (e) {
            print('⚠️ Error parsing user in search: $e');
          }
        }
        
        print('✅ Ditemukan ${users.length} users untuk query: $query');
        return users;
      }
      
      throw Exception('Search failed: ${response.statusCode}');
      
    } catch (e) {
      print('💥 Error searching users: $e');
      throw Exception('Gagal mencari users: $e');
    }
  }

  // ============ TEST KONEKSI API ============
  Future<bool> testConnection() async {
    print('🔌 Testing API connection...');
    
    try {
      // Test endpoint yang sederhana
      final url = '${_baseUrl}select_all/token/$_token/project/$_project/collection/user/appid/$_appId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        print('✅ API Connection: SUCCESS');
        return true;
      } else {
        print('❌ API Connection: FAILED (${response.statusCode})');
        return false;
      }
      
    } catch (e) {
      print('❌ API Connection: FAILED - $e');
      return false;
    }
  }

  // ============ GET USER BOOKINGS ============
  Future<List<BookingModel>> getUserBookings(String userId) async {
    print('📅 Mengambil bookings untuk user: $userId');
    
    final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/bookings/appid/$_appId/where_field/user_id/where_value/$userId';
    
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
          } else if (responseData.containsKey('bookings')) {
            rawData = responseData['bookings'] is List ? responseData['bookings'] : [];
          }
        }
        
        print('📊 Jumlah data mentah: ${rawData.length}');
        
        if (rawData.isEmpty) {
          print('ℹ️ Tidak ada bookings untuk user: $userId');
          return [];
        }
        
        // Convert to BookingModel
        final List<BookingModel> bookings = [];
        
        for (var item in rawData) {
          try {
            final bookingMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            print('📋 Raw booking data: ${bookingMap.keys}');
            
            final booking = BookingModel.fromJson(bookingMap);
            bookings.add(booking);
            
            print('✅ Booking loaded: ${booking.booking_code} (${booking.booking_status})');
          } catch (e) {
            print('⚠️ Error parsing booking: $e');
            print('⚠️ Raw item: $item');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        bookings.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        print('🎯 Total bookings yang berhasil di-load: ${bookings.length}');
        return bookings;
        
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to get bookings: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error mengambil bookings: $e');
      throw Exception('Gagal mengambil data booking: $e');
    }
  }

  // ============ GET BOOKINGS STATISTICS ============
  Future<Map<String, dynamic>> getUserBookingStats(String userId) async {
    print('📊 Mengambil statistik booking untuk user: $userId');
    
    try {
      final bookings = await getUserBookings(userId);
      
      final totalBookings = bookings.length;
      
      // ✅ PERBAIKAN: Gunakan getter totalPriceDouble untuk konversi String ke double
      final totalSpent = bookings.fold<double>(0, (sum, booking) => sum + booking.totalPriceDouble);
      
      // Hitung berdasarkan status
      final completedBookings = bookings.where((b) => b.booking_status == 'selesai').length;
      final pendingBookings = bookings.where((b) => b.booking_status == 'menunggu' || b.booking_status == 'diproses').length;
      final canceledBookings = bookings.where((b) => b.booking_status == 'dibatalkan').length;
      
      // Booking terbaru (3 terakhir)
      final recentBookings = bookings.take(3).map((booking) {
        return {
          'id': booking.id,
          'code': booking.booking_code,
          'status': booking.booking_status,
          'date': booking.booking_date,
          'total': booking.totalPriceDouble, // ✅ Gunakan totalPriceDouble
        };
      }).toList();
      
      final stats = {
        'total_bookings': totalBookings,
        'total_spent': totalSpent,
        'completed_bookings': completedBookings,
        'pending_bookings': pendingBookings,
        'canceled_bookings': canceledBookings,
        'recent_bookings': recentBookings,
        'has_bookings': totalBookings > 0,
      };
      
      print('📈 Statistik: $stats');
      return stats;
      
    } catch (e) {
      print('💥 Error mengambil statistik: $e');
      return {
        'total_bookings': 0,
        'total_spent': 0.0, // ✅ Gunakan 0.0 bukan 0
        'completed_bookings': 0,
        'pending_bookings': 0,
        'canceled_bookings': 0,
        'recent_bookings': [],
        'has_bookings': false,
      };
    }
  }

  //=================== create user ===================
  Future<void> createUser(UserModel user) async {
    print('➕ Creating user: ${user.name}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'user',
        'appid': _appId,
        'email': user.email,
        'password': user.password,
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'birth_date': user.birth_date,
        'gender': user.gender,
        'profile_picture': user.profile_picture,
        'salon_code': user.salon_code,
        'salon_name': user.salon_name,
        'salon_id': user.salon_id,
        'created_at': user.created_at,
      };
      
      print('📋 User Data:');
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
          print('✅ User created with ID: ${responseData[0]['_id']}');
        } else if (responseData is Map && responseData['status'] == '1') {
          print('✅ User created successfully');
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error creating user: $e');
      rethrow;
    }
  }

  // Method untuk delete user
  Future<void> deleteUser(String userId) async {
    print('🗑️ Deleting user: $userId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'user',
          'appid': _appId,
          'id': userId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      print('📦 Delete Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ User deleted successfully');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting user: $e');
      rethrow;
    }
  }

  // reset password
  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    print('🔄 Reset password for user: $userId');
    
    try {
      // 1. Get user data
      final user = await getUserById(userId);
      
      // 2. Update password
      final updatedUser = user.copyWith(
        password: newPassword, // Note: In production, this should be hashed
      );
      
      // 3. Save to database
      await updateUser(updatedUser);
      
      print('✅ Password reset successful');
      
    } catch (e) {
      print('❌ Error resetting password: $e');
      rethrow;
    }
  }  

  // lib/presentation/screens/services/auth_service.dart atau user_service.dart
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    print('🔐 Attempting login for: $email');

    try {
      // 1. BUAT URL UNTUK SEARCH USER BY EMAIL (TANPA FILTER ROLE)
      // API 247GO biasanya punya endpoint untuk search email
      final url = '${_baseUrl}select_where/token/$_token/project/$_project/collection/user/appid/$_appId/where_field/email/where_value/$email';
      
      print('🔗 Login URL: $url');
      
      // 2. LAKUKAN HTTP REQUEST
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      print('📡 Login Response Status: ${response.statusCode}');
      print('📦 Login Response Body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
      
      // 3. PARSE RESPONSE
      final dynamic responseData = json.decode(response.body);
      List<dynamic> rawData = [];
      
      if (responseData is List) {
        rawData = responseData;
      } else if (responseData is Map) {
        if (responseData.containsKey('data')) {
          rawData = responseData['data'] is List ? responseData['data'] : [];
        } else if (responseData.containsKey('result')) {
          rawData = responseData['result'] is List ? responseData['result'] : [];
        }
      }
      
      if (rawData.isEmpty) {
        throw Exception('Email tidak ditemukan');
      }
      
      // 4. AMBIL USER DATA
      final userMap = rawData[0] is Map<String, dynamic> 
          ? rawData[0] 
          : Map<String, dynamic>.from(rawData[0] as Map);
      
      print('📋 Raw user data: $userMap');
      
      // 5. VALIDASI PASSWORD
      final UserModel user = UserModel.fromJson(userMap);
      
      if (user.password != password) {
        throw Exception('Password salah');
      }
      
      print('✅ Login successful: ${user.name} (${user.role})');
      
      // 6. SIMPAN KE STORAGE
      print('💾 Saving user data to storage...');
      
      if (!StorageHelper.isInitialized()) {
        print('⚠️ StorageHelper not initialized, initializing now...');
        await StorageHelper.init();
      }
      
      // Simpan semua data user ke storage
      await Future.wait([
        StorageHelper.setString('user_id', user.id),
        StorageHelper.setString('user_name', user.name),
        StorageHelper.setString('user_email', user.email),
        StorageHelper.setString('user_role', user.role),
        StorageHelper.setString('user_phone', user.phone),
      ]);
      
      // Debug: Print stored data
      print('🔍 Verifying stored data:');
      print('  user_id: ${StorageHelper.getString("user_id")}');
      print('  user_name: ${StorageHelper.getString("user_name")}');
      print('  user_email: ${StorageHelper.getString("user_email")}');
      print('  user_role: ${StorageHelper.getString("user_role")}');
      print('  user_phone: ${StorageHelper.getString("user_phone")}');
      
      return user;

    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }
}