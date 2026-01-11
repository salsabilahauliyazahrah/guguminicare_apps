//lib/presentation/screens/auth/storage_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageHelper {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  // Initialize
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('✅ StorageHelper initialized successfully');
    } catch (e) {
      print('❌ Error initializing StorageHelper: $e');
      _isInitialized = false;
    }
  }

  // Check if initialized
  static bool isInitialized() {
    return _isInitialized && _prefs != null;
  }  

  // Perbaiki method getString untuk handle null safety
  static String? getString(String key) {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized! Call StorageHelper.init() first');
      return null;
    }
    
    final value = _prefs!.getString(key);
    print('📖 Storage get: "$key" = "$value"');
    return value;
  }

  // Perbaiki save method
  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized!');
      return false;
    }
    
    print('💾 Storage save: "$key" = "$value"');
    return await _prefs!.setString(key, value);
  }  

  // SAVE methods
  static Future<bool> save(String key, dynamic value) async {
    if (value is String) return _prefs!.setString(key, value);
    if (value is int) return _prefs!.setInt(key, value);
    if (value is bool) return _prefs!.setBool(key, value);
    if (value is double) return _prefs!.setDouble(key, value);
    if (value is List<String>) return _prefs!.setStringList(key, value);
    
    // Untuk Map/List object, convert ke JSON string
    if (value is Map || value is List) {
      return _prefs!.setString(key, json.encode(value));
    }
    
    throw Exception('Unsupported type: ${value.runtimeType}');
  }

  // GET methods  
  static int? getInt(String key) => _prefs?.getInt(key);
  static bool? getBool(String key) => _prefs?.getBool(key);
  static double? getDouble(String key) => _prefs?.getDouble(key);
  static List<String>? getStringList(String key) => _prefs?.getStringList(key);
  
  // Get JSON (auto decode)
  static dynamic getJson(String key) {
    final jsonString = _prefs?.getString(key);
    return jsonString != null ? json.decode(jsonString) : null;
  }

  // REMOVE
  static Future<bool> remove(String key) async {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized!');
      return false;
    }
    
    print('🗑️ Storage remove: "$key"');
    return await _prefs!.remove(key);
  }  
  
  // CLEAR ALL
  static Future<bool> clear() async {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized!');
      return false;
    }
    
    print('🧹 Storage clear all');
    return await _prefs!.clear();
  }  
  
  // CHECK IF EXISTS
  static bool containsKey(String key) {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized!');
      return false;
    }
    
    return _prefs!.containsKey(key);
  }

  // Get all keys
  static Set<String> getKeys() {
    if (_prefs == null) {
      print('❌ StorageHelper not initialized!');
      return {};
    }
    
    return _prefs!.getKeys();
  }  
  
}