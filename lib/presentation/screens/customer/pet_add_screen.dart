import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final PetService _petService = PetService();

  bool _isLoading = false;

  // Data form
  String _name = '';
  String _type = 'Kucing'; // Default value
  String _breed = '';
  int _age = 1;
  double _weight = 1.0;
  // ignore: unused_field
  String _medicalNotes = '';
  bool _isSafe = true;
  XFile? _selectedImage;
  File? _imageFile;

  // CATATAN MEDIS UNTUK GROOMING (4 field terpisah)
  // ignore: unused_field
  String _specialCondition = '';
  // ignore: unused_field
  String _currentMedication = '';
  // ignore: unused_field
  String _groomingBehavior = '';
  // ignore: unused_field
  String _additionalNotes = '';

  // List untuk dropdown
  final List<String> _petTypes = ['Kucing', 'Anjing', 'Kelinci'];
  final Map<String, List<String>> _breedsByType = {
    'Kucing': [
      'Persia',
      'Anggora',
      'Siam',
      'Domestik',
      'British Shorthair',
      'Maine Coon'
    ],
    'Anjing': [
      'Golden Retriever',
      'Poodle',
      'Bulldog',
      'Chihuahua',
      'Husky',
      'Beagle'
    ],
    'Kelinci': ['Holland Lop', 'Netherland Dwarf', 'Flemish Giant'],
  };

  @override
  void initState() {
    super.initState();
    // Set breed awal berdasarkan type default
    if (_breedsByType[_type] != null && _breedsByType[_type]!.isNotEmpty) {
      _breed = _breedsByType[_type]!.first;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      // Tampilkan pesan error ke pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error taking photo: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // ============ PERBAIKAN 1: AMBIL USER_ID DENGAN BENAR ============
      // GANTI INI:
      // final userData = StorageHelper.getJson('user');
      // final userId = userData?['id']?.toString();
      
      // MENJADI INI:
      final userId = StorageHelper.getString('user_id');
      
      print('🔍 Checking user_id from storage: "$userId"');
      
      // Debug: print semua storage
      final allKeys = StorageHelper.getKeys();
      print('📋 All storage keys: $allKeys');
      for (var key in allKeys) {
        print('  "$key": ${StorageHelper.getString(key)}');
      }
      // ================================================================

      if (userId == null || userId.isEmpty) {
        print('❌ ERROR: user_id not found!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal: User tidak ditemukan. Silakan login ulang.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('✅ User ID found: $userId');
      
      setState(() {
        _isLoading = true;
      });

      try {
        // ============ PERBAIKAN 2: SESUAIKAN DENGAN PetModel ============
        // PetModel mengharapkan String? untuk age dan weight
        // is_safe juga String? (bukan bool)
        
        // Convert int/double ke String untuk PetModel
        final String? ageString = _age.toString(); // int -> String
        final String? weightString = _weight.toString(); // double -> String
        final String isSafeString = _isSafe.toString(); // bool -> String ("true"/"false")
        
        // Buat PetModel baru sesuai dengan model yang ada
        final newPet = PetModel(
          id: '', // ID akan di-generate oleh database
          user_id: userId,
          name: _name,
          type: _type,
          breed: _breed,
          age: ageString,           // ✅ String?, bukan int
          weight: weightString,     // ✅ String?, bukan double
          photo: _selectedImage?.path ?? '',
          is_safe: isSafeString,    // ✅ String?, bukan bool
          last_grooming: null,
          created_at: DateTime.now().toIso8601String(),
        );

        print('📝 Pet data to create:');
        print('  name: ${newPet.name}');
        print('  user_id: ${newPet.user_id}');
        print('  type: ${newPet.type}');
        print('  breed: ${newPet.breed}');
        print('  age: ${newPet.age} (type: ${newPet.age.runtimeType})');
        print('  weight: ${newPet.weight} (type: ${newPet.weight.runtimeType})');
        print('  is_safe: ${newPet.is_safe} (type: ${newPet.is_safe.runtimeType})');

        // Simpan ke database
        await _petService.createPet(newPet);

        setState(() {
          _isLoading = false;
        });

        // Tampilkan snackbar sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_name berhasil ditambahkan!'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Kembali ke halaman pets dengan result true untuk refresh
        if (mounted) {
          context.pop(true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        print('❌ Error creating pet: $e');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan hewan: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tambah Hewan Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _submitForm,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.check,
                      color: AppColors.primary,
                    ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Upload Foto
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload Foto',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Nama
                    _buildFormField(
                      label: 'Nama Hewan *',
                      hintText: 'Contoh: Milo',
                      icon: Icons.pets,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama hewan harus diisi';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Jenis Hewan
                    _buildDropdownField(
                      label: 'Jenis Hewan *',
                      value: _type,
                      items: _petTypes,
                      icon: Icons.category,
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                          // Reset breed sesuai jenis hewan yang dipilih
                          if (_breedsByType[_type] != null &&
                              _breedsByType[_type]!.isNotEmpty) {
                            _breed = _breedsByType[_type]!.first;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Ras
                    _buildDropdownField(
                      label: 'Ras *',
                      value: _breed,
                      items: _breedsByType[_type] ?? ['Tidak diketahui'],
                      icon: Icons.straighten,
                      onChanged: (value) {
                        setState(() {
                          _breed = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Umur
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Umur (tahun) *',
                            hintText: '1',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Umur harus diisi';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age <= 0) {
                                return 'Umur harus angka positif';
                              }
                              return null;
                            },
                            onSaved: (value) => _age = int.parse(value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            label: 'Berat (kg) *',
                            hintText: '4.5',
                            icon: Icons.monitor_weight,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Berat harus diisi';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                return 'Berat harus angka positif';
                              }
                              return null;
                            },
                            onSaved: (value) => _weight = double.parse(value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bagian Catatan Medis untuk Grooming
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Catatan Medis untuk Grooming',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 1,
                                  width: 100,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Kondisi Khusus
                          _buildGroomingNoteField(
                            label: 'Kondisi Khusus',
                            hintText:
                                'Contoh: kulit sensitif, alergi shampoo, arthritis',
                            icon: Icons.health_and_safety,
                            maxLines: 2,
                            onSaved: (value) => _specialCondition = value ?? '',
                          ),
                          const SizedBox(height: 16),

                          // Obat yang Sedang Dikonsumsi
                          _buildGroomingNoteField(
                            label: 'Obat yang Sedang Dikonsumsi',
                            hintText: 'Contoh: Antibiotik - 2x sehari',
                            icon: Icons.medication,
                            maxLines: 2,
                            onSaved: (value) =>
                                _currentMedication = value ?? '',
                          ),
                          const SizedBox(height: 16),

                          // Perilaku selama Grooming
                          _buildGroomingNoteField(
                            label: 'Perilaku selama Grooming',
                            hintText:
                                'Contoh: tidak suka suara clipper, takut mandi',
                            icon: Icons.psychology,
                            maxLines: 2,
                            onSaved: (value) => _groomingBehavior = value ?? '',
                          ),
                          const SizedBox(height: 16),

                          // Catatan Tambahan
                          _buildGroomingNoteField(
                            label: 'Catatan Tambahan',
                            hintText: 'Catatan lain yang perlu diperhatikan',
                            icon: Icons.note_add,
                            maxLines: 3,
                            onSaved: (value) => _additionalNotes = value ?? '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Aman/Tidak Aman
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSafe ? Icons.check_circle : Icons.warning,
                            color: _isSafe ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status Keamanan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  _isSafe
                                      ? 'Hewan ini aman untuk grooming'
                                      : 'Hewan ini memerlukan perhatian khusus',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isSafe,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _isSafe = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Hewan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Batal
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey[500]),
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroomingNoteField({
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label + ':',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: maxLines,
          onSaved: onSaved,
        ),
      ],
    );
  }
}
