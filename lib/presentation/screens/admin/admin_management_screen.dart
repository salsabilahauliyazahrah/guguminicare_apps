// lib/presentation/screens/admin/settings/admin_management_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final UserService _userService = UserService();
  List<UserModel> _staffList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    
    try {
      // Ambil semua user dengan role 'admin' atau 'driver'
      final admins = await _userService.getUsersByRole('admin');
      final drivers = await _userService.getUsersByRole('driver');
      
      // Gabungkan dan filter yang bukan customer
      List<UserModel> allStaff = [];
      allStaff.addAll(admins);
      allStaff.addAll(drivers);
      
      // Filter duplikat berdasarkan ID
      final uniqueStaff = <UserModel>[];
      final seenIds = <String>{};
      
      for (var staff in allStaff) {
        if (!seenIds.contains(staff.id) && staff.id.isNotEmpty) {
          seenIds.add(staff.id);
          uniqueStaff.add(staff);
        }
      }
      
      setState(() {
        _staffList = uniqueStaff;
        _isLoading = false;
      });
      
      print('✅ Loaded ${_staffList.length} staff members');
    } catch (e) {
      print('❌ Error loading staff: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data staff: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<UserModel> get _filteredStaff {
    if (_searchQuery.isEmpty) return _staffList;
    
    return _staffList.where((staff) {
      return staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             staff.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             staff.phone.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return 'Admin';
      case 'driver': return 'Driver';
      case 'customer': return 'Customer';
      default: return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.purple;
      case 'driver': return Colors.blue;
      case 'customer': return Colors.green;
      default: return Colors.grey;
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Kelola Staff',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
            color: AppColors.orangeMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewStaff,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari staff...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  label: 'Total Staff',
                  value: '${_staffList.length}',
                  icon: Icons.group,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  label: 'Admin',
                  value: '${_staffList.where((s) => s.role.toLowerCase() == 'admin').length}',
                  icon: Icons.admin_panel_settings,
                  color: Colors.purple,
                ),
                _buildStatCard(
                  label: 'Driver',
                  value: '${_staffList.where((s) => s.role.toLowerCase() == 'driver').length}',
                  icon: Icons.delivery_dining,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Staff List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredStaff.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadStaff,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredStaff.length,
                          itemBuilder: (context, index) {
                            final staff = _filteredStaff[index];
                            return _buildStaffCard(staff);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.orangeMedium),
          const SizedBox(height: 16),
          const Text('Memuat data staff...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Belum ada staff terdaftar'
                  : 'Staff tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Tambahkan staff baru untuk mengelola sistem'
                  : 'Coba dengan kata kunci lain',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchQuery.isEmpty ? _addNewStaff : () => setState(() => _searchQuery = ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeMedium,
                foregroundColor: Colors.white,
              ),
              child: Text(_searchQuery.isEmpty ? 'Tambah Staff' : 'Reset Pencarian'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(UserModel staff) {
    final roleLabel = _getRoleLabel(staff.role);
    final roleColor = _getRoleColor(staff.role);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Icon(
            _getRoleIcon(staff.role),
            color: roleColor,
          ),
        ),
        title: Text(
          staff.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff.email),
            if (staff.phone.isNotEmpty) Text(staff.phone),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: roleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (staff.created_at.isNotEmpty)
                  Text(
                    _formatDate(staff.created_at),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleStaffAction(value, staff),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'reset_password', child: Text('Reset Password')),
            const PopupMenuItem(value: 'deactivate', child: Text('Nonaktifkan')),
            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Icons.admin_panel_settings;
      case 'driver': return Icons.delivery_dining;
      default: return Icons.person;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return 'Bergabung: ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Bergabung: $dateString';
    }
  }

  void _addNewStaff() {
    context.push('/admin/add-staff').then((result) {
      if (result == true) {
        _loadStaff(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Staff baru berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _handleStaffAction(String action, UserModel staff) {
    switch (action) {
      case 'edit':
        _editStaff(staff);
        break;
      case 'reset_password':
        _resetPassword(staff);
        break;
      case 'deactivate':
        _deactivateStaff(staff);
        break;
      case 'delete':
        _deleteStaff(staff);
        break;
    }
  }

  void _editStaff(UserModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Staff'),
        content: const Text('Fitur edit staff akan segera tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetPassword(UserModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Reset password untuk ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link reset password telah dikirim ke ${staff.email}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _deactivateStaff(UserModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan Staff'),
        content: Text('Nonaktifkan ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${staff.name} telah dinonaktifkan'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
  }

  void _deleteStaff(UserModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Staff'),
        content: Text('Hapus permanen ${staff.name}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${staff.name} telah dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}