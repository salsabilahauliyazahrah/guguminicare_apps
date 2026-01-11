// lib/presentation/screens/profile/add_address_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _namaAlamatController = TextEditingController();
  final TextEditingController _alamatLengkapController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  String _selectedJenis = 'rumah';
  bool _isUtama = false;

  @override
  void dispose() {
    _namaAlamatController.dispose();
    _alamatLengkapController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    _catatanController.dispose();
    super.dispose();
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
          'Tambah Alamat Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Nama Alamat
              _buildFormField(
                controller: _namaAlamatController,
                label: 'Nama Alamat',
                hint: 'Contoh: Rumah, Kantor, Apartemen',
                icon: Icons.title,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama alamat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Jenis Alamat
              _buildJenisAlamatDropdown(),
              const SizedBox(height: 16),
              
              // Alamat Lengkap
              _buildFormField(
                controller: _alamatLengkapController,
                label: 'Alamat Lengkap',
                hint: 'Jl. Merdeka No. 123, RT/RW, Kecamatan',
                icon: Icons.location_on,
                isRequired: true,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Kota
              _buildFormField(
                controller: _kotaController,
                label: 'Kota/Kabupaten',
                hint: 'Contoh: Jakarta Pusat, Bandung, Surabaya',
                icon: Icons.location_city,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kota wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Kode Pos
              _buildFormField(
                controller: _kodePosController,
                label: 'Kode Pos',
                hint: 'Contoh: 10110',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Catatan
              _buildFormField(
                controller: _catatanController,
                label: 'Catatan (Opsional)',
                hint: 'Contoh: Gang biru, rumah pagar putih, parkir depan',
                icon: Icons.note,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Checkbox Jadikan Alamat Utama
              _buildUtamaCheckbox(),
              
              const SizedBox(height: 32),
              
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Simpan Alamat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
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
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJenisAlamatDropdown() {
    final List<Map<String, dynamic>> jenisOptions = [
      {'value': 'rumah', 'label': 'Rumah', 'icon': Icons.home},
      {'value': 'kantor', 'label': 'Kantor', 'icon': Icons.work},
      {'value': 'apartemen', 'label': 'Apartemen', 'icon': Icons.apartment},
      {'value': 'lainnya', 'label': 'Lainnya', 'icon': Icons.location_on},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'Jenis Alamat',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedJenis,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedJenis = newValue;
                  });
                }
              },
              items: jenisOptions.map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Row(
                    children: [
                      Icon(option['icon'], color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(option['label']),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtamaCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isUtama,
          onChanged: (bool? value) {
            setState(() {
              _isUtama = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jadikan alamat utama',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Alamat utama akan digunakan untuk semua layanan grooming',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = {
        'id': DateTime.now().millisecondsSinceEpoch, // Generate unique ID
        'namaAlamat': _namaAlamatController.text,
        'alamatLengkap': _alamatLengkapController.text,
        'kota': _kotaController.text,
        'kodePos': _kodePosController.text,
        'catatan': _catatanController.text,
        'jenis': _selectedJenis,
        'isUtama': _isUtama,
      };
      
      // Kembali ke halaman sebelumnya dengan data
      context.pop(newAddress);
    }
  }
}