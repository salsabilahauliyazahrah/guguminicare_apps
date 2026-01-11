// lib/presentation/screens/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/report_model.dart';

class ReportService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET REPORTS BY SALON ID ============
  Future<List<ReportModel>> getReportsBySalonId(String salonId) async {
    print('📊 Mengambil laporan untuk salon: $salonId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'report',
          'appid': _appId,
          'where_field': 'salon_id',
          'where_value': salonId,
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
        
        print('📊 Jumlah laporan ditemukan: ${rawData.length}');
        
        final List<ReportModel> reports = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> reportMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final report = ReportModel.fromJson(reportMap);
            reports.add(report);
            
            print('✅ Loaded: ${report.report_type} - ${report.period}');
          } catch (e) {
            print('⚠️ Error parsing report: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        reports.sort((a, b) {
          final dateA = a.generated_at;
          final dateB = b.generated_at;
          return dateB.compareTo(dateA);
        });
        
        return reports;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil laporan: $e');
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  // ============ CREATE NEW REPORT ============
  Future<ReportModel> createReport(ReportModel report) async {
    print('➕ Membuat laporan baru: ${report.report_type}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'report',
        'appid': _appId,
        'salon_id': report.salon_id,
        'report_type': report.report_type,
        'period': report.period,
        'data': report.data,
        'generated_by': report.generated_by,
        'generated_at': report.generated_at,
      };
      
      print('📋 Report Data:');
      bodyData.forEach((key, value) {
        final displayValue = key == 'data' && value.length > 100 
            ? '${value.substring(0, 100)}...' 
            : value;
        print('   $key: $displayValue');
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
          
          print('✅ Report created with ID: $newId');
          return report.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return report;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating report: $e');
      rethrow;
    }
  }

  // ============ GENERATE INCOME REPORT ============
  Future<ReportModel> generateIncomeReport({
    required String salonId,
    required String period,
    required String generatedBy,
    required Map<String, dynamic> incomeData,
  }) async {
    print('💰 Generate income report for salon: $salonId');
    
    final report = ReportModel.createNew(
      salon_id: salonId,
      report_type: 'pendapatan',
      period: period,
      data: incomeData,
      generated_by: generatedBy,
    );
    
    return await createReport(report);
  }

  // ============ GENERATE SERVICE REPORT ============
  Future<ReportModel> generateServiceReport({
    required String salonId,
    required String period,
    required String generatedBy,
    required Map<String, dynamic> serviceData,
  }) async {
    print('✂️ Generate service report for salon: $salonId');
    
    final report = ReportModel.createNew(
      salon_id: salonId,
      report_type: 'service',
      period: period,
      data: serviceData,
      generated_by: generatedBy,
    );
    
    return await createReport(report);
  }

  // ============ GET REPORT BY ID ============
  Future<ReportModel> getReportById(String reportId) async {
    print('🔎 Mengambil laporan by ID: $reportId');
    
    final url = '${_baseUrl}select_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'report',
          'appid': _appId,
          'id': reportId,
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
          final reportMap = rawData[0] is Map<String, dynamic> 
              ? rawData[0] 
              : Map<String, dynamic>.from(rawData[0] as Map);
          
          return ReportModel.fromJson(reportMap);
        }
      }
      
      throw Exception('Laporan dengan ID $reportId tidak ditemukan');
    } catch (e) {
      print('💥 Error getting report by ID: $e');
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  // ============ DELETE REPORT ============
  Future<void> deleteReport(String reportId) async {
    print('🗑️ Delete report: $reportId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'report',
          'appid': _appId,
          'id': reportId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Report deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting report: $e');
      rethrow;
    }
  }

  // ============ GET RECENT REPORTS ============
  Future<List<ReportModel>> getRecentReports(String salonId, {int limit = 5}) async {
    final allReports = await getReportsBySalonId(salonId);
    return allReports.take(limit).toList();
  }

  // ============ GET REPORT SUMMARY ============
  Future<Map<String, dynamic>> getReportSummary(String salonId) async {
    print('📈 Getting report summary for salon: $salonId');
    
    try {
      final reports = await getReportsBySalonId(salonId);
      
      final totalReports = reports.length;
      final incomeReports = reports.where((r) => r.report_type == 'pendapatan').length;
      final serviceReports = reports.where((r) => r.report_type == 'service').length;
      final customerReports = reports.where((r) => r.report_type == 'customer').length;
      final driverReports = reports.where((r) => r.report_type == 'driver').length;
      
      // Get latest report date
      final latestReport = reports.isNotEmpty ? reports.first.generatedAtOrNull : null;
      final latestDate = latestReport != null 
          ? '${latestReport.day}/${latestReport.month}/${latestReport.year}'
          : '-';
      
      return {
        'total_reports': totalReports,
        'income_reports': incomeReports,
        'service_reports': serviceReports,
        'customer_reports': customerReports,
        'driver_reports': driverReports,
        'latest_report_date': latestDate,
        'has_reports': totalReports > 0,
      };
    } catch (e) {
      print('💥 Error getting report summary: $e');
      return {
        'total_reports': 0,
        'income_reports': 0,
        'service_reports': 0,
        'customer_reports': 0,
        'driver_reports': 0,
        'latest_report_date': '-',
        'has_reports': false,
      };
    }
  }
}