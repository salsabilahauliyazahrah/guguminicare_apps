// lib/core/services/address_manager.dart
import 'package:tugas_akhir/core/models/address_model.dart';

class AddressManager {
  static AddressManager? _instance;
  
  // Private constructor
  AddressManager._internal() {
    print('✅ AddressManager instance created');
  }
  
  // Factory constructor
  factory AddressManager() {
    _instance ??= AddressManager._internal();
    return _instance!;
  }
  
  List<AddressModel> _addresses = [];
  
  // 1. Update addresses
  void updateAddresses(List<AddressModel> addresses) {
    _addresses = List.from(addresses);
    print('✅ AddressManager: ${_addresses.length} alamat diupdate');
  }
  
  // 2. Get primary address
  AddressModel? getPrimaryAddress() {
    if (_addresses.isEmpty) {
      print('⚠️ AddressManager: Tidak ada alamat');
      return null;
    }
    
    try {
      final primary = _addresses.firstWhere(
        // ✅ PERBAIKAN: Gunakan getter isUtamaBool
        (address) => address.isUtamaBool,
        orElse: () => _addresses.first,
      );
      print('✅ AddressManager: Alamat utama: ${primary.jenis_alamat}');
      return primary;
    } catch (e) {
      print('❌ AddressManager: Error: $e');
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  
  // 3. Get all addresses
  List<AddressModel> getAllAddresses() {
    return List.from(_addresses);
  }
  
  // 4. Add new address
  void addAddress(AddressModel address) {
    // ✅ PERBAIKAN: Gunakan isUtamaBool untuk cek
    if (address.isUtamaBool) {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(is_utama: '0'); // ✅ Set '0' untuk bukan utama
      }).toList();
    }
    _addresses.add(address);
    print('✅ AddressManager: Alamat ditambahkan: ${address.jenis_alamat}');
  }
  
  // 5. Update specific address
  void updateAddress(AddressModel updatedAddress) {
    final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index != -1) {
      // ✅ PERBAIKAN: Gunakan isUtamaBool untuk cek
      if (updatedAddress.isUtamaBool) {
        _addresses = _addresses.map((addr) {
          return addr.id == updatedAddress.id 
              ? updatedAddress 
              // ✅ Set '0' untuk bukan utama
              : addr.copyWith(is_utama: '0');
        }).toList();
      } else {
        _addresses[index] = updatedAddress;
      }
      print('✅ AddressManager: Alamat diupdate: ${updatedAddress.jenis_alamat}');
    }
  }
    
  // 6. Delete address
  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    print('✅ AddressManager: Alamat dihapus, ID: $id');
  }
  
  // 7. Set primary address
  void setPrimaryAddress(String addressId) {
    _addresses = _addresses.map((address) {
      // ✅ PERBAIKAN: Gunakan copyWith dengan String '1'/'0'
      return address.copyWith(
        is_utama: address.id == addressId ? '1' : '0',
      );
    }).toList();
    print('✅ AddressManager: Alamat utama diubah ke ID: $addressId');
  }

  // 8. Clear all addresses
  void clearAddresses() {
    _addresses.clear();
    print('✅ AddressManager: Semua alamat dihapus');
  }
  
  // 9. Debug: print all addresses
  void printAllAddresses() {
    print('📋 AddressManager: Daftar semua alamat (${_addresses.length}):');
    for (var addr in _addresses) {
      print('  - ${addr.jenis_alamat} (ID: ${addr.id}, Utama: ${addr.isUtamaBool})');
    }
  }
  
  // 10. Get address by ID
  AddressModel? getAddressById(String id) {
    try {
      return _addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 11. Check if has addresses
  bool get hasAddresses => _addresses.isNotEmpty;
  
  // 12. Get addresses count
  int get addressesCount => _addresses.length;
}