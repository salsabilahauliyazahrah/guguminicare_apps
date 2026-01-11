//lib/presentation/screens/customer/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/theme/app_responsive.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    print('🔍 Testing storage...');
    
    // // Test 1: Coba simpan data dulu
    // await StorageHelper.setString('user_name', 'John Doe Test');
    // await StorageHelper.setString('user_email', 'test@example.com');
    
    // // Test 2: Baca data
    // final testName = StorageHelper.getString('user_name');
    // final testEmail = StorageHelper.getString('user_email');
    
    // print('🧪 Test Name: $testName');
    // print('🧪 Test Email: $testEmail');
    
    // Test 3: Gunakan data asli jika ada
    final userName = StorageHelper.getString('user_name') ?? 'Pengguna';
    
    if (mounted) {
      setState(() {
        _userName = userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, // Sedikit shadow
        centerTitle: true,
        shadowColor: Colors.black.withOpacity(0.1), // Shadow soft        
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.pets,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Gugumini Care',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications),
            ),
            color: AppColors.primary,
            onPressed: () => context.go('/notification'),
          ),
        ],
      ), 
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section - Responsive
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 120),
                        decoration: BoxDecoration(
                          gradient: AppColors.homePrimaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Row(
                            children: [
                              // Avatar - Responsive
                              Container(
                                width: isSmallScreen ? 50 : 60,
                                height: isSmallScreen ? 50 : 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: isSmallScreen ? 24 : 30,
                                    color: AppColors.homePrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,                                  
                                  children: [
                                    Text(
                                      'Selamat Datang,',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: isSmallScreen ? 11 : 13,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      _userName,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: isSmallScreen ? 18 : 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      'Siap merawat hewan peliharaan Anda hari ini?',
                                      style: TextStyle(
                                        color: AppColors.white.withOpacity(0.9),
                                        fontSize: isSmallScreen ? 11 : 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Quick Actions Title
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: AppResponsive.title(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: AppResponsive.spacing(context)),

                      // quck Actions
                      _buildQuickActions(context), // DIUBAH: tambah parameter context
                      const SizedBox(height: 24),
                                          
                      // Recent Bookings
                      Text(
                        'Recent Bookings',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Bookings Container - Responsive
                      Container(
                        width: double.infinity,
                        height: isSmallScreen 
                            ? screenHeight * 0.20 
                            : screenHeight * 0.22,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.grey200, AppColors.grey300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: isSmallScreen ? 36 : 44,
                                color: AppColors.grey600,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'No bookings yet',
                                style: TextStyle(
                                  color: AppColors.grey600,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Book your first service today!',
                                style: TextStyle(
                                  color: AppColors.grey500,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05), // Space untuk bottom nav
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),  
      bottomNavigationBar: _buildBottomNavigationBar(context),            
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orangeMedium, // WARNA BARU
        unselectedItemColor: AppColors.grey600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        elevation: 0,
        onTap: (index) => _onBottomNavTap(context, index),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.home_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, size: 24, color: Colors.white),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.pets_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 24, color: Colors.white),
            ),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.calendar_today_outlined, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, size: 24, color: Colors.white),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.person_outline, size: 24),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.orangeRedGradient, // GRADASI BARU
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 24, color: Colors.white),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/pets');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }


  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(
          icon: Icons.add_circle_outline,
          label: 'Booking\nBaru',
          color: Colors.blue,
          onTap: () => context.push('/booking-new'),
        ),
        _buildQuickAction(
          icon: Icons.history,
          label: 'Riwayat\nGrooming',
          color: Colors.purple,
          onTap: () => context.push('/bookings'),
        ),
        _buildQuickAction(
          icon: Icons.spa,
          label: 'Pilihan\nLayanan',
          color: Colors.green,
          onTap: () => context.push('/profile/layanan'),
        ),
        _buildQuickAction(
          icon: Icons.help_outline,
          label: 'Bantuan &\nDukungan',
          color: Colors.teal,
          onTap: () => context.push('/profile/help'),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }    

  // ignore: unused_element
  void _sharePetProfile() {
    // TODO: Implement share functionality
  }    
}