// lib/core/models/report_model.dart
import 'dart:convert';

class ReportModel {
  final String id;
  final String salon_id;
  final String report_type; // 'pendapatan','service','customer','driver'
  final String period; // 'harian','mingguan','bulanan','tahunan'
  final String data; // ✅ String bukan dynamic (JSON string)
  final String generated_by; // ✅ sesuai field name di GoCloud
  final String generated_at; // ✅ String bukan DateTime

  ReportModel({
    required this.id,
    required this.salon_id,
    required this.report_type,
    required this.period,
    required this.data,
    required this.generated_by,
    required this.generated_at,
  });

  // Factory method dengan null safety dan format GoCloud
  factory ReportModel.fromJson(Map<String, dynamic> data) {
    return ReportModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      salon_id: data['salon_id']?.toString() ?? '',
      report_type: data['report_type']?.toString() ?? '',
      period: data['period']?.toString() ?? '',
      data: data['data']?.toString() ?? '',
      generated_by: data['generated_by']?.toString() ?? '',
      generated_at: data['generated_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API (sesuai format GoCloud)
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert baru, biarkan null
    'id': id.isEmpty ? null : id,
    'salon_id': salon_id,
    'report_type': report_type,
    'period': period,
    'data': data,
    'generated_by': generated_by,
    'generated_at': generated_at,
  };

  // Helper methods untuk UI convenience

  // Konversi data dari String ke Map (jika berupa JSON)
  Map<String, dynamic>? get dataMap {
    if (data.isEmpty) return null;
    try {
      return json.decode(data);
    } catch (e) {
      return null;
    }
  }

  // Konversi data dari String ke List (jika berupa JSON array)
  List<dynamic>? get dataList {
    if (data.isEmpty) return null;
    try {
      final decoded = json.decode(data);
      return decoded is List ? decoded : null;
    } catch (e) {
      return null;
    }
  }

  // Konversi generated_at ke DateTime
  DateTime? get generatedAtOrNull {
    try {
      return DateTime.parse(generated_at);
    } catch (e) {
      return null;
    }
  }

  // Formatted date untuk display
  String get formattedGeneratedAt {
    final date = generatedAtOrNull;
    if (date == null) return '';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }

  // Get report type label untuk display
  String get reportTypeLabel {
    switch (report_type) {
      case 'pendapatan':
        return 'Laporan Pendapatan';
      case 'service':
        return 'Laporan Layanan';
      case 'customer':
        return 'Laporan Pelanggan';
      case 'driver':
        return 'Laporan Driver';
      case 'booking':
        return 'Laporan Booking';
      default:
        return 'Laporan $report_type';
    }
  }

  // Get period label untuk display
  String get periodLabel {
    switch (period) {
      case 'harian':
        return 'Harian';
      case 'mingguan':
        return 'Mingguan';
      case 'bulanan':
        return 'Bulanan';
      case 'tahunan':
        return 'Tahunan';
      case 'custom':
        return 'Custom';
      default:
        return period;
    }
  }

  // Get icon berdasarkan report type
  String get reportIcon {
    switch (report_type) {
      case 'pendapatan':
        return '💰';
      case 'service':
        return '✂️';
      case 'customer':
        return '👥';
      case 'driver':
        return '🚗';
      case 'booking':
        return '📅';
      default:
        return '📊';
    }
  }

  // Get color berdasarkan report type
  String get reportColor {
    switch (report_type) {
      case 'pendapatan':
        return '#4CAF50'; // Green
      case 'service':
        return '#2196F3'; // Blue
      case 'customer':
        return '#9C27B0'; // Purple
      case 'driver':
        return '#FF9800'; // Orange
      case 'booking':
        return '#F44336'; // Red
      default:
        return '#607D8B'; // Grey
    }
  }

  // Method untuk mendapatkan summary data
  Map<String, dynamic>? get summary {
    final mapData = dataMap;
    if (mapData == null) return null;

    // Coba ambil field yang umum untuk summary
    if (report_type == 'pendapatan') {
      return {
        'total_pendapatan': mapData['total_pendapatan'] ?? '0',
        'jumlah_transaksi': mapData['jumlah_transaksi'] ?? '0',
        'rata_rata': mapData['rata_rata'] ?? '0',
      };
    } else if (report_type == 'service') {
      return {
        'total_service': mapData['total_service'] ?? '0',
        'service_terpopuler': mapData['service_terpopuler'] ?? '-',
        'total_pendapatan': mapData['total_pendapatan'] ?? '0',
      };
    } else if (report_type == 'customer') {
      return {
        'total_customer': mapData['total_customer'] ?? '0',
        'customer_baru': mapData['customer_baru'] ?? '0',
        'customer_aktif': mapData['customer_aktif'] ?? '0',
      };
    }
    
    return mapData;
  }

  // Copy with method (tetap dalam format String)
  ReportModel copyWith({
    String? id,
    String? salon_id,
    String? report_type,
    String? period,
    String? data,
    String? generated_by,
    String? generated_at,
  }) {
    return ReportModel(
      id: id ?? this.id,
      salon_id: salon_id ?? this.salon_id,
      report_type: report_type ?? this.report_type,
      period: period ?? this.period,
      data: data ?? this.data,
      generated_by: generated_by ?? this.generated_by,
      generated_at: generated_at ?? this.generated_at,
    );
  }

  // Static method untuk create new report
  static ReportModel createNew({
    required String salon_id,
    required String report_type,
    required String period,
    required dynamic data,
    required String generated_by,
  }) {
    // Convert data to JSON string jika bukan string
    String dataString;
    if (data is String) {
      dataString = data;
    } else {
      dataString = json.encode(data);
    }

    return ReportModel(
      id: '', // Empty untuk insert baru
      salon_id: salon_id,
      report_type: report_type,
      period: period,
      data: dataString,
      generated_by: generated_by,
      generated_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk validasi report
  bool get isValid {
    return salon_id.isNotEmpty &&
           report_type.isNotEmpty &&
           period.isNotEmpty &&
           data.isNotEmpty &&
           generated_by.isNotEmpty;
  }

  // Method untuk mendapatkan file name
  String get fileName {
    final date = DateTime.now();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    
    return '${report_type}_${period}_$day$month$year.json';
  }

  // Method untuk export ke berbagai format
  Map<String, dynamic> exportToFormat(String format) {
    switch (format) {
      case 'json':
        return {'data': dataMap ?? {}};
      case 'csv':
        // Implement CSV conversion logic here
        return {'csv': 'CSV data would be generated here'};
      case 'pdf':
        return {'pdf': 'PDF data would be generated here'};
      default:
        return {'data': dataMap ?? {}};
    }
  }

  @override
  String toString() {
    return '$reportTypeLabel ($periodLabel) - $formattedGeneratedAt';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel &&
        other.id == id &&
        other.salon_id == salon_id &&
        other.generated_at == generated_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^ salon_id.hashCode ^ generated_at.hashCode;
  }
}