// lib/core/models/salon_setting_model.dart
import 'dart:convert';

class SalonSettingModel {
  final String id;
  final String salon_id;
  final String salon_name;
  final String salon_address;
  final String salon_phone;
  final String salon_email;
  final String salon_website;
  final String business_hours; // JSON string
  final String notifications_enabled;
  final String email_notifications;
  final String sms_notifications;
  final String auto_confirm_booking;
  final String require_deposit;
  final String deposit_percentage;
  final String salon_service_enabled;
  final String home_service_enabled;
  final String pickup_service_enabled;
  final String pickup_service_fee;
  final String cod_enabled;
  final String bank_transfer_enabled;
  final String qris_enabled;
  final String ewallet_enabled;
  final String created_at;
  final String updated_at;

  SalonSettingModel({
    required this.id,
    required this.salon_id,
    required this.salon_name,
    required this.salon_address,
    required this.salon_phone,
    required this.salon_email,
    required this.salon_website,
    required this.business_hours,
    required this.notifications_enabled,
    required this.email_notifications,
    required this.sms_notifications,
    required this.auto_confirm_booking,
    required this.require_deposit,
    required this.deposit_percentage,
    required this.salon_service_enabled,
    required this.home_service_enabled,
    required this.pickup_service_enabled,
    required this.pickup_service_fee,
    required this.cod_enabled,
    required this.bank_transfer_enabled,
    required this.qris_enabled,
    required this.ewallet_enabled,
    required this.created_at,
    required this.updated_at,
  });

  factory SalonSettingModel.fromJson(Map<String, dynamic> json) {
    return SalonSettingModel(
      id: json['_id']?.toString() ?? '',
      salon_id: json['salon_id']?.toString() ?? '',
      salon_name: json['salon_name']?.toString() ?? '',
      salon_address: json['salon_address']?.toString() ?? '',
      salon_phone: json['salon_phone']?.toString() ?? '',
      salon_email: json['salon_email']?.toString() ?? '',
      salon_website: json['salon_website']?.toString() ?? '',
      business_hours: json['business_hours']?.toString() ?? '{}',
      notifications_enabled: json['notifications_enabled']?.toString() ?? 'true',
      email_notifications: json['email_notifications']?.toString() ?? 'true',
      sms_notifications: json['sms_notifications']?.toString() ?? 'false',
      auto_confirm_booking: json['auto_confirm_booking']?.toString() ?? 'false',
      require_deposit: json['require_deposit']?.toString() ?? 'false',
      deposit_percentage: json['deposit_percentage']?.toString() ?? '20.0',
      salon_service_enabled: json['salon_service_enabled']?.toString() ?? 'true',
      home_service_enabled: json['home_service_enabled']?.toString() ?? 'true',
      pickup_service_enabled: json['pickup_service_enabled']?.toString() ?? 'true',
      pickup_service_fee: json['pickup_service_fee']?.toString() ?? '25000',
      cod_enabled: json['cod_enabled']?.toString() ?? 'true',
      bank_transfer_enabled: json['bank_transfer_enabled']?.toString() ?? 'true',
      qris_enabled: json['qris_enabled']?.toString() ?? 'true',
      ewallet_enabled: json['ewallet_enabled']?.toString() ?? 'true',
      created_at: json['created_at']?.toString() ?? '',
      updated_at: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
      'updated_at': updated_at,
    };
  }

  // Helper getters untuk UI (optional)
  bool get isNotificationsEnabled => 
      notifications_enabled == '1' || notifications_enabled.toLowerCase() == 'true';
  
  bool get isEmailNotifications => 
      email_notifications == '1' || email_notifications.toLowerCase() == 'true';
  
  bool get isSmsNotifications => 
      sms_notifications == '1' || sms_notifications.toLowerCase() == 'true';
  
  bool get isAutoConfirmBooking => 
      auto_confirm_booking == '1' || auto_confirm_booking.toLowerCase() == 'true';
  
  bool get isRequireDeposit => 
      require_deposit == '1' || require_deposit.toLowerCase() == 'true';
  
  double get depositPercentageDouble => 
      double.tryParse(deposit_percentage) ?? 20.0;
  
  double get pickupServiceFeeDouble => 
      double.tryParse(pickup_service_fee) ?? 25000.0;
  
  Map<String, dynamic>? get businessHoursMap {
    try {
      return json.decode(business_hours);
    } catch (e) {
      return null;
    }
  }

  // CopyWith method (tetap snake_case)
  SalonSettingModel copyWith({
    String? id,
    String? salon_id,
    String? salon_name,
    String? salon_address,
    String? salon_phone,
    String? salon_email,
    String? salon_website,
    String? business_hours,
    String? notifications_enabled,
    String? email_notifications,
    String? sms_notifications,
    String? auto_confirm_booking,
    String? require_deposit,
    String? deposit_percentage,
    String? salon_service_enabled,
    String? home_service_enabled,
    String? pickup_service_enabled,
    String? pickup_service_fee,
    String? cod_enabled,
    String? bank_transfer_enabled,
    String? qris_enabled,
    String? ewallet_enabled,
    String? created_at,
    String? updated_at,
  }) {
    return SalonSettingModel(
      id: id ?? this.id,
      salon_id: salon_id ?? this.salon_id,
      salon_name: salon_name ?? this.salon_name,
      salon_address: salon_address ?? this.salon_address,
      salon_phone: salon_phone ?? this.salon_phone,
      salon_email: salon_email ?? this.salon_email,
      salon_website: salon_website ?? this.salon_website,
      business_hours: business_hours ?? this.business_hours,
      notifications_enabled: notifications_enabled ?? this.notifications_enabled,
      email_notifications: email_notifications ?? this.email_notifications,
      sms_notifications: sms_notifications ?? this.sms_notifications,
      auto_confirm_booking: auto_confirm_booking ?? this.auto_confirm_booking,
      require_deposit: require_deposit ?? this.require_deposit,
      deposit_percentage: deposit_percentage ?? this.deposit_percentage,
      salon_service_enabled: salon_service_enabled ?? this.salon_service_enabled,
      home_service_enabled: home_service_enabled ?? this.home_service_enabled,
      pickup_service_enabled: pickup_service_enabled ?? this.pickup_service_enabled,
      pickup_service_fee: pickup_service_fee ?? this.pickup_service_fee,
      cod_enabled: cod_enabled ?? this.cod_enabled,
      bank_transfer_enabled: bank_transfer_enabled ?? this.bank_transfer_enabled,
      qris_enabled: qris_enabled ?? this.qris_enabled,
      ewallet_enabled: ewallet_enabled ?? this.ewallet_enabled,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }
}