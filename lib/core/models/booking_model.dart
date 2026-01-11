// lib/core/models/booking_model.dart
class BookingModel {
  final String id;
  final String booking_code;
  final String user_id;
  final String pet_id;
  final String service_id;
  final String booking_date; // ✅ String bukan DateTime
  final String booking_time;
  final String service_method; // 'salon','home','pickup'
  final String address_id;
  final String driver_id;
  final String special_notes;
  final String total_price; // ✅ String bukan double
  final String additional_fee; // ✅ String bukan double
  final String payment_method; // 'cod','transfer','qris','ewallet'
  final String payment_status; // 'pending','lunas','dibatalkan'
  final String booking_status; // 'menunggu','diproses','selesai','dibatalkan'
  final String created_at; // ✅ String bukan DateTime

  BookingModel({
    required this.id,
    required this.booking_code,
    required this.user_id,
    required this.pet_id,
    required this.service_id,
    required this.booking_date,
    required this.booking_time,
    required this.service_method,
    required this.address_id,
    required this.driver_id,
    required this.special_notes,
    required this.total_price,
    required this.additional_fee,
    required this.payment_method,
    required this.payment_status,
    required this.booking_status,
    required this.created_at,
  });

  // Factory method dengan null safety dan format GoCloud
  factory BookingModel.fromJson(Map<String, dynamic> data) {
    return BookingModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      booking_code: data['booking_code']?.toString() ?? '',
      user_id: data['user_id']?.toString() ?? '',
      pet_id: data['pet_id']?.toString() ?? '',
      service_id: data['service_id']?.toString() ?? '',
      booking_date: data['booking_date']?.toString() ?? '',
      booking_time: data['booking_time']?.toString() ?? '',
      service_method: data['service_method']?.toString() ?? 'salon',
      address_id: data['address_id']?.toString() ?? '',
      driver_id: data['driver_id']?.toString() ?? '',
      special_notes: data['special_notes']?.toString() ?? '',
      total_price: data['total_price']?.toString() ?? '0',
      additional_fee: data['additional_fee']?.toString() ?? '0',
      payment_method: data['payment_method']?.toString() ?? 'cod',
      payment_status: data['payment_status']?.toString() ?? 'pending',
      booking_status: data['booking_status']?.toString() ?? 'menunggu',
      created_at: data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
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
    'created_at': created_at,
  };

  // Helper methods untuk UI convenience (membantu konversi)

  // Konversi total_price ke double untuk perhitungan
  double get totalPriceDouble {
    try {
      return double.parse(total_price);
    } catch (e) {
      return 0.0;
    }
  }

  // Konversi additional_fee ke double
  double get additionalFeeDouble {
    try {
      return double.parse(additional_fee);
    } catch (e) {
      return 0.0;
    }
  }

  // Total harga termasuk additional fee
  double get grandTotal {
    return totalPriceDouble + additionalFeeDouble;
  }

  // Konversi booking_date ke DateTime (optional)
  DateTime? get bookingDateOrNull {
    try {
      return DateTime.parse(booking_date);
    } catch (e) {
      return null;
    }
  }

  // Konversi created_at ke DateTime
  DateTime? get createdAtOrNull {
    try {
      return DateTime.parse(created_at);
    } catch (e) {
      return null;
    }
  }

  // Formatted date untuk display
  String get formattedBookingDate {
    final date = bookingDateOrNull;
    if (date == null) return booking_date;
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  // Formatted time untuk display
  String get formattedBookingTime {
    return booking_time;
  }

  // Helper untuk status booking
  bool get isPending => booking_status == 'menunggu';
  bool get isProcessing => booking_status == 'diproses';
  bool get isCompleted => booking_status == 'selesai';
  bool get isCancelled => booking_status == 'dibatalkan';

  // Helper untuk status pembayaran
  bool get isPaymentPending => payment_status == 'pending';
  bool get isPaymentPaid => payment_status == 'lunas';
  bool get isPaymentCancelled => payment_status == 'dibatalkan';

  // Helper untuk service method
  String get serviceMethodLabel {
    switch (service_method) {
      case 'salon': return 'Datang ke Salon';
      case 'home': return 'Home Service';
      case 'pickup': return 'Pickup Service';
      default: return service_method;
    }
  }

  // Helper untuk payment method
  String get paymentMethodLabel {
    switch (payment_method) {
      case 'cod': return 'Cash on Delivery';
      case 'transfer': return 'Transfer Bank';
      case 'qris': return 'QRIS';
      case 'ewallet': return 'E-Wallet';
      default: return payment_method;
    }
  }

  // Copy with method (tetap dalam format String)
  BookingModel copyWith({
    String? id,
    String? booking_code,
    String? user_id,
    String? pet_id,
    String? service_id,
    String? booking_date,
    String? booking_time,
    String? service_method,
    String? address_id,
    String? driver_id,
    String? special_notes,
    String? total_price,
    String? additional_fee,
    String? payment_method,
    String? payment_status,
    String? booking_status,
    String? created_at,
  }) {
    return BookingModel(
      id: id ?? this.id,
      booking_code: booking_code ?? this.booking_code,
      user_id: user_id ?? this.user_id,
      pet_id: pet_id ?? this.pet_id,
      service_id: service_id ?? this.service_id,
      booking_date: booking_date ?? this.booking_date,
      booking_time: booking_time ?? this.booking_time,
      service_method: service_method ?? this.service_method,
      address_id: address_id ?? this.address_id,
      driver_id: driver_id ?? this.driver_id,
      special_notes: special_notes ?? this.special_notes,
      total_price: total_price ?? this.total_price,
      additional_fee: additional_fee ?? this.additional_fee,
      payment_method: payment_method ?? this.payment_method,
      payment_status: payment_status ?? this.payment_status,
      booking_status: booking_status ?? this.booking_status,
      created_at: created_at ?? this.created_at,
    );
  }

  // Method untuk update status
  BookingModel updateStatus(String newStatus) {
    return copyWith(booking_status: newStatus);
  }

  BookingModel updatePaymentStatus(String newPaymentStatus) {
    return copyWith(payment_status: newPaymentStatus);
  }

  // Static method untuk create new booking
  static BookingModel createNew({
    required String user_id,
    required String pet_id,
    required String service_id,
    required String booking_date,
    required String booking_time,
    required String service_method,
    required String total_price,
    String booking_code = '',
    String address_id = '',
    String driver_id = '',
    String special_notes = '',
    String additional_fee = '0',
    String payment_method = 'cod',
    String payment_status = 'pending',
    String booking_status = 'menunggu',
  }) {
    // Generate booking code jika kosong
    final code = booking_code.isEmpty 
        ? 'BK${DateTime.now().millisecondsSinceEpoch}'
        : booking_code;

    return BookingModel(
      id: '', // Empty untuk insert baru
      booking_code: code,
      user_id: user_id,
      pet_id: pet_id,
      service_id: service_id,
      booking_date: booking_date,
      booking_time: booking_time,
      service_method: service_method,
      address_id: address_id,
      driver_id: driver_id,
      special_notes: special_notes,
      total_price: total_price,
      additional_fee: additional_fee,
      payment_method: payment_method,
      payment_status: payment_status,
      booking_status: booking_status,
      created_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk validasi booking
  bool get isValid {
    return user_id.isNotEmpty &&
           pet_id.isNotEmpty &&
           service_id.isNotEmpty &&
           booking_date.isNotEmpty &&
           booking_time.isNotEmpty &&
           total_price.isNotEmpty;
  }

  @override
  String toString() {
    return 'Booking $booking_code - $booking_status ($formattedBookingDate $booking_time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel &&
        other.id == id &&
        other.booking_code == booking_code;
  }

  @override
  int get hashCode {
    return id.hashCode ^ booking_code.hashCode;
  }
}