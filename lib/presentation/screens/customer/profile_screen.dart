// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/presentation/screens/auth/storage_helper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userName = StorageHelper.getString('user_name');
    final userEmail = StorageHelper.getString('user_email');
    setState(() {
      _userName = userName ?? 'Pengguna';
      _userEmail = userEmail ?? '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
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
            onPressed: () => context.push('/notification'),
          ),
        ],
      ),      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.homePrimaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.homePrimary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name
                    Text(
                      _userName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      _userEmail,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),            
            
            // Menu Items
            _buildMenuSection(
              context,
              title: 'Akun Saya',
              items: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Data Diri',
                  subtitle: 'Ubah data pribadi',
                  onTap: () => context.push('/profile/personal'),
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  subtitle: 'Kelola alamat penjemputan',
                  onTap: () => context.push('/profile/address'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildMenuSection(
              context,
              title: 'Layanan',
              items: [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Pilihan Layanan',
                  subtitle: 'Jenis grooming yang tersedia',
                  onTap: () => context.push('/profile/layanan'),
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Metode Layanan',
                  subtitle: 'Cara pengantaran dan penjemputan',
                  onTap: () => context.push('/profile/metode-layanan'),
                ),                
              ],
            ),
            const SizedBox(height: 32),

            _buildMenuSection(
              context,
              title: 'Bantuan',
              items: [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan & Dukungan',
                  subtitle: 'Pusat bantuan',
                  onTap: () => context.push('/profile/help'),
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Versi 1.0.0',
                  onTap: () => context.push('/profile/about'),
                ),
              ],
            ),
            const SizedBox(height: 32),
                        
            // Logout Button          
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFEBEE), // Red 50
                    Color(0xFFFFCDD2), // Red 100
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Color(0xFFEF9A9A), // Red 200
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEF9A9A).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    _showLogoutDialog(context, ref);
                  },
                  splashColor: AppColors.error.withOpacity(0.1),
                  highlightColor: AppColors.error.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE53935), // Red 600
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          color: Color(0xFFC62828), // Red 800
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),   
            const SizedBox(height: 20),
          ],
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
        currentIndex: 3,
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

  // ignore: unused_element
  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement logout logic here
              // ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}