// ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'core/models/user_model.dart';
import 'dart:convert';

class DataService {

    static const String _baseUrl = 'https://api.247go.app/v5/';
    static const String _token = '68f2ede325bcf6243d214a05';
    static const String _project = 'gugumicare';
    static const String appid = '695d6cfd045a4b3d08976d16';

   Future insertAddress(String appid, String userid, String jenis_alamat, String alamat_lengkap, String kota, String is_utama, String catatan, String kode_pos, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'address',
            'appid': appid,
            'userid': userid,
            'jenis_alamat': jenis_alamat,
            'alamat_lengkap': alamat_lengkap,
            'kota': kota,
            'is_utama': is_utama,
            'catatan': catatan,
            'kode_pos': kode_pos,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertBooking(String appid, String booking_code, String user_id, String pet_id, String service_id, String booking_date, String booking_time, String service_method, String address_id, String driver_id, String special_notes, String total_price, String additional_fee, String payment_method, String payment_status, String booking_status, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'booking',
            'appid': appid,
            'booking_code': booking_code,
            'user_id': user_id,
            'pet_id': pet_id,
            'service_id': service_id,
            'booking_date': booking_date,
            'booking_time': booking_time,
            'service_method': service_method,
            'address_id': address_id,
            'driver_id': driver_id,
            'special_notes': special_notes,
            'total_price': total_price,
            'additional_fee': additional_fee,
            'payment_method': payment_method,
            'payment_status': payment_status,
            'booking_status': booking_status,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertDriverData(String appid, String name, String completed, String rating, String revenue) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'driver_data',
            'appid': appid,
            'name': name,
            'completed': completed,
            'rating': rating,
            'revenue': revenue
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertPetMedicalNotes(String appid, String pet_id, String special_condition, String current_medication, String grooming_behavior) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'pet_medical_notes',
            'appid': appid,
            'pet_id': pet_id,
            'special_condition': special_condition,
            'current_medication': current_medication,
            'grooming_behavior': grooming_behavior
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertPet(String appid, String user_id, String name, String type, String breed, String age, String weight, String photo, String is_safe, String last_grooming, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'pet',
            'appid': appid,
            'user_id': user_id,
            'name': name,
            'type': type,
            'breed': breed,
            'age': age,
            'weight': weight,
            'photo': photo,
            'is_safe': is_safe,
            'last_grooming': last_grooming,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertReport(String appid, String salon_id, String report_type, String period, String data, String generated_b, String generated_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'report',
            'appid': appid,
            'salon_id': salon_id,
            'report_type': report_type,
            'period': period,
            'data': data,
            'generated_b': generated_b,
            'generated_at': generated_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertReview(String appid, String booking_id, String user_id, String rating, String comment, String is_responded, String response_admin, String response_date, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'review',
            'appid': appid,
            'booking_id': booking_id,
            'user_id': user_id,
            'rating': rating,
            'comment': comment,
            'is_responded': is_responded,
            'response_admin': response_admin,
            'response_date': response_date,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertSalonSetting(String appid, String salon_id, String salon_name, String salon_address, String salon_phone, String salon_email, String salon_website, String business_hours, String notifications_enabled, String email_notifications, String sms_notifications, String auto_confirm_booking, String require_deposit, String deposit_percentage, String salon_service_enabled, String home_service_enabled, String pickup_service_enabled, String pickup_service_fee, String cod_enabled, String bank_transfer_enabled, String qris_enabled, String ewallet_enabled, String created_at, String updated_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'salon_setting',
            'appid': appid,
            'salon_id': salon_id,
            'salon_name': salon_name,
            'salon_address': salon_address,
            'salon_phone': salon_phone,
            'salon_email': salon_email,
            'salon_website': salon_website,
            'business_hours': business_hours,
            'notifications_enabled': notifications_enabled,
            'email_notifications': email_notifications,
            'sms_notifications': sms_notifications,
            'auto_confirm_booking': auto_confirm_booking,
            'require_deposit': require_deposit,
            'deposit_percentage': deposit_percentage,
            'salon_service_enabled': salon_service_enabled,
            'home_service_enabled': home_service_enabled,
            'pickup_service_enabled': pickup_service_enabled,
            'pickup_service_fee': pickup_service_fee,
            'cod_enabled': cod_enabled,
            'bank_transfer_enabled': bank_transfer_enabled,
            'qris_enabled': qris_enabled,
            'ewallet_enabled': ewallet_enabled,
            'created_at': created_at,
            'updated_at': updated_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertService(String appid, String name, String description, String price, String duration, String category, String icon, String color, String details, String benefits, String suitable_for, String is_active, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'service',
            'appid': appid,
            'name': name,
            'description': description,
            'price': price,
            'duration': duration,
            'category': category,
            'icon': icon,
            'color': color,
            'details': details,
            'benefits': benefits,
            'suitable_for': suitable_for,
            'is_active': is_active,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertStaffAssignments(String appid, String staff_id, String role, String assigned_by, String status, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'staff_assignments',
            'appid': appid,
            'staff_id': staff_id,
            'role': role,
            'assigned_by': assigned_by,
            'status': status,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertUser(String appid, String email, String password, String name, String phone, String role, String birth_date, String gender, String profile_picture, String salon_code, String salon_name, String salon_id, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'user',
            'appid': appid,
            'email': email,
            'password': password,
            'name': name,
            'phone': phone,
            'role': role,
            'birth_date': birth_date,
            'gender': gender,
            'profile_picture': profile_picture,
            'salon_code': salon_code,
            'salon_name': salon_name,
            'salon_id': salon_id,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

    static Future<Map<String, dynamic>> _postRequest({
      required String endpoint,
      required Map<String, dynamic> body,
    }) async {
      try {
        // 1. CONVERT semua values ke String
        final Map<String, String> stringBody = {};
        
        body.forEach((key, value) {
          if (value is String) {
            stringBody[key] = value;
          } else if (value is int || value is double || value is bool) {
            stringBody[key] = value.toString();
          } else if (value is Map || value is List) {
            stringBody[key] = jsonEncode(value); // Convert JSON to string
          } else if (value == null) {
            stringBody[key] = '';
          } else {
            stringBody[key] = value.toString();
          }
        });

        // 2. Add token dan project
        stringBody['token'] = _token;
        stringBody['project'] = _project;

        print('API Request to: $_baseUrl$endpoint');
        print('Request body: $stringBody');

        // 3. Make request
        final response = await http.post(
          Uri.parse('$_baseUrl$endpoint'),
          body: stringBody,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );

        print('API Response status: ${response.statusCode}');
        print('API Response body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          print('API Decoded response: $decoded');
          return decoded;
        } else {
          throw Exception('API Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        print('API Error: $e');
        throw Exception('Network Error: $e');
      }
    }

    // USER METHODS
    static Future<UserModel> registerUser({
      required String name,
      required String email,
      required String password,
      required String phone,
      String role = 'customer', // AUTO DEFAULT = CUSTOMER
    }) async {
      final result = await _postRequest(
        endpoint: 'insert/',
        body: {
          'collection': 'user',
          'appid': appid,
          'email': email,
          'password': password, // NOTE: Ini harus di-hash di backend!
          'name': name,
          'phone': phone,
          'role': role, // OTOMATIS "customer"
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return UserModel.fromJson(result['data'] ?? {});
    }

    static Future<UserModel> loginUser({
      required String email,
      required String password,
    }) async {
      final result = await _postRequest(
        endpoint: 'get/', // Asumsi ada endpoint login
        body: {
          'collection': 'user',
          'query': jsonEncode({
            'email': email,
            'password': password, // Backend harus compare hash
          }),
        },
      );

      final userData = result['data'] is List && result['data'].isNotEmpty
          ? result['data'][0]
          : throw Exception('User not found');

      return UserModel.fromJson(userData);
    }

    // FORGOT PASSWORD METHODS
    static Future<bool> requestPasswordReset(String phone) async {
      // 1. Cek apakah phone ada di database
      final result = await _postRequest(
        endpoint: 'get/',
        body: {
          'collection': 'user',
          'query': jsonEncode({'phone': phone}),
        },
      );

      final users = result['data'] as List;
      if (users.isEmpty) throw Exception('Nomor telepon tidak terdaftar');

      // 2. Generate reset token (ini harus di backend)
      final userId = users[0]['id'];
      
      // 3. Simpan reset token ke database
      await _postRequest(
        endpoint: 'update/',
        body: {
          'collection': 'user',
          'id': userId,
          'data': jsonEncode({
            'reset_password_token': 'generated_token_123',
            'reset_password_expires': DateTime.now()
                .add(Duration(hours: 1))
                .toIso8601String(),
          }),
        },
      );

      return true;
    }

    static Future<bool> resetPassword({
      required String phone,
      required String newPassword,
      required String token,
    }) async {
      // 1. Verifikasi token masih valid
      final result = await _postRequest(
        endpoint: 'get/',
        body: {
          'collection': 'user',
          'query': jsonEncode({
            'phone': phone,
            'reset_password_token': token,
          }),
        },
      );

      final users = result['data'] as List;
      if (users.isEmpty) throw Exception('Token tidak valid');

      final user = users[0];
      final expires = DateTime.parse(user['reset_password_expires']);
      
      if (DateTime.now().isAfter(expires)) {
        throw Exception('Token telah kadaluarsa');
      }

      // 2. Update password
      await _postRequest(
        endpoint: 'update/',
        body: {
          'collection': 'user',
          'id': user['id'],
          'data': jsonEncode({
            'password': newPassword, // Hash di backend
            'reset_password_token': null,
            'reset_password_expires': null,
          }),
        },
      );

      return true;
    }

    // ADMIN METHODS (Hanya admin yang bisa buat admin/driver baru)
    static Future<UserModel> createAdminOrDriver({
      required String name,
      required String email,
      required String password,
      required String phone,
      required String role, // 'admin' atau 'driver'
      String? salonCode,
      String? salonName,
      String? salonId,
    }) async {
      // HANYA ADMIN YANG BISA PAKAI METHOD INI
      final result = await _postRequest(
        endpoint: 'insert/',
        body: {
          'collection': 'user',
          'appid': appid,
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
          'salon_code': salonCode,
          'salon_name': salonName,
          'salon_id': salonId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return UserModel.fromJson(result['data'] ?? {});
    }

   Future insertNotification(String appid, String user_id, String title, String message, String type, String icon, String color, String is_read, String metadata, String created_at) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '68f2ede325bcf6243d214a05',
            'project': 'gugumicare',
            'collection': 'notification',
            'appid': appid,
            'user_id': user_id,
            'title': title,
            'message': message,
            'type': type,
            'icon': icon,
            'color': color,
            'is_read': is_read,
            'metadata': metadata,
            'created_at': created_at
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/select_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectId(String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/select_id/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/id/' + id;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

    // Di restapi.dart, update selectWhere:
   Future selectWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/select_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/select_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/select_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/select_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/select_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future removeAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/remove_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeId(String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/remove_id/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/id/' + id;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/remove_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/remove_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future updateAll(String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_all/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateId(String update_field, String update_value, String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/update_id/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid,
             'id': id
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhere(String where_field, String where_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'where_field': where_field,
             'where_value': where_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateOrWhere(String or_where_field, String or_where_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_or_where/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'or_where_field': or_where_field,
             'or_where_value': or_where_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereLike(String wlike_field, String wlike_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_like/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'wlike_field': wlike_field,
             'wlike_value': wlike_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereIn(String win_field, String win_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_in/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'win_field': win_field,
             'win_value': win_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereNotIn(String wnotin_field, String wnotin_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_not_in/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'wnotin_field': wnotin_field,
             'wnotin_value': wnotin_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future firstAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/first_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/first_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/first_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/first_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/first_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/first_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/last_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/last_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/last_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/last_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/last_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/last_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/random_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/random_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/random_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/random_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/random_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/random_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

  Future upload(
      String token,
      String project,
      Uint8List fileBytes,
      String extension) async {
    String uri = 'https://api.247go.app/v5/upload/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uri));

      request.fields['token'] = token;
      request.fields['project'] = project;

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: 'file.$extension',
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '{"error": "Upload failed"}';
      }
    } catch (e) {
      return '{"error": "Upload failed"}';
    }
  }   
}