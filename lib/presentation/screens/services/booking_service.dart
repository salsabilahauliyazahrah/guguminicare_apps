// lib/presentation/screens/services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/booking_model.dart';

class BookingService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ CREATE NEW BOOKING ============
  Future<BookingModel> createBooking(BookingModel booking) async {
    print('➕ Membuat booking baru: ${booking.booking_code}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'booking',
        'appid': _appId,
        'booking_code': booking.booking_code,
        'user_id': booking.user_id,
        'pet_id': booking.pet_id,
        'service_id': booking.service_id,
        'booking_date': booking.booking_date,
        'booking_time': booking.booking_time,
        'service_method': booking.service_method,
        'address_id': booking.address_id,
        'driver_id': booking.driver_id,
        'special_notes': booking.special_notes,
        'total_price': booking.total_price,
        'additional_fee': booking.additional_fee,
        'payment_method': booking.payment_method,
        'payment_status': booking.payment_status,
        'booking_status': booking.booking_status,
        'created_at': booking.created_at,
      };
      
      print('📋 Booking Data:');
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
          
          print('✅ Booking created with ID: $newId');
          return booking.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return booking;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating booking: $e');
      rethrow;
    }
  }

  // ============ GET BOOKINGS BY USER ID ============
  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    print('📅 Mengambil bookings untuk user: $userId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'booking',
          'appid': _appId,
          'where_field': 'user_id',
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
        
        final List<BookingModel> bookings = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> bookingMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final booking = BookingModel.fromJson(bookingMap);
            bookings.add(booking);
          } catch (e) {
            print('⚠️ Error parsing booking: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal
        bookings.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return bookings;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error fetching user bookings: $e');
      rethrow;
    }
  }

  // ============ GET ALL BOOKINGS (ADMIN) ============
  Future<List<BookingModel>> getAllBookings() async {
    print('📅 Mengambil semua bookings...');
    
    final url = '${_baseUrl}select/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'booking',
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
        
        print('📊 Jumlah semua bookings: ${rawData.length}');
        
        final List<BookingModel> bookings = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> bookingMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final booking = BookingModel.fromJson(bookingMap);
            bookings.add(booking);
          } catch (e) {
            print('⚠️ Error parsing booking: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        bookings.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return bookings;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil semua bookings: $e');
      throw Exception('Gagal mengambil data booking: $e');
    }
  }

  // ============ UPDATE BOOKING STATUS ============
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    print('🔄 Update status booking $bookingId ke: $newStatus');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      // Get current booking first
      final booking = await getBookingById(bookingId);
      
      // ignore: unused_local_variable
      final updatedBooking = booking.copyWith(booking_status: newStatus);
      
      final Map<String, dynamic> updateData = {
        'booking_status': newStatus,
      };
      
      final bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'booking',
        'appid': _appId,
        'id': bookingId,
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
        
        print('✅ Booking status updated successfully');
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating booking status: $e');
      rethrow;
    }
  }

  // ============ GET BOOKING BY ID ============
  Future<BookingModel> getBookingById(String bookingId) async {
    print('🔎 Mengambil booking by ID: $bookingId');
    
    final url = '${_baseUrl}select_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'booking',
          'appid': _appId,
          'id': bookingId,
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
          final bookingMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return BookingModel.fromJson(bookingMap);
        }
      }
      
      throw Exception('Booking dengan ID $bookingId tidak ditemukan');
    } catch (e) {
      print('💥 Error getting booking by ID: $e');
      throw Exception('Gagal mengambil data booking: $e');
    }
  }

  // ============ CANCEL BOOKING ============
  Future<void> cancelBooking(String bookingId, String reason) async {
    print('❌ Cancel booking: $bookingId - Reason: $reason');
    
    try {
      // Update status ke 'dibatalkan'
      await updateBookingStatus(bookingId, 'dibatalkan');
      
      // Update payment status jika perlu
      final url = '${_baseUrl}update_id/';
      
      final updateData = {
        'payment_status': 'dibatalkan',
        'special_notes': 'Dibatalkan: $reason',
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'booking',
          'appid': _appId,
          'id': bookingId,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      if (response.statusCode == 200) {
        print('✅ Booking cancelled successfully');
      } else {
        throw Exception('Cancel failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error cancelling booking: $e');
      rethrow;
    }
  }

  // ============ UPDATE BOOKING (FULL DATA) ============
  Future<bool> updateBooking(String bookingId, Map<String, dynamic> data) async {
    print('🔄 Update booking $bookingId dengan data: $data');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'booking',
          'appid': _appId,
          'id': bookingId,
          'update_field': 'data',
          'update_value': jsonEncode(data),
        },
      );
      
      print('📡 Update Response: ${response.statusCode}');
      print('📦 Update Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is Map && responseData['status'] == '0') {
          print('❌ API Error: ${responseData['message']}');
          return false;
        }
        
        print('✅ Booking updated successfully');
        return true;
      } else {
        print('❌ HTTP Error ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error updating booking: $e');
      return false;
    }
  }
}