// lib/presentation/screens/auth/forgot_password/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const OTPVerificationScreen({
    super.key,
    required this.userData,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  String _errorMessage = '';
  String _generatedOTP = ''; // Simpan OTP yang digenerate

  @override
  void initState() {
    super.initState();
    _generateOTP();
    _startResendTimer();
    
    // Setup focus listeners
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _generateOTP() {
    // Generate 6 digit OTP
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    _generatedOTP = random.substring(random.length - 6);
    print('🔐 Generated OTP: $_generatedOTP'); // Debug only
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startResendTimer();
      }
    });
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _resendCountdown = 60;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call
    
    _generateOTP();
    
    setState(() => _isResending = false);
    _startResendTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP baru telah dikirim'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _verifyOTP() async {
    final enteredOTP = _otpControllers.map((c) => c.text).join();
    
    if (enteredOTP.length != 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit OTP');
      return;
    }

    // Debug: Bypass OTP untuk testing
    if (enteredOTP == '123456' || enteredOTP == _generatedOTP) {
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Navigasi ke reset password screen
      if (context.mounted) {
        context.push(
          '/reset-password/new',
          extra: widget.userData,
        );
      }
    } else {
      setState(() => _errorMessage = 'Kode OTP tidak valid');
      _shakeOTPFields();
    }
  }

  void _shakeOTPFields() {
    // Bisa implement shake animation di sini
    setState(() {});
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 8) return phone;
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 4);
    return '$start****$end';
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.userData['phone'] ?? '';
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
                'Verifikasi OTP',
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
                    const TextSpan(text: 'Kami telah mengirim kode OTP ke '),
                    TextSpan(
                      text: _maskPhoneNumber(phone),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // User Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.orangeMedium.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.orangeMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Ubah',
                        style: TextStyle(
                          color: AppColors.orangeMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input Fields
              Center(
                child: Column(
                  children: [
                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _errorMessage.isNotEmpty 
                                      ? Colors.red 
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.orangeMedium,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              setState(() => _errorMessage = '');
                            },
                          ),
                        );
                      }),
                    ),
                    
                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    // OTP Hint (for testing)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Testing OTP: $_generatedOTP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
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
                          'Verifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Resend OTP
              Center(
                child: Column(
                  children: [
                    Text(
                      'Tidak menerima kode?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_resendCountdown > 0)
                      Text(
                        'Kirim ulang dalam $_resendCountdown detik',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isResending ? null : _resendOTP,
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Kirim Ulang OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orangeMedium,
                                ),
                              ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back to Phone Input
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Ganti Nomor Telepon',
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