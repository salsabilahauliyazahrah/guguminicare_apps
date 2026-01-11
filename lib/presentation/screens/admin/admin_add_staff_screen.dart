// lib/presentation/screens/admin/settings/add_staff_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  final UserService _userService = UserService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedRole = 'admin';
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  // Untuk upload foto
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // Daftar role yang tersedia
  final List<Map<String, String>> _roles = [
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'driver', 'label': 'Driver'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan konfirmasi password tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload gambar jika ada
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      // 2. Buat UserModel
      final newUser = UserModel(
        id: '', // ID akan di-generate oleh API
        email: _emailController.text,
        password: _passwordController.text, // Note: Ini belum di-hash
        name: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : '-',
        role: _selectedRole,
        birth_date: '',
        gender: '',
        profile_picture: imageUrl ?? '',
        salon_code: '',
        salon_name: '',
        salon_id: '',
        created_at: DateTime.now().toIso8601String().split('.')[0], // Format tanpa milidetik
      );

      // 3. Panggil API untuk insert user
      await _createStaff(newUser);

      // 4. Tampilkan success message dan kembali
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Staff berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      // 5. Kembali ke halaman sebelumnya
      if (context.mounted) {
        context.pop(true); // Return true sebagai tanda berhasil
      }

    } catch (e) {
      print('❌ Error adding staff: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan staff: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    setState(() => _isUploadingImage = true);
    
    try {
      print('📤 Uploading image...');
      
      // Konfigurasi API 247GO upload
      const String uploadUrl = 'https://api.247go.app/v5/upload/';
      const String token = '68f2ede325bcf6243d214a05';
      const String project = 'gugumicare';
      
      // Buat multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Tambahkan fields
      request.fields['token'] = token;
      request.fields['project'] = project;
      
      // Tambahkan file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'staff_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('📡 Upload Response Status: ${response.statusCode}');
      print('📦 Upload Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is Map && responseData.containsKey('url')) {
          final imageUrl = responseData['url']?.toString();
          print('✅ Image uploaded: $imageUrl');
          return imageUrl;
        } else if (responseData is Map && responseData.containsKey('data')) {
          final imageUrl = responseData['data']?.toString();
          print('✅ Image uploaded: $imageUrl');
          return imageUrl;
        } else {
          print('⚠️ No URL in response, using response directly');
          return response.body;
        }
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      print('💥 Error uploading image: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _createStaff(UserModel user) async {
    print('➕ Creating new staff: ${user.name}');
    
    const String baseUrl = 'https://api.247go.app/v5/';
    const String token = '68f2ede325bcf6243d214a05';
    const String project = 'gugumicare';
    const String appId = '695d6cfd045a4b3d08976d16';
    
    final url = '${baseUrl}insert/';
    
    try {
      final Map<String, String> bodyData = {
        'token': token,
        'project': project,
        'collection': 'user',
        'appid': appId,
        'email': user.email,
        'password': user.password,
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'profile_picture': user.profile_picture,
        'created_at': user.created_at,
      };
      
      print('📋 Staff Data:');
      bodyData.forEach((key, value) {
        print('   $key: $value');
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
          print('✅ Staff created with ID: ${createdData['_id']}');
        } else if (responseData is Map && responseData['status'] == '1') {
          print('✅ Staff created successfully');
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('💥 Error creating staff: $e');
      rethrow;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil dipilih'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
        title: const Text(
          'Tambah Staff Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatarSection(),
              const SizedBox(height: 24),

              // Nama
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'contoh@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone (optional)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                  hintText: '0812-3456-7890',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role / Posisi *',
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((Map<String, String> role) {
                  return DropdownMenuItem<String>(
                    value: role['value'],
                    child: Text(role['label']!),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih role staff';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _isLoading ? null : () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                  hintText: 'Minimal 6 karakter',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _isLoading ? null : () {
                      setState(() => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                  hintText: 'Ulangi password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Tambah Staff',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar Circle
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey500, width: 2),
                color: Colors.grey[100],
              ),
              child: ClipOval(
                child: _isUploadingImage
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.orangeMedium),
                      )
                    : _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
              ),
            ),
            if (_selectedImage != null && !_isUploadingImage)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.orangeMedium,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Upload Button
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading || _isUploadingImage ? null : () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.orangeMedium,
                side: BorderSide(color: AppColors.orangeMedium),
              ),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Kamera'),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading || _isUploadingImage ? null : () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.orangeMedium,
                side: BorderSide(color: AppColors.orangeMedium),
              ),
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Galeri'),
            ),
            if (_selectedImage != null)
              ElevatedButton.icon(
                onPressed: _isLoading || _isUploadingImage ? null : () {
                  setState(() => _selectedImage = null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        Text(
          'Upload foto profil (opsional)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.grey500,
      ),
    );
  }
}