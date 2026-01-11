// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/auth/auth_service.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_text_styles.dart';
import 'package:tugas_akhir/core/utils/validators.dart';
import 'package:tugas_akhir/core/theme/primary_button.dart';
import 'package:tugas_akhir/core/theme/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ METHOD LOGIN YANG BARU (CONNECT KE AUTH SERVICE)
  // Di LoginScreen.dart
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('📝 Login attempt with email: ${_emailController.text}');
      
      final user = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      print('✅ Login successful!');
      print('   User ID: ${user.id}');
      print('   User Name: ${user.name}');
      print('   User Role: ${user.role}');
      
      // **TAMBAHKAN DELAY DAN CLEAR NAVIGATION STACK**
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear semua halaman sebelumnya dan redirect sesuai role
      switch (user.role.toLowerCase()) {
        case 'customer':
          print('🚀 Redirecting customer to /home');
          // Gunakan goNamed dengan clear stack
          context.go('/home');
          break;
        case 'admin':
          print('🚀 Redirecting admin to /admin/dashboard');
          // Pastikan route admin sudah ada di GoRouter
          context.go('/admin/dashboard'); 
          break;
        case 'driver':
          print('🚀 Redirecting driver to /driver/dashboard');
          context.go('/driver/dashboard');
          break;
        default:
          print('⚠️ Unknown role: ${user.role}');
          throw Exception('Role tidak dikenali: ${user.role}');
      }

    } catch (e) {
      print('❌ Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.orangeRedGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 50,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to PetCare',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'yulis@email.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  isRequired: true,
                  onSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  isRequired: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grey600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 8),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  fullWidth: true,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),
                const SizedBox(height: 24),
                // HAPUS SOCIAL LOGIN SECTION (optional)
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Sign Up',
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
      ),
    );
  }
}