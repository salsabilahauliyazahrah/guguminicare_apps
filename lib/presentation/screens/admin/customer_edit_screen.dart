// lib/presentation/screens/admin/customer_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/presentation/screens/services/user_service.dart';

class EditCustomerScreen extends StatefulWidget {
  final UserModel customer;
  
  const EditCustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  
  String? _selectedGender;
  List<String> genderOptions = ['Laki-laki', 'Perempuan'];
  
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Isi form dengan data customer
    _nameController = TextEditingController(text: widget.customer.name);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _birthDateController = TextEditingController();
    
    // Format birth date jika ada
    if (widget.customer.birth_date.isNotEmpty) {
      final birthDate = DateTime.tryParse(widget.customer.birth_date);
      if (birthDate != null) {
        _birthDateController.text = _dateFormat.format(birthDate);
      }
    }
    
    // Set gender
    _selectedGender = widget.customer.gender.isNotEmpty 
        ? (widget.customer.gender == 'male' ? 'Laki-laki' : 'Perempuan')
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Prepare updated data
        final updatedCustomer = widget.customer.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          gender: _selectedGender == 'Laki-laki' ? 'male' : 'female',
        );
        
        // Update in database
        await _userService.updateUser(updatedCustomer);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil pelanggan berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back with updated data
        if (context.mounted) {
          context.pop(updatedCustomer);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.customer.birthDateOrNull ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orangeMedium,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = _dateFormat.format(picked);
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
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
          'Edit Profil Pelanggan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.blue),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.orangeMedium.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.orangeMedium,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.orangeMedium,
                              ),
                            ),
                            
                            const SizedBox(width: 20),
                            
                            // Customer Info Preview
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.customer.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.customer.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.customer.role == 'customer'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      widget.customer.role == 'customer' ? 'AKTIF' : 'TIDAK AKTIF',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: widget.customer.role == 'customer'
                                            ? Colors.green
                                            : Colors.red,
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
                    
                    const SizedBox(height: 24),
                    
                    // Form Fields
                    _buildFormSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Save Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeMedium,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
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
                    
                    const SizedBox(height: 20),
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
            if (!value.contains('@') || !value.contains('.')) {
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
          suffixIcon: Icons.edit_calendar,
        ),
        const SizedBox(height: 16),
        
        // Jenis Kelamin
        _buildGenderDropdown(),
        
        const SizedBox(height: 16),
        
        // ID Pelanggan (Read Only)
        _buildFormField(
          label: 'ID Pelanggan',
          controller: TextEditingController(text: widget.customer.id),
          icon: Icons.person_pin,
          readOnly: true,
          enabled: false,
        ),
        
        const SizedBox(height: 20),
        
        // Role (Read Only)
        _buildFormField(
          label: 'Role',
          controller: TextEditingController(
            text: widget.customer.role == 'customer' ? 'Pelanggan' : widget.customer.role,
          ),
          icon: Icons.work,
          readOnly: true,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
    bool readOnly = false,
    bool enabled = true,
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
                color: enabled ? Colors.grey[700] : Colors.grey[400],
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
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
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
              borderSide: BorderSide(color: AppColors.orangeMedium),
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

  Widget _buildGenderDropdown() {
    return Column(
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
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              isExpanded: true,
              hint: const Text('Pilih Jenis Kelamin'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              items: genderOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}