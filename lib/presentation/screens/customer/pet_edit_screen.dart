import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/presentation/screens/services/pet_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditPetPage extends StatefulWidget {
  final PetModel petData;

  const EditPetPage({
    super.key,
    required this.petData,
  });

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final PetService _petService = PetService();

  bool _isLoading = false;

  // Data form
  late String _name;
  late String _type;
  late String _breed;
  late int _age;
  late double _weight;
  late String _medicalNotes;
  late bool _isSafe;
  XFile? _selectedImage;
  File? _imageFile;
  String? _currentPhotoUrl;

  // List untuk dropdown
  final List<String> _petTypes = [
    'Kucing',
    'Anjing',
    'Kelinci',
    'Hamster',
    'Burung'
  ];
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
    'Hamster': ['Syrian', 'Campbell', 'Roborovski'],
    'Burung': ['Lovebird', 'Parkit', 'Kenari'],
  };

  @override
  void initState() {
    super.initState();

    // Inisialisasi data dari widget.petData (PetModel)
    _name = widget.petData.name;
    _type = widget.petData.type;
    _breed = widget.petData.breed ?? '';
    _age = int.tryParse(widget.petData.age ?? '1') ?? 1;
    _weight = double.tryParse(widget.petData.weight ?? '1.0') ?? 1.0;
    _medicalNotes = '';
    _isSafe = widget.petData.is_safe == 'true' ||
        widget.petData.is_safe == true.toString();
    _currentPhotoUrl = widget.petData.photo;

    // Pastikan type ada di list
    if (!_petTypes.contains(_type)) {
      _type = 'Kucing';
    }

    // Jika breed tidak ada di list, tambahkan
    if (_breed.isNotEmpty &&
        !(_breedsByType[_type]?.contains(_breed) ?? false)) {
      _breedsByType[_type]?.add(_breed);
    }

    // Jika breed kosong, set ke default
    if (_breed.isEmpty &&
        _breedsByType[_type] != null &&
        _breedsByType[_type]!.isNotEmpty) {
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
        _currentPhotoUrl = null; // Reset URL karena ada gambar baru
      });
    }
  }

  Future<void> _takePhoto() async {
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
        _currentPhotoUrl = null; // Reset URL karena ada gambar baru
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Buat PetModel yang diupdate
        final updatedPet = widget.petData.copyWith(
          name: _name,
          type: _type,
          breed: _breed,
          age: _age.toString(),
          weight: _weight.toString(),
          photo:
              _selectedImage?.path ?? _currentPhotoUrl ?? widget.petData.photo,
          is_safe: _isSafe,
        );

        // Update ke database
        await _petService.updatePet(updatedPet);

        setState(() {
          _isLoading = false;
        });

        // Tampilkan snackbar sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_name berhasil diperbarui!'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Kembali ke halaman sebelumnya dengan result true untuk refresh
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui data: $e'),
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
            if (_currentPhotoUrl != null &&
                _currentPhotoUrl!.startsWith('http'))
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto Saat Ini'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentPhotoUrl = null;
                    _selectedImage = null;
                    _imageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hewan?'),
        content:
            Text('Apakah Anda yakin ingin menghapus ${widget.petData.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              try {
                await _petService.deletePet(widget.petData.id);

                setState(() {
                  _isLoading = false;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.petData.name} telah dihapus'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                // Kembali dengan result true untuk refresh list
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit ${widget.petData.name}',
          style: const TextStyle(
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus Hewan', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
                              : _currentPhotoUrl != null &&
                                      _currentPhotoUrl!.startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        _currentPhotoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _buildPlaceholderImage();
                                        },
                                      ),
                                    )
                                  : _buildPlaceholderImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Nama
                    _buildFormField(
                      label: 'Nama Hewan *',
                      hintText: 'Contoh: Milo',
                      icon: Icons.pets,
                      initialValue: _name,
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
                            initialValue: _age.toString(),
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
                            initialValue: _weight.toString(),
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

                    // Input Catatan Medis
                    _buildFormField(
                      label: 'Catatan Medis',
                      hintText:
                          'Contoh: Alergi obat tertentu, kondisi kesehatan khusus',
                      icon: Icons.local_hospital,
                      initialValue: _medicalNotes,
                      maxLines: 3,
                      onSaved: (value) => _medicalNotes = value ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Toggle Aman/Tidak Aman
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
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

                    // Info Terakhir Grooming
                    if (widget.petData.last_grooming != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.spa,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terakhir Grooming',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    widget.petData.last_grooming ??
                                        'Belum pernah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan Perubahan',
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
                        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildPlaceholderImage() {
    return Column(
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
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required IconData icon,
    String? initialValue,
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
          initialValue: initialValue,
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
}
