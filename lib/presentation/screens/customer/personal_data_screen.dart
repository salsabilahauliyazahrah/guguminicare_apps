// lib/presentation/screens/profile/personal_data_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/address_model.dart';
import 'package:tugas_akhir/presentation/screens/customer/address_manager.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'dart:convert';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  // User data dari storage
  UserModel? _currentUser;
  // ignore: unused_field
  bool _isLoading = true;
  // ignore: unused_field
  bool _isSaving = false;

  AddressModel? primaryAddress;
  bool isLoadingAddress = true;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user dari StorageHelper
      final userJsonString = StorageHelper.getString('current_user');
      
      if (userJsonString != null && userJsonString.isNotEmpty) {
        final userJson = json.decode(userJsonString) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userJson);
        
        // Isi form dengan data user
        _nameController.text = _currentUser!.name;
        _emailController.text = _currentUser!.email;
        _phoneController.text = _currentUser!.phone;
        _birthDateController.text = _currentUser!.birth_date;
        selectedGender = _currentUser!.gender.isNotEmpty ? _currentUser!.gender : null;
      } else {
        // Fallback: load dari individual fields
        _nameController.text = StorageHelper.getString('user_name') ?? '';
        _emailController.text = StorageHelper.getString('user_email') ?? '';
        _phoneController.text = StorageHelper.getString('user_phone') ?? '';
        _birthDateController.text = '';
        selectedGender = null;
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }

    setState(() {
      _isLoading = false;
    });
    
    // Ambil alamat utama
    _loadPrimaryAddress();
  }

  void _loadPrimaryAddress() {
    print('🔄 Memuat alamat utama dari AddressManager...');
    
    // Ambil alamat utama dari AddressManager
    final addressManager = AddressManager();
    final address = addressManager.getPrimaryAddress();
    
    // Debug: print hasil
    if (address == null) {
      print('⚠️ Tidak ada alamat utama ditemukan');
    } else {
      print('✅ Alamat utama ditemukan: ${address.jenis_alamat} (ID: ${address.id})');
    }
    
    setState(() {
      primaryAddress = address;
      isLoadingAddress = false;
    });
  }

  // ignore: unused_element
  void _goToAddressScreen() async {
    print('➡️ [DataDiri] Navigasi ke halaman alamat');
    
    // Navigasi dan TUNGGU hasilnya
    final newPrimaryAddress = await context.push<AddressModel?>('/profile/address');
    
    if (newPrimaryAddress != null) {
      print('✅ [DataDiri] Menerima alamat utama baru: ${newPrimaryAddress.jenis_alamat}');
      
      // Update AddressManager dengan data baru
      final addressManager = AddressManager();
      
      // PERBAIKAN 1: Gunakan addressesCount dan getAddressById jika perlu
      print('📊 AddressManager memiliki ${addressManager.addressesCount} alamat');
      
      // Jika AddressManager punya method untuk set primary address langsung
      addressManager.setPrimaryAddress(newPrimaryAddress.id);
      
      // Update UI dengan alamat utama yang baru
      setState(() {
        primaryAddress = newPrimaryAddress;
      });
      
      print('🔄 [DataDiri] Alamat utama diperbarui di UI');
    } else {
      print('ℹ️ [DataDiri] Tidak ada perubahan alamat');
    }
  }

  void _refreshAddress() {
    _loadPrimaryAddress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
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
          'Data Diri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _changeProfilePicture,
                      child: const Text(
                        'Ubah Foto Profil',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Fields
              _buildFormSection(),
              
              // Save Button
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 24),
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        // Nama Lengkap
        _buildFormField(
          label: 'Nama Lengkap',
          controller: _nameController,
          icon: Icons.person,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama lengkap wajib diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Email
        _buildFormField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email,
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email wajib diisi';
            }
            if (!value.contains('@')) {
              return 'Email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Nomor Telepon
        _buildFormField(
          label: 'Nomor Telepon',
          controller: _phoneController,
          icon: Icons.phone,
          isRequired: true,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor telepon wajib diisi';
            }
            if (value.length < 10) {
              return 'Nomor telepon terlalu pendek';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Tanggal Lahir
        _buildFormField(
          label: 'Tanggal Lahir',
          controller: _birthDateController,
          icon: Icons.cake,
          readOnly: true,
          onTap: () => _selectBirthDate(context),
          suffixIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        
        // Jenis Kelamin
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.grey500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Jenis Kelamin',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(
                      value: 'Laki-laki',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption(
                      value: 'Perempuan',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Alamat Utama dari halaman alamat
        _buildPrimaryAddressSection(),
      ],
    );
  }

  Widget _buildPrimaryAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home, color: AppColors.grey500, size: 20),
            const SizedBox(width: 8),
            Text(
              'Alamat Utama',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (isLoadingAddress)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Memuat alamat...'),
              ],
            ),
          )
        else if (primaryAddress == null)
          GestureDetector(
            onTap: () async {
              final result = await context.push('/profile/address');
              if (result == true || result != null) {
                _refreshAddress();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tambahkan Alamat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada alamat utama',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap untuk menambahkan alamat penjemputan',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              final result = await context.push('/profile/address');
              if (result == true || result != null) {
                _refreshAddress();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getAddressIcon(primaryAddress!.jenis_alamat),
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              primaryAddress!.jenis_alamat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    primaryAddress!.alamat_lengkap,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${primaryAddress!.kota} - ${primaryAddress!.kode_pos}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (primaryAddress!.catatan.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: ${primaryAddress!.catatan}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap untuk mengelola alamat',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Alamat ini adalah alamat utama dari halaman Alamat Saya',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  IconData _getAddressIcon(String jenis) {
    switch (jenis) {
      case 'rumah': return Icons.home;
      case 'kantor': return Icons.work;
      case 'apartemen': return Icons.apartment;
      default: return Icons.location_on;
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.grey500, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
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
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.grey500)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = groupValue == value;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 4, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return '';
    }
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _takePhoto() {
    // TODO: Implement take photo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ambil foto akan segera tersedia'),
      ),
    );
  }

  void _pickFromGallery() {
    // TODO: Implement pick from gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur pilih dari galeri akan segera tersedia'),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update user model dengan data baru
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birth_date: _birthDateController.text.trim(),
        gender: selectedGender ?? '',
      );

      // Update ke database via UserService
      final userService = UserService();
      await userService.updateUser(updatedUser);

      // Update local storage
      await StorageHelper.save('current_user', json.encode(updatedUser.toJson()));
      await StorageHelper.save('user_name', updatedUser.name);
      await StorageHelper.save('user_email', updatedUser.email);
      await StorageHelper.save('user_phone', updatedUser.phone);

      // Update state
      setState(() {
        _currentUser = updatedUser;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}