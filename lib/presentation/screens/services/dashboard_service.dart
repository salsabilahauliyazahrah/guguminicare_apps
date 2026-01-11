//simpan logic untuk dashboard service admin di sini

// lib/core/services/dashboard_service.dart
import 'dart:convert';
import 'package:tugas_akhir/restapi.dart';
import 'package:tugas_akhir/core/models/booking_model.dart';
import 'package:intl/intl.dart';


class DashboardService {
  static const String token = '68f2ede325bcf6243d214a05';
  static const String project = 'gugumicare';
  static const String appid = '695d6cfd045a4b3d08976d16';

  // 1. STATISTIK UTAMA
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final customers = await _getTotalCustomers();
      final bookings = await _getTodayBookings();
      final revenue = await _getMonthlyRevenue();
      final pending = await _getPendingBookings();
      final avgRating = await _getAverageRating();

      return {
        'totalCustomers': customers,
        'todayBookings': bookings,
        'monthlyRevenue': revenue,
        'pendingBookings': pending,
        'averageRating': avgRating,
      };
    } catch (e) {
      print('❌ Error getDashboardStats: $e');
      return {
        'totalCustomers': 0,
        'todayBookings': 0,
        'monthlyRevenue': 0,
        'pendingBookings': 0,
        'averageRating': 4.8,
      };
    }
  }

  // 2. BOOKING TERBARU (max 5)
  static Future<List<BookingModel>> getRecentBookings() async {
    try {
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allBookings is String && allBookings.isNotEmpty) {
        final decoded = json.decode(allBookings);
        final bookingsData = decoded['data'] as List? ?? [];
        
        // Urutkan berdasarkan created_at (terbaru dulu)
        bookingsData.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] ?? '');
          final dateB = DateTime.tryParse(b['created_at'] ?? '');
          return dateB?.compareTo(dateA ?? DateTime(0)) ?? 0;
        });
        
        // Ambil 5 terbaru
        final recent = bookingsData.take(5).map((data) => 
          BookingModel.fromJson(data)
        ).toList();
        
        return recent;
      }
      return [];
    } catch (e) {
      print('❌ Error getRecentBookings: $e');
      return [];
    }
  }

  // 3. LAYANAN TERPOPULER (berdasarkan jumlah booking)
  static Future<List<Map<String, dynamic>>> getTopServices() async {
    try {
      // Get all services
      final allServices = await DataService().selectAll(token, project, 'service', appid);
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allServices is String && allBookings is String) {
        final servicesData = json.decode(allServices)['data'] as List? ?? [];
        final bookingsData = json.decode(allBookings)['data'] as List? ?? [];
        
        // Hitung jumlah booking per service
        Map<String, int> serviceCounts = {};
        Map<String, double> serviceRevenue = {};
        
        for (var booking in bookingsData) {
          final serviceId = booking['service_id']?.toString();
          final price = double.tryParse(booking['total_price']?.toString() ?? '0') ?? 0;
          
          if (serviceId != null && serviceId.isNotEmpty) {
            serviceCounts[serviceId] = (serviceCounts[serviceId] ?? 0) + 1;
            serviceRevenue[serviceId] = (serviceRevenue[serviceId] ?? 0) + price;
          }
        }
        
        // Gabungkan dengan service data
        List<Map<String, dynamic>> topServices = [];
        
        for (var service in servicesData) {
          final serviceId = service['_id']?.toString();
          final count = serviceCounts[serviceId] ?? 0;
          final revenue = serviceRevenue[serviceId] ?? 0;
          
          if (count > 0) {
            topServices.add({
              'id': serviceId,
              'name': service['name'] ?? '',
              'count': count,
              'revenue': revenue,
            });
          }
        }
        
        // Urutkan berdasarkan count (terbanyak)
        topServices.sort((a, b) => b['count'].compareTo(a['count']));
        
        return topServices.take(5).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getTopServices: $e');
      return [];
    }
  }

  // 4. AKTIVITAS DRIVER
  static Future<List<Map<String, dynamic>>> getDriverActivities() async {
    try {
      final allDrivers = await DataService().selectAll(token, project, 'driver_data', appid);
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allDrivers is String) {
        final driversData = json.decode(allDrivers)['data'] as List? ?? [];
        final bookingsData = json.decode(allBookings)['data'] as List? ?? [];
        
        List<Map<String, dynamic>> driverActivities = [];
        
        for (var driver in driversData) {
          final driverId = driver['_id']?.toString();
          final driverName = driver['name'] ?? 'Unknown Driver';
          final completed = int.tryParse(driver['completed']?.toString() ?? '0') ?? 0;
          
          // Hitung assigned bookings untuk driver ini
          int assigned = 0;
          for (var booking in bookingsData) {
            if (booking['driver_id']?.toString() == driverId) {
              final status = booking['booking_status']?.toString() ?? '';
              if (status != 'selesai' && status != 'cancelled') {
                assigned++;
              }
            }
          }
          
          // Tentukan status
          String status = 'inactive';
          String statusText = 'Offline';
          if (assigned > 0) {
            status = 'on_delivery';
            statusText = 'Sedang Antar';
          } else if (completed > 0) {
            status = 'active';
            statusText = 'Aktif';
          }
          
          driverActivities.add({
            'driver_name': driverName,
            'status': status,
            'status_text': statusText,
            'assigned': assigned,
            'completed': completed,
          });
        }
        
        return driverActivities;
      }
      return [];
    } catch (e) {
      print('❌ Error getDriverActivities: $e');
      return [];
    }
  }

  // 5. DATA PENDAPATAN 6 BULAN TERAKHIR
  static Future<List<Map<String, dynamic>>> getRevenueData() async {
    try {
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allBookings is String) {
        final bookingsData = json.decode(allBookings)['data'] as List? ?? [];
        
        // Grup berdasarkan bulan
        Map<String, double> monthlyRevenue = {};
        final now = DateTime.now();
        
        // Inisialisasi 6 bulan terakhir
        for (int i = 5; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final monthKey = DateFormat('MMM').format(monthDate);
          monthlyRevenue[monthKey] = 0;
        }
        
        // Hitung revenue per bulan
        for (var booking in bookingsData) {
          final bookingDate = DateTime.tryParse(booking['booking_date'] ?? '');
          if (bookingDate != null) {
            final monthDiff = (now.year - bookingDate.year) * 12 + now.month - bookingDate.month;
            
            if (monthDiff >= 0 && monthDiff < 6) {
              final monthKey = DateFormat('MMM').format(bookingDate);
              final price = double.tryParse(booking['total_price']?.toString() ?? '0') ?? 0;
              monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + price;
            }
          }
        }
        
        // Convert ke list
        return monthlyRevenue.entries.map((entry) {
          return {
            'month': entry.key,
            'revenue': entry.value.toInt(),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getRevenueData: $e');
      return [];
    }
  }

  // HELPER METHODS
  static Future<int> _getTotalCustomers() async {
    print('🔍 Mencari total customers dengan role: customer');
    
    try {
      // GUNAKAN DataService YANG SUDAH ADA (tanpa http langsung)
      final usersData = await DataService().selectWhere(
        token, project, 'user', appid, 'role', 'customer'
      );
      
      print('📊 Response type: ${usersData.runtimeType}');
      
      // DataService.selectWhere() mungkin mengembalikan List langsung
      // Atau Map dengan struktur tertentu
      
      int customerCount = 0;
      
      if (usersData is List) {
        // Jika langsung return List
        customerCount = usersData.length;
        print('👥 Customers (List): $customerCount');
      } else if (usersData is Map) {
        // Jika return Map, cari data di dalamnya
        print('🗺️ Response keys: ${usersData.keys.toList()}');
        
        // Coba berbagai kemungkinan key
        if (usersData.containsKey('data') && usersData['data'] is List) {
          customerCount = (usersData['data'] as List).length;
        } else if (usersData.containsKey('result') && usersData['result'] is List) {
          customerCount = (usersData['result'] as List).length;
        } else if (usersData.containsKey('users') && usersData['users'] is List) {
          customerCount = (usersData['users'] as List).length;
        } else {
          // Hitung semua List dalam Map
          for (var value in usersData.values) {
            if (value is List) {
              customerCount = value.length;
              break;
            }
          }
        }
      } else if (usersData is String) {
        // Jika return String JSON, parse dulu
        try {
          final parsed = json.decode(usersData);
          if (parsed is List) {
            customerCount = parsed.length;
          } else if (parsed is Map && parsed.containsKey('data')) {
            final data = parsed['data'];
            customerCount = data is List ? data.length : 0;
          }
        } catch (e) {
          print('❌ Error parsing String response: $e');
        }
      }
      
      print('✅ Jumlah customers ditemukan: $customerCount');
      
      // Debug: print structure jika ada data
      if (customerCount > 0) {
        print('📋 Struktur data customers:');
        if (usersData is List && usersData.isNotEmpty) {
          print('   Item pertama: ${usersData[0]}');
        } else if (usersData is Map) {
          final firstKey = usersData.keys.firstWhere(
            (k) => usersData[k] is List && (usersData[k] as List).isNotEmpty,
            orElse: () => ''
          );
          if (firstKey.isNotEmpty) {
            final firstList = usersData[firstKey] as List;
            if (firstList.isNotEmpty) {
              print('   Item pertama di key "$firstKey": ${firstList[0]}');
            }
          }
        }
      }
      
      return customerCount;
      
    } catch (e) {
      print('💥 Error di _getTotalCustomers: $e');
      print('💥 Stack trace: ${e.toString()}');
      return 0;
    }
  }

  static Future<int> _getTodayBookings() async {
    try {
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allBookings is String) {
        final decoded = json.decode(allBookings);
        final bookingsData = decoded['data'] as List? ?? [];
        
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayCount = bookingsData.where((b) {
          final bookingDate = b['booking_date']?.toString() ?? '';
          return bookingDate.contains(today);
        }).length;
        
        return todayCount;
      }
      return 0;
    } catch (e) {
      print('Error _getTodayBookings: $e');
      return 0;
    }
  }

  static Future<double> _getMonthlyRevenue() async {
    try {
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allBookings is String) {
        final decoded = json.decode(allBookings);
        final bookingsData = decoded['data'] as List? ?? [];
        
        final now = DateTime.now();
        final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        
        double total = 0;
        for (var booking in bookingsData) {
          final bookingDate = booking['booking_date']?.toString() ?? '';
          if (bookingDate.contains(currentMonth)) {
            final price = booking['total_price']?.toString() ?? '0';
            total += double.tryParse(price) ?? 0;
          }
        }
        
        return total;
      }
      return 0;
    } catch (e) {
      print('Error _getMonthlyRevenue: $e');
      return 0;
    }
  }

  static Future<int> _getPendingBookings() async {
    try {
      final allBookings = await DataService().selectAll(token, project, 'booking', appid);
      
      if (allBookings is String) {
        final decoded = json.decode(allBookings);
        final bookingsData = decoded['data'] as List? ?? [];
        
        final pending = bookingsData.where((b) {
          final status = b['booking_status']?.toString() ?? '';
          return status == 'menunggu' || status == 'pending';
        }).length;
        
        return pending;
      }
      return 0;
    } catch (e) {
      print('Error _getPendingBookings: $e');
      return 0;
    }
  }

  static Future<double> _getAverageRating() async {
    try {
      final allReviews = await DataService().selectAll(token, project, 'review', appid);
      
      if (allReviews is String) {
        final decoded = json.decode(allReviews);
        final reviewsData = decoded['data'] as List? ?? [];
        
        if (reviewsData.isEmpty) return 4.8;
        
        double total = 0;
        int count = 0;
        
        for (var review in reviewsData) {
          final rating = review['rating']?.toString();
          if (rating != null && rating.isNotEmpty) {
            total += double.tryParse(rating) ?? 0;
            count++;
          }
        }
        
        return count > 0 ? total / count : 4.8;
      }
      return 4.8;
    } catch (e) {
      print('Error _getAverageRating: $e');
      return 4.8;
    }
  }
}