// lib/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/auth/auth_service.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_text_styles.dart';
import 'package:tugas_akhir/core/utils/validators.dart';
import 'package:tugas_akhir/core/theme/primary_button.dart';
import 'package:tugas_akhir/core/theme/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController(); // ✅ TAMBAH PHONE CONTROLLER
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose(); // ✅ JANGAN LUPA
    super.dispose();
  }

  // ✅ METHOD REGISTER YANG BARU
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Cek password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password tidak sama'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // ✅ REGISTER via AuthService (connect ke database)
        // ignore: unused_local_variable
        final user = await AuthService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(), // ✅ TAMBAH PHONE
        );

        // ✅ REDIRECT KE CUSTOMER HOME (auto role customer)
        context.go('/home');

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daftar Akun',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header Image
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Buat Akun Baru',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Isi data diri Anda untuk membuat akun',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Nama Lengkap
              CustomTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                validator: (value) => Validators.validateRequired(value, field: 'Nama lengkap'),
                isRequired: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // ✅ TAMBAH PHONE FIELD
              CustomTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                hintText: '0812-3456-7890',
                prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
                isRequired: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'contoh@email.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                isRequired: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Password
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Minimal 6 karakter',
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                obscureText: !_isPasswordVisible,
                validator: Validators.validatePassword,
                isRequired: true,
                textInputAction: TextInputAction.next,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Konfirmasi Password
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password',
                hintText: 'Ketik ulang password',
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) => Validators.validateConfirmPassword(
                  value, 
                  _passwordController.text,
                ),
                isRequired: true,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                onSubmitted: (_) => _register(),
              ),
              
              const SizedBox(height: 32),
              
              // Register Button
              PrimaryButton(
                text: 'Daftar',
                onPressed: _isLoading ? null : _register,
                isLoading: _isLoading,
                fullWidth: true,
                icon: Icons.person_add,
              ),
              
              const SizedBox(height: 24),
              
              // HAPUS TERMS & CONDITIONS (optional)
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Masuk di sini',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}