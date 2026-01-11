// lib/presentation/screens/auth/auth_service.dart
import 'dart:convert';
import 'package:tugas_akhir/restapi.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class AuthService {
  static UserModel? _currentUser;
  
  // LOGIN dengan DataService
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      
      // 1. Get users dengan email tersebut
      final response = await DataService().selectWhere(
        '68f2ede325bcf6243d214a05',
        'gugumicare',
        'user',
        '695d6cfd045a4b3d08976d16',
        'email',
        email,
      );
      
      // 2. Parse String response menjadi List
      List<dynamic> users = [];
      
      if (response is String && response.isNotEmpty) {
        print('📦 Raw response: $response');
        
        try {
          final parsed = json.decode(response);
          
          if (parsed is Map<String, dynamic> && parsed.containsKey('data')) {
            // Format: {"limit":0,"offset":0,"total":1,"data":[...]}
            users = parsed['data'] as List;
          } else if (parsed is List) {
            // Format langsung: [...]
            users = parsed;
          }
          
          print('📊 Parsed users: $users');
          print('📊 Users count: ${users.length}');
          
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          throw Exception('Format response tidak valid');
        }
      } else if (response is List) {
        users = response;
      }
      
      if (users.isEmpty) {
        throw Exception('Email tidak terdaftar');
      }
      
      // 3. Cari user dengan password yang cocok
      UserModel? foundUser;
      for (var userData in users) {
        if (userData['password'] == password) {
          foundUser = UserModel.fromJson(userData);
          break;
        }
      }
      
      if (foundUser == null) {
        throw Exception('Password salah');
      }
      
      // 4. Simpan ke local storage
      await _saveUserToStorage(foundUser);
      
      // 5. Set current user
      _currentUser = foundUser;
      
      print('✅ Login success: ${foundUser.name}, Role: ${foundUser.role}');
      
      return foundUser;
      
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // REGISTER dengan DataService
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      print('📝 Registering user: $name ($email)');
      
      // 1. Cek apakah email sudah terdaftar
      final rawExisting = await DataService().selectWhere(
        '68f2ede325bcf6243d214a05',
        'gugumicare',
        'user',
        '695d6cfd045a4b3d08976d16',
        'email',
        email,
      );

      List<dynamic> existingUsers = [];
      try {
        if (rawExisting is String && rawExisting.isNotEmpty) {
          final parsed = json.decode(rawExisting);
          if (parsed is Map && parsed.containsKey('data')) {
            existingUsers = parsed['data'] as List<dynamic>;
          } else if (parsed is List) {
            existingUsers = parsed;
          }
        } else if (rawExisting is List) {
          existingUsers = rawExisting;
        }
      } catch (e) {
        print('❌ Error parsing existing users response: $e');
        existingUsers = [];
      }

      if (existingUsers.isNotEmpty) {
        throw Exception('Email sudah terdaftar');
      }
      
      // 2. Insert user ke database dengan role CUSTOMER
      final result = await DataService().insertUser(
        'gugumicare', // appid
        email,
        password,
        name,
        phone,
        'customer', // ✅ AUTO ROLE = CUSTOMER (FIXED)
        '', // birth_date
        '', // gender
        '', // profile_picture
        '', // salon_code
        '', // salon_name
        '', // salon_id
        DateTime.now().toIso8601String(), // created_at
      );
      
      print('📦 Insert result: $result');

      // 3. Pastikan insert berhasil dan ambil user baru
      final rawNew = await DataService().selectWhere(
        '68f2ede325bcf6243d214a05',
        'gugumicare',
        'user',
        '695d6cfd045a4b3d08976d16',
        'email',
        email,
      );

      List<dynamic> newUsers = [];
      try {
        if (rawNew is String && rawNew.isNotEmpty) {
          final parsed = json.decode(rawNew);
          if (parsed is Map && parsed.containsKey('data')) {
            newUsers = parsed['data'] as List<dynamic>;
          } else if (parsed is List) {
            newUsers = parsed;
          }
        } else if (rawNew is List) {
          newUsers = rawNew;
        }
      } catch (e) {
        print('❌ Error parsing new users response: $e');
        newUsers = [];
      }

      if (newUsers.isEmpty) {
        throw Exception('Registrasi gagal - user tidak ditemukan setelah insert');
      }

      final user = UserModel.fromJson(newUsers[0] as Map<String, dynamic>);
      
      // 5. Simpan ke local storage
      await _saveUserToStorage(user);
      
      // 6. Set current user
      _currentUser = user;
      
      print('✅ Register success: ${user.name}');
      print('📋 User details:');
      print('   ID: ${user.id}');
      print('   Email: ${user.email}');
      print('   Role: ${user.role}');
      print('   Phone: ${user.phone}');
      
      return user;
      
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  // Helper: Simpan user ke storage
  static Future<void> _saveUserToStorage(UserModel user) async {
    try {
      // Simpan sebagai JSON string
      await StorageHelper.save('current_user', json.encode(user.toJson()));
      
      // Simpan juga individual fields untuk akses cepat
      await StorageHelper.save('auth_token', 'dummy_token_${user.id}');
      await StorageHelper.save('user_id', user.id);
      await StorageHelper.save('user_email', user.email);
      await StorageHelper.save('user_name', user.name);
      await StorageHelper.save('user_role', user.role);
      await StorageHelper.save('user_phone', user.phone);
      
      print('💾 Saved user to storage: ${user.name}');
    } catch (e) {
      print('❌ Error saving to storage: $e');
    }
  }

  // GET CURRENT USER
  static UserModel? get currentUser => _currentUser;
  
  // GET USER ROLE
  static String? get userRole => _currentUser?.role;
  
  // LOGOUT
  static Future<void> logout() async {
    await StorageHelper.clear();
    _currentUser = null;
    print('🚪 User logged out');
  }
  
  // CHECK IF LOGGED IN
  static bool get isLoggedIn => _currentUser != null;
  
  // LOAD USER FROM STORAGE (saat app start)
  static Future<void> loadUserFromStorage() async {
    try {
      // Load dari JSON string
      final userJsonString = StorageHelper.getString('current_user');
      
      if (userJsonString != null && userJsonString.isNotEmpty) {
        final userJson = json.decode(userJsonString) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userJson);
        print('✅ Loaded user from storage: ${_currentUser!.name}');
        print('📋 Role: ${_currentUser!.role}');
      } else {
        // Fallback: load dari individual fields
        final id = StorageHelper.getString('user_id');
        final email = StorageHelper.getString('user_email');
        final name = StorageHelper.getString('user_name');
        final role = StorageHelper.getString('user_role');
        final phone = StorageHelper.getString('user_phone');
        
        if (id != null && email != null && name != null && role != null) {
          _currentUser = UserModel(
            id: id,
            email: email,
            password: '', // Password tidak disimpan di storage (SECURITY!)
            name: name,
            phone: phone ?? '',
            role: role,
            birth_date: '',
            gender: '',
            profile_picture: '',
            salon_code: '',
            salon_name: '',
            salon_id: '',
            created_at: '',
          );
          print('✅ Loaded user from legacy storage: ${_currentUser!.name}');
          print('📋 Role: ${_currentUser!.role}');
        } else {
          print('ℹ️ No user found in storage');
        }
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
    }
  }
}