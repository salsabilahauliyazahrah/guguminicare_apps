// lib/presentation/screens/auth/forgot_password/phone_input_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';
import 'package:tugas_akhir/core/models/user_model.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isPhoneValid = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String phone) {
    // Validasi format nomor telepon Indonesia
    final phoneRegex = RegExp(r'^(?:\+62|62|0)8[1-9][0-9]{6,9}$');
    setState(() {
      _isPhoneValid = phoneRegex.hasMatch(phone);
      _errorMessage = null;
    });
  }

  Future<void> _sendOTP() async {
    if (!_isPhoneValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📱 Checking phone number: ${_phoneController.text}');
      
      // Validasi nomor telepon ada di database
      final users = await _userService.searchUsers(_phoneController.text);
      
      final userWithPhone = users.firstWhere(
        (user) => user.phone == _phoneController.text,
        orElse: () => UserModel(
          id: '',
          email: '',
          password: '',
          name: '',
          phone: '',
          role: '',
          birth_date: '',
          gender: '',
          profile_picture: '',
          salon_code: '',
          salon_name: '',
          salon_id: '',
          created_at: '',
        ),
      );

      if (userWithPhone.id.isEmpty) {
        throw Exception('Nomor telepon tidak terdaftar');
      }

      print('✅ Phone verified for user: ${userWithPhone.name}');

      // Navigasi ke OTP verification screen dengan data user
      if (context.mounted) {
        context.push(
          '/reset-password/verify',
          extra: {
            'phone': _phoneController.text,
            'userId': userWithPhone.id,
            'userName': userWithPhone.name,
          },
        );
      }

    } catch (e) {
      print('❌ Error verifying phone: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              Text(
                'Lupa Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan nomor telepon yang terdaftar untuk reset password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Illustration
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.orangeMedium.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_iphone,
                    size: 100,
                    color: AppColors.orangeMedium,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Phone Input
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: '0812-3456-7890',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  errorText: _errorMessage,
                  suffixIcon: _phoneController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _phoneController.clear();
                            _validatePhone('');
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.phone,
                onChanged: _validatePhone,
                onSubmitted: (_) => _isPhoneValid ? _sendOTP() : null,
              ),
              
              const SizedBox(height: 8),
              Text(
                'Contoh: 081234567890 atau 6281234567890',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPhoneValid && !_isLoading ? _sendOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.orangeMedium,
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
}