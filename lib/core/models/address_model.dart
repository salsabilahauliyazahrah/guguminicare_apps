// lib/core/models/address_model.dart
class AddressModel {
  final String id;
  final String userid; // ✅ snake_case, sesuai database
  final String jenis_alamat; // ✅ snake_case
  final String alamat_lengkap; // ✅ snake_case
  final String kota;
  final String is_utama; // ✅ String bukan bool, snake_case
  final String catatan;
  final String kode_pos; // ✅ snake_case
  final String created_at; // ✅ String bukan DateTime, snake_case

  AddressModel({
    required this.id,
    required this.userid,
    required this.jenis_alamat,
    required this.alamat_lengkap,
    required this.kota,
    required this.is_utama,
    required this.catatan,
    required this.kode_pos,
    required this.created_at,
  });

  // Factory method dengan null safety
  factory AddressModel.fromJson(Map<String, dynamic> data) {
    return AddressModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      userid: data['userid']?.toString() ?? '',
      jenis_alamat: data['jenis_alamat']?.toString() ?? '',
      alamat_lengkap: data['alamat_lengkap']?.toString() ?? '',
      kota: data['kota']?.toString() ?? '',
      is_utama: data['is_utama']?.toString() ?? '0', // '1' untuk true, '0' untuk false
      catatan: data['catatan']?.toString() ?? '',
      kode_pos: data['kode_pos']?.toString() ?? '',
      created_at: data['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON untuk API
  Map<String, dynamic> toJson() => {
    '_id': id.isEmpty ? null : id, // Untuk insert, ID null karena auto-generate
    'id': id.isEmpty ? null : id,
    'userid': userid,
    'jenis_alamat': jenis_alamat,
    'alamat_lengkap': alamat_lengkap,
    'kota': kota,
    'is_utama': is_utama,
    'catatan': catatan,
    'kode_pos': kode_pos,
    'created_at': created_at,
  };

  // Helper methods untuk UI convenience

  // Getter untuk cek apakah alamat utama (String '1' = true)
  bool get isUtamaBool => is_utama == '1' || is_utama == 'true';

  // Getter untuk format tampilan
  String get label => jenis_alamat;

  // Getter untuk alamat lengkap
  String get fullAddress => '$alamat_lengkap, $kota $kode_pos';

  // Getter untuk catatan (bisa kosong)
  String? get notes => catatan.isNotEmpty ? catatan : null;

  // Getter untuk tanggal created (optional parsing)
  DateTime? get createdAtOrNull {
    try {
      return DateTime.parse(created_at);
    } catch (e) {
      return null;
    }
  }

  // Method untuk membuat salinan dengan perubahan
  AddressModel copyWith({
    String? id,
    String? userid,
    String? jenis_alamat,
    String? alamat_lengkap,
    String? kota,
    String? is_utama,
    String? catatan,
    String? kode_pos,
    String? created_at,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userid: userid ?? this.userid,
      jenis_alamat: jenis_alamat ?? this.jenis_alamat,
      alamat_lengkap: alamat_lengkap ?? this.alamat_lengkap,
      kota: kota ?? this.kota,
      is_utama: is_utama ?? this.is_utama,
      catatan: catatan ?? this.catatan,
      kode_pos: kode_pos ?? this.kode_pos,
      created_at: created_at ?? this.created_at,
    );
  }

  // Method untuk set sebagai alamat utama
  AddressModel setAsPrimary() {
    return copyWith(is_utama: '1');
  }

  // Method untuk set sebagai bukan alamat utama
  AddressModel setAsNotPrimary() {
    return copyWith(is_utama: '0');
  }

  // Method untuk validasi data
  bool get isValid {
    return userid.isNotEmpty &&
           alamat_lengkap.isNotEmpty &&
           kota.isNotEmpty &&
           kode_pos.isNotEmpty;
  }

  // Static method untuk create new address
  static AddressModel createNew({
    required String userid,
    required String alamat_lengkap,
    required String kota,
    required String kode_pos,
    String jenis_alamat = 'Rumah',
    String catatan = '',
    bool isUtama = false,
  }) {
    return AddressModel(
      id: '', // Empty untuk insert baru
      userid: userid,
      jenis_alamat: jenis_alamat,
      alamat_lengkap: alamat_lengkap,
      kota: kota,
      is_utama: isUtama ? '1' : '0',
      catatan: catatan,
      kode_pos: kode_pos,
      created_at: DateTime.now().toIso8601String(),
    );
  }

  // Method untuk format tampilan singkat
  @override
  String toString() {
    return '$jenis_alamat: $alamat_lengkap, $kota';
  }

  // Method untuk comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.id == id &&
        other.userid == userid &&
        other.alamat_lengkap == alamat_lengkap;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userid.hashCode ^ alamat_lengkap.hashCode;
  }
}