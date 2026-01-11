// lib/presentation/screens/services/staff_assignments_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/staff_assignment_model.dart';

class StaffAssignmentsService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET ASSIGNMENTS BY STAFF ID ============
  Future<List<StaffAssignmentsModel>> getAssignmentsByStaffId(String staffId) async {
    print('👥 Mengambil assignments untuk staff: $staffId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'staff_assignments',
          'appid': _appId,
          'where_field': 'staff_id',
          'where_value': staffId,
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
        
        print('📊 Jumlah assignments ditemukan: ${rawData.length}');
        
        final List<StaffAssignmentsModel> assignments = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> assignmentMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final assignment = StaffAssignmentsModel.fromJson(assignmentMap);
            assignments.add(assignment);
            
            print('✅ Loaded: ${assignment.role} - ${assignment.status}');
          } catch (e) {
            print('⚠️ Error parsing assignment: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        assignments.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return assignments;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil assignments: $e');
      throw Exception('Gagal mengambil data assignments: $e');
    }
  }

  // ============ CREATE NEW ASSIGNMENT ============
  Future<StaffAssignmentsModel> createAssignment(StaffAssignmentsModel assignment) async {
    print('➕ Membuat assignment baru untuk staff: ${assignment.staff_id}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      // Jika menugaskan sebagai aktif, nonaktifkan assignment lain untuk staff yang sama
      if (assignment.isActive) {
        await _deactivateOtherAssignments(assignment.staff_id);
      }
      
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'staff_assignments',
        'appid': _appId,
        'staff_id': assignment.staff_id,
        'role': assignment.role,
        'assigned_by': assignment.assigned_by,
        'status': assignment.status,
        'created_at': assignment.created_at,
      };
      
      print('📋 Assignment Data:');
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
          
          print('✅ Assignment created with ID: $newId');
          return assignment.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return assignment;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating assignment: $e');
      rethrow;
    }
  }

  // ============ UPDATE ASSIGNMENT ============
  Future<void> updateAssignment(StaffAssignmentsModel assignment) async {
    print('✏️ Update assignment: ${assignment.id}');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      // Jika mengubah status menjadi aktif, nonaktifkan assignment lain
      if (assignment.isActive) {
        await _deactivateOtherAssignments(assignment.staff_id, excludeId: assignment.id);
      }
      
      final Map<String, dynamic> updateData = {
        'role': assignment.role,
        'assigned_by': assignment.assigned_by,
        'status': assignment.status,
      };
      
      final bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'staff_assignments',
        'appid': _appId,
        'id': assignment.id,
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
        
        print('✅ Assignment updated successfully');
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating assignment: $e');
      rethrow;
    }
  }

  // ============ DEACTIVATE OTHER ASSIGNMENTS (HELPER) ============
  Future<void> _deactivateOtherAssignments(String staffId, {String? excludeId}) async {
    print('🔁 Deactivating other assignments for staff: $staffId');
    
    try {
      final assignments = await getAssignmentsByStaffId(staffId);
      
      for (var assignment in assignments) {
        // Skip jika ini assignment yang dikecualikan
        if (excludeId != null && assignment.id == excludeId) continue;
        
        // Skip jika sudah tidak aktif
        if (!assignment.isActive) continue;
        
        // Deactivate assignment
        final deactivated = assignment.copyWith(status: 'inactive');
        await updateAssignment(deactivated);
        
        print('   Deactivated assignment: ${assignment.id}');
      }
    } catch (e) {
      print('⚠️ Error deactivating other assignments: $e');
    }
  }

  // ============ GET ACTIVE ASSIGNMENT ============
  Future<StaffAssignmentsModel?> getActiveAssignment(String staffId) async {
    print('🔍 Mencari assignment aktif untuk staff: $staffId');
    
    try {
      final assignments = await getAssignmentsByStaffId(staffId);
      
      // Cari assignment yang aktif
      for (var assignment in assignments) {
        if (assignment.isActive) {
          print('✅ Found active assignment: ${assignment.role}');
          return assignment;
        }
      }
      
      print('ℹ️ No active assignment found');
      return null;
    } catch (e) {
      print('💥 Error getting active assignment: $e');
      return null;
    }
  }

  // ============ CHANGE STAFF ROLE ============
  Future<void> changeStaffRole({
    required String staffId,
    required String newRole,
    required String assignedBy,
  }) async {
    print('🔄 Changing staff role: $staffId -> $newRole');
    
    try {
      // Get active assignment
      final activeAssignment = await getActiveAssignment(staffId);
      
      if (activeAssignment != null) {
        // Deactivate current assignment
        await updateAssignment(activeAssignment.copyWith(status: 'inactive'));
        
        // Create new assignment with new role
        final newAssignment = StaffAssignmentsModel.createNew(
          staff_id: staffId,
          role: newRole,
          assigned_by: assignedBy,
          status: 'active',
        );
        
        await createAssignment(newAssignment);
        
        print('✅ Staff role changed successfully');
      } else {
        // Create new assignment if no active one exists
        final newAssignment = StaffAssignmentsModel.createNew(
          staff_id: staffId,
          role: newRole,
          assigned_by: assignedBy,
          status: 'active',
        );
        
        await createAssignment(newAssignment);
        
        print('✅ New assignment created');
      }
    } catch (e) {
      print('💥 Error changing staff role: $e');
      rethrow;
    }
  }

  // ============ GET ALL ACTIVE STAFF ============
  Future<List<StaffAssignmentsModel>> getAllActiveStaff() async {
    print('👥 Mengambil semua staff aktif');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'staff_assignments',
          'appid': _appId,
          'where_field': 'status',
          'where_value': 'active',
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
        
        final List<StaffAssignmentsModel> activeStaff = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> assignmentMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            activeStaff.add(StaffAssignmentsModel.fromJson(assignmentMap));
          } catch (e) {
            print('⚠️ Error parsing staff: $e');
          }
        }
        
        print('✅ Found ${activeStaff.length} active staff members');
        return activeStaff;
      }
      
      throw Exception('Failed to get active staff');
    } catch (e) {
      print('💥 Error getting active staff: $e');
      rethrow;
    }
  }

  // ============ GET STAFF BY ROLE ============
  Future<List<StaffAssignmentsModel>> getStaffByRole(String role) async {
    print('🔍 Mengambil staff dengan role: $role');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'staff_assignments',
          'appid': _appId,
          'where_field': 'role',
          'where_value': role,
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
        
        return rawData.map((item) {
          final Map<String, dynamic> assignmentMap = item is Map<String, dynamic> 
              ? item 
              : Map<String, dynamic>.from(item as Map);
          return StaffAssignmentsModel.fromJson(assignmentMap);
        }).toList();
      }
      
      throw Exception('Failed to get staff by role');
    } catch (e) {
      print('💥 Error getting staff by role: $e');
      rethrow;
    }
  }

  // ============ DELETE ASSIGNMENT ============
  Future<void> deleteAssignment(String assignmentId) async {
    print('🗑️ Delete assignment: $assignmentId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'staff_assignments',
          'appid': _appId,
          'id': assignmentId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Assignment deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting assignment: $e');
      rethrow;
    }
  }
}