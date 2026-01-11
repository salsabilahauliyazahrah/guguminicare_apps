// lib/presentation/screens/auth/forgot_password/new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const NewPasswordScreen({
    super.key,
    required this.userData,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isPasswordValid = false;
  String _passwordError = '';
  String _confirmPasswordError = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String password) {
    setState(() {
      _passwordError = '';
      
      if (password.length < 6) {
        _passwordError = 'Password minimal 6 karakter';
        _isPasswordValid = false;
      } else {
        _isPasswordValid = true;
      }
    });
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      _confirmPasswordError = '';
      
      if (confirmPassword != _passwordController.text) {
        _confirmPasswordError = 'Password tidak cocok';
      }
    });
  }

  Future<void> _resetPassword() async {
    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final userId = widget.userData['userId'];
      final user = await _userService.getUserById(userId);
      
      // Update password
      final updatedUser = user.copyWith(
        password: _passwordController.text,
      );
      
      await _userService.updateUser(updatedUser);
      
      print('✅ Password updated successfully for user: ${user.name}');
      
      // Show success dialog
      await _showSuccessDialog();
      
      // Navigate to login
      if (context.mounted) {
        context.go('/login');
      }
      
    } catch (e) {
      print('❌ Error resetting password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal reset password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: const Text(
          'Password Anda telah berhasil direset. Silakan login dengan password baru Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Login Sekarang'),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Lemah';
    if (password.length < 8) return 'Cukup';
    if (!RegExp(r'[A-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Baik';
    }
    return 'Sangat Baik';
  }

  Color _getStrengthColor(String password) {
    if (password.isEmpty) return Colors.grey;
    if (password.length < 6) return Colors.red;
    if (password.length < 8) return Colors.orange;
    if (!RegExp(r'[A-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      return Colors.blue;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userData['userName'] ?? '';

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
                'Password Baru',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeMedium,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  children: [
                    const TextSpan(text: 'Halo '),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ', buat password baru Anda'),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Illustration
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.orangeMedium.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: AppColors.orangeMedium,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // New Password
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  errorText: _passwordError.isNotEmpty ? _passwordError : null,
                ),
                onChanged: _validatePassword,
              ),
              
              // Password Strength
              if (_passwordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordController.text.length / 12,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStrengthColor(_passwordController.text),
                              ),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getStrengthText(_passwordController.text),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStrengthColor(_passwordController.text),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Minimal 6 karakter\n• Kombinasi huruf dan angka lebih baik',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                ),
                onChanged: _validateConfirmPassword,
              ),
              
              const SizedBox(height: 32),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pastikan password Anda mudah diingat tetapi sulit ditebak. Hindari menggunakan informasi pribadi seperti tanggal lahir.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}