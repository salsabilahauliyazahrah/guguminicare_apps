// lib/presentation/screens/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/core/models/review_model.dart';

class ReviewService {
  // ============ KONFIGURASI API 247GO ============
  static const String _baseUrl = 'https://api.247go.app/v5/';
  static const String _token = '68f2ede325bcf6243d214a05';
  static const String _project = 'gugumicare';
  static const String _appId = '695d6cfd045a4b3d08976d16';

  // ============ GET ALL REVIEWS ============
  Future<List<ReviewModel>> getAllReviews() async {
    print('⭐ Mengambil semua reviews');
    
    final url = '${_baseUrl}select_all/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
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
        
        print('📊 Jumlah reviews ditemukan: ${rawData.length}');
        
        final List<ReviewModel> reviews = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> reviewMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final review = ReviewModel.fromJson(reviewMap);
            reviews.add(review);
          } catch (e) {
            print('⚠️ Error parsing review: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        reviews.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return reviews;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil all reviews: $e');
      throw Exception('Gagal mengambil data reviews: $e');
    }
  }

  // ============ GET REVIEWS BY USER ID ============
  Future<List<ReviewModel>> getReviewsByUserId(String userId) async {
    print('⭐ Mengambil reviews untuk user: $userId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
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
        
        print('📊 Jumlah reviews ditemukan: ${rawData.length}');
        
        final List<ReviewModel> reviews = [];
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> reviewMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final review = ReviewModel.fromJson(reviewMap);
            reviews.add(review);
            
            print('✅ Loaded: ${review.rating} stars - ${review.commentPreview}');
          } catch (e) {
            print('⚠️ Error parsing review: $e');
          }
        }
        
        // Urutkan berdasarkan tanggal (terbaru duluan)
        reviews.sort((a, b) {
          final dateA = a.created_at;
          final dateB = b.created_at;
          return dateB.compareTo(dateA);
        });
        
        return reviews;
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error mengambil reviews: $e');
      throw Exception('Gagal mengambil data reviews: $e');
    }
  }

  // ============ GET REVIEWS BY BOOKING ID ============
  Future<List<ReviewModel>> getReviewsByBookingId(String bookingId) async {
    print('📋 Mengambil reviews untuk booking: $bookingId');
    
    final url = '${_baseUrl}select_where/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
          'appid': _appId,
          'where_field': 'booking_id',
          'where_value': bookingId,
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
          final Map<String, dynamic> reviewMap = item is Map<String, dynamic> 
              ? item 
              : Map<String, dynamic>.from(item as Map);
          return ReviewModel.fromJson(reviewMap);
        }).toList();
      }
      
      throw Exception('Failed to get reviews');
    } catch (e) {
      print('💥 Error getting reviews by booking: $e');
      rethrow;
    }
  }

  // ============ CREATE NEW REVIEW ============
  Future<ReviewModel> createReview(ReviewModel review) async {
    print('➕ Membuat review baru untuk booking: ${review.booking_id}');
    
    final url = '${_baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': _token,
        'project': _project,
        'collection': 'review',
        'appid': _appId,
        'booking_id': review.booking_id,
        'user_id': review.user_id,
        'rating': review.rating,
        'comment': review.comment,
        'is_responded': review.is_responded,
        'response_admin': review.response_admin,
        'response_date': review.response_date,
        'created_at': review.created_at,
      };
      
      print('📋 Review Data:');
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
          
          print('✅ Review created with ID: $newId');
          return review.copyWith(id: newId);
        } else if (responseData is Map && responseData['status'] == '1') {
          return review;
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error creating review: $e');
      rethrow;
    }
  }

  // ============ ADD ADMIN RESPONSE ============
  Future<void> addAdminResponse({
    required String reviewId,
    required String adminName,
    required String response,
  }) async {
    print('💬 Add admin response to review: $reviewId');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final updateData = {
        'is_responded': '1',
        'response_admin': '$adminName: $response',
        'response_date': DateTime.now().toIso8601String(),
      };
      
      final responseHttp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
          'appid': _appId,
          'id': reviewId,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      print('📡 Update Response: ${responseHttp.statusCode}');
      
      if (responseHttp.statusCode == 200) {
        print('✅ Admin response added');
      } else {
        throw Exception('Add response failed: ${responseHttp.statusCode}');
      }
    } catch (e) {
      print('💥 Error adding admin response: $e');
      rethrow;
    }
  }

  // ============ UPDATE REVIEW ============
  Future<void> updateReview(ReviewModel review) async {
    print('✏️ Update review: ${review.id}');
    
    final url = '${_baseUrl}update_id/';
    
    try {
      final updateData = {
        'rating': review.rating,
        'comment': review.comment,
        'is_responded': review.is_responded,
        'response_admin': review.response_admin,
        'response_date': review.response_date,
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
          'appid': _appId,
          'id': review.id,
          'update_field': 'data',
          'update_value': jsonEncode(updateData),
        },
      );
      
      print('📡 Update Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Review updated');
      } else {
        throw Exception('Update failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating review: $e');
      rethrow;
    }
  }

  // ============ DELETE REVIEW ============
  Future<void> deleteReview(String reviewId) async {
    print('🗑️ Delete review: $reviewId');
    
    final url = '${_baseUrl}remove_id/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
          'appid': _appId,
          'id': reviewId,
        },
      );
      
      print('📡 Delete Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Review deleted');
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error deleting review: $e');
      rethrow;
    }
  }

  // ============ GET AVERAGE RATING ============
  Future<double> getAverageRating(String salonId) async {
    print('📊 Getting average rating for salon: $salonId');
    
    try {
      // Get all reviews (this might need optimization for large datasets)
      final url = '${_baseUrl}select_all/';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': _token,
          'project': _project,
          'collection': 'review',
          'appid': _appId,
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
        
        if (rawData.isEmpty) return 0.0;
        
        double total = 0;
        int count = 0;
        
        for (var item in rawData) {
          try {
            final Map<String, dynamic> reviewMap = item is Map<String, dynamic> 
                ? item 
                : Map<String, dynamic>.from(item as Map);
            
            final ratingStr = reviewMap['rating']?.toString() ?? '0';
            final rating = double.tryParse(ratingStr) ?? 0.0;
            
            total += rating;
            count++;
          } catch (e) {
            print('⚠️ Error calculating rating: $e');
          }
        }
        
        final average = count > 0 ? total / count : 0.0;
        print('✅ Average rating: $average ($count reviews)');
        return double.parse(average.toStringAsFixed(1));
      }
      
      return 0.0;
    } catch (e) {
      print('💥 Error getting average rating: $e');
      return 0.0;
    }
  }

  // ============ GET REVIEW STATISTICS ============
  Future<Map<String, dynamic>> getReviewStats(String salonId) async {
    try {
      final reviews = await getReviewsByUserId(salonId); // Adjust as needed
      
      final totalReviews = reviews.length;
      final averageRating = reviews.isEmpty 
          ? 0.0 
          : reviews.map((r) => r.ratingDouble).reduce((a, b) => a + b) / totalReviews;
      
      final starCounts = {
        '5': reviews.where((r) => r.ratingDouble >= 4.5).length,
        '4': reviews.where((r) => r.ratingDouble >= 3.5 && r.ratingDouble < 4.5).length,
        '3': reviews.where((r) => r.ratingDouble >= 2.5 && r.ratingDouble < 3.5).length,
        '2': reviews.where((r) => r.ratingDouble >= 1.5 && r.ratingDouble < 2.5).length,
        '1': reviews.where((r) => r.ratingDouble < 1.5).length,
      };
      
      final respondedCount = reviews.where((r) => r.isRespondedBool).length;
      
      return {
        'total_reviews': totalReviews,
        'average_rating': double.parse(averageRating.toStringAsFixed(1)),
        'star_counts': starCounts,
        'responded_count': respondedCount,
        'response_rate': totalReviews > 0 ? (respondedCount / totalReviews * 100).toStringAsFixed(1) : '0',
        'has_reviews': totalReviews > 0,
      };
    } catch (e) {
      print('💥 Error getting review stats: $e');
      return {
        'total_reviews': 0,
        'average_rating': 0.0,
        'star_counts': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
        'responded_count': 0,
        'response_rate': '0',
        'has_reviews': false,
      };
    }
  }
}