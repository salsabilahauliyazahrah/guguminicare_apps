// lib/presentation/screens/admin/services/edit_service_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;
  
  const EditServiceScreen({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceService _serviceService = ServiceService();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _suitableForController;
  
  // Form state
  late String _selectedCategory;
  late bool _isActive;
  String _selectedColor = '#FF6B35';
  String _selectedIcon = 'spa';
  
  // Untuk multiple details dan benefits
  List<String> _details = [];
  List<String> _benefits = [];
  
  bool _isLoading = false;
  
  // Categories
  final List<Map<String, String>> _categories = [
    {'value': 'grooming', 'label': 'Grooming'},
    {'value': 'spa', 'label': 'Spa'},
    {'value': 'paket', 'label': 'Paket'},
    {'value': 'medis', 'label': 'Medis'},
  ];
  
  // Icons pilihan
  final List<Map<String, dynamic>> _icons = [
    {'value': 'cleaning_services', 'label': 'Grooming', 'icon': Icons.cleaning_services},
    {'value': 'spa', 'label': 'Spa', 'icon': Icons.spa},
    {'value': 'pets', 'label': 'Pets', 'icon': Icons.pets},
    {'value': 'health_and_safety', 'label': 'Health', 'icon': Icons.health_and_safety},
    {'value': 'bathtub', 'label': 'Bath', 'icon': Icons.bathtub},
    {'value': 'cut', 'label': 'Cut', 'icon': Icons.content_cut},
  ];
  
  // Colors pilihan
  final List<Map<String, dynamic>> _colors = [
    {'value': '#FF6B35', 'label': 'Orange', 'color': Colors.orange},
    {'value': '#4FC3F7', 'label': 'Blue', 'color': Colors.blue},
    {'value': '#66BB6A', 'label': 'Green', 'color': Colors.green},
    {'value': '#FFD54F', 'label': 'Yellow', 'color': Colors.yellow},
    {'value': '#BA68C8', 'label': 'Purple', 'color': Colors.purple},
    {'value': '#FF8A65', 'label': 'Deep Orange', 'color': Colors.deepOrange},
  ];

  @override
  void initState() {
    super.initState();
    
    try {
      print('🔄 Initializing EditServiceScreen...');
      print('📋 Service data: ${widget.service.toJson()}');
      
      // Inisialisasi controllers
      _nameController = TextEditingController(text: widget.service.name);
      _descriptionController = TextEditingController(text: widget.service.description);
      _priceController = TextEditingController(text: widget.service.price);
      _durationController = TextEditingController(text: widget.service.duration);
      _suitableForController = TextEditingController(text: widget.service.suitable_for);
      
      // Inisialisasi category - PASTIKAN INI ADA!
      _selectedCategory = widget.service.category.isNotEmpty 
          ? widget.service.category 
          : 'grooming';
      
      // Inisialisasi is_active
      _isActive = widget.service.is_active == '1' || 
                  widget.service.is_active == 'true' ||
                  widget.service.is_active == '1';
      
      // Inisialisasi color dan icon dari service jika ada
      if (widget.service.color.isNotEmpty) {
        _selectedColor = widget.service.color;
      }
      
      if (widget.service.icon.isNotEmpty) {
        _selectedIcon = widget.service.icon;
      }
      
      // Parse details dan benefits
      if (widget.service.details.isNotEmpty) {
        _details = widget.service.details.split('|').map((e) => e.trim()).toList();
      }
      if (widget.service.benefits.isNotEmpty) {
        _benefits = widget.service.benefits.split('|').map((e) => e.trim()).toList();
      }
      
      // Jika kosong, tambah field kosong
      if (_details.isEmpty) _details.add('');
      if (_benefits.isEmpty) _benefits.add('');
      
      print('✅ EditServiceScreen initialized successfully');
      print('   Category: $_selectedCategory');
      print('   Color: $_selectedColor');
      print('   Icon: $_selectedIcon');
      print('   Active: $_isActive');
      print('   Details count: ${_details.length}');
      print('   Benefits count: ${_benefits.length}');
      
    } catch (e) {
      print('❌ Error initializing EditServiceScreen: $e');
      // Set default values jika error
      _selectedCategory = 'grooming';
      _isActive = true;
      _selectedColor = '#FF6B35';
      _selectedIcon = 'spa';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _suitableForController.dispose();
    super.dispose();
  }
  
  // Tambah/hapus field details dan benefits
  void _addDetailField() => setState(() => _details.add(''));
  void _removeDetailField(int index) => setState(() => _details.length > 1 ? _details.removeAt(index) : null);
  
  void _addBenefitField() => setState(() => _benefits.add(''));
  void _removeBenefitField(int index) => setState(() => _benefits.length > 1 ? _benefits.removeAt(index) : null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
        title: Text(
          'Edit Layanan: ${widget.service.name}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.orangeMedium,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateService,
            color: AppColors.orangeMedium,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _showDeleteDialog,
            color: Colors.red,
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
                    // Basic Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Layanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // ID Layanan (read-only)
                            TextFormField(
                              initialValue: widget.service.id,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'ID Layanan',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Nama Layanan
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Layanan*',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama layanan harus diisi';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Kategori
                            const Text(
                              'Kategori*',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _categories.map((category) {
                                final isSelected = _selectedCategory == category['value'];
                                return ChoiceChip(
                                  label: Text(category['label']!),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category['value']!;
                                    });
                                  },
                                  selectedColor: AppColors.orangeMedium,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Deskripsi
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Deskripsi Layanan*',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deskripsi harus diisi';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Suitable For
                            TextFormField(
                              controller: _suitableForController,
                              decoration: const InputDecoration(
                                labelText: 'Cocok Untuk',
                                border: OutlineInputBorder(),
                                hintText: 'Contoh: Semua jenis anjing dan kucing',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Icon & Color Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ikon & Warna',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Icon Selection
                            const Text(
                              'Pilih Ikon',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _icons.map((iconData) {
                                final isSelected = _selectedIcon == iconData['value'];
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        iconData['icon'] as IconData? ?? Icons.help,
                                        size: 16,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(iconData['label']!),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedIcon = iconData['value']!;
                                    });
                                  },
                                  selectedColor: AppColors.orangeMedium,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Color Selection
                            const Text(
                              'Pilih Warna',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _colors.map((colorData) {
                                final isSelected = _selectedColor == colorData['value'];
                                return ChoiceChip(
                                  label: Container(
                                    width: 80,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: colorData['color'] as Color? ?? Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(colorData['label']!),
                                      ],
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedColor = colorData['value']!;
                                    });
                                  },
                                  selectedColor: AppColors.orangeMedium,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Detail Layanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: _addDetailField,
                                  tooltip: 'Tambah Detail',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Contoh: Pemandian dengan shampoo khusus, Pengeringan dengan handuk',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Dynamic details fields
                            Column(
                              children: List.generate(_details.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _details[index],
                                          onChanged: (value) {
                                            _details[index] = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Detail ${index + 1}',
                                            border: const OutlineInputBorder(),
                                            hintText: 'Masukkan detail layanan',
                                            prefixIcon: const Icon(Icons.check, size: 16),
                                          ),
                                        ),
                                      ),
                                      if (_details.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => _removeDetailField(index),
                                          tooltip: 'Hapus',
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Benefits Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Manfaat Layanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: _addBenefitField,
                                  tooltip: 'Tambah Manfaat',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Contoh: Bersih dan wangi, Bebas kutu dan parasit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Dynamic benefits fields
                            Column(
                              children: List.generate(_benefits.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _benefits[index],
                                          onChanged: (value) {
                                            _benefits[index] = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Manfaat ${index + 1}',
                                            border: const OutlineInputBorder(),
                                            hintText: 'Masukkan manfaat layanan',
                                            prefixIcon: const Icon(Icons.thumb_up, size: 16),
                                          ),
                                        ),
                                      ),
                                      if (_benefits.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => _removeBenefitField(index),
                                          tooltip: 'Hapus',
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pricing & Duration Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Harga & Durasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                // Harga
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Harga (Rp)*',
                                      border: OutlineInputBorder(),
                                      prefixText: 'Rp ',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harga harus diisi';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Harga harus angka';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Durasi (dalam menit)
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Durasi (menit)*',
                                      border: OutlineInputBorder(),
                                      suffixText: 'menit',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Durasi harus diisi';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Durasi harus angka';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Layanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            SwitchListTile(
                              title: const Text(
                                'Status Layanan',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                _isActive 
                                    ? 'Layanan aktif dan tersedia untuk booking'
                                    : 'Layanan tidak aktif dan tidak tersedia untuk booking',
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeColor: AppColors.orangeMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Update button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updateService,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: _isLoading 
                                ? const Text('Menyimpan...')
                                : const Text('Update Layanan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeMedium,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Delete button (danger zone)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _showDeleteDialog,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Hapus Layanan',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Filter details dan benefits
        final String detailsString = _details
            .where((detail) => detail.isNotEmpty)
            .join(' | ');
        
        final String benefitsString = _benefits
            .where((benefit) => benefit.isNotEmpty)
            .join(' | ');
        
        // Update service object
        final updatedService = widget.service.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          price: _priceController.text,
          duration: _durationController.text,
          category: _selectedCategory,
          icon: _selectedIcon,
          color: _selectedColor,
          details: detailsString,
          benefits: benefitsString,
          suitable_for: _suitableForController.text,
          is_active: _isActive ? '1' : '0',
        );
        
        print('🔄 Mengupdate layanan: ${updatedService.name} (ID: ${updatedService.id})');
        
        // Gunakan updateServiceFull
        await _serviceService.updateServiceFull(updatedService);
        
        // PERBAIKAN: Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan "${_nameController.text}" berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // PERBAIKAN: Navigate back dengan data yang diupdate
        // Gunakan Navigator.pop dengan result
        Navigator.of(context).pop({
          'success': true,
          'action': 'updated',
          'service': updatedService,
        });
        
      } catch (e) {
        print('💥 Update error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Tampilkan pesan validasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap perbaiki semua kesalahan pada form'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus layanan "${widget.service.name}"? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _serviceService.deleteService(widget.service.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan "${widget.service.name}" berhasil dihapus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Kembali dengan status deleted
        context.pop({'deleted': true, 'service': widget.service});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}