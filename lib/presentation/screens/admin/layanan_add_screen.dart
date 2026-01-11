import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';
import 'package:tugas_akhir/presentation/screens/services/layanan_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _suitableForController = TextEditingController();
  
  // Form state
  String _selectedCategory = 'grooming';
  bool _isActive = true;
  String _selectedColor = '#FF6B35'; // Default orange
  String _selectedIcon = 'cleaning_services';
  
  bool _isLoading = false;

  // Untuk multiple details dan benefits
  List<String> _details = ['', '']; // 2 input kosong
  List<String> _benefits = ['', '']; // 2 input kosong
  
  // Categories
  final List<Map<String, String>> _categories = [
    {'value': 'grooming', 'label': 'Grooming'},
    {'value': 'spa', 'label': 'Spa'},
    {'value': 'paket', 'label': 'Paket'},
    {'value': 'medis', 'label': 'Medis'},
  ];
  
  // Icons pilihan - PERBAIKAN TIPE DATA
  final List<Map<String, dynamic>> _icons = [  // Ubah dari <String, String> ke <String, dynamic>
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _suitableForController.dispose();
    super.dispose();
  }
  
  // Tambah input detail
  void _addDetailField() {
    setState(() {
      _details.add('');
    });
  }
  
  // Hapus input detail
  void _removeDetailField(int index) {
    setState(() {
      if (_details.length > 1) {
        _details.removeAt(index);
      }
    });
  }
  
  // Tambah input benefit
  void _addBenefitField() {
    setState(() {
      _benefits.add('');
    });
  }
  
  // Hapus input benefit
  void _removeBenefitField(int index) {
    setState(() {
      if (_benefits.length > 1) {
        _benefits.removeAt(index);
      }
    });
  }

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
        title: const Text(
          'Tambah Layanan Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveService,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      
                      // Nama Layanan
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Layanan*',
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Premium Grooming',
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
                          hintText: 'Jelaskan detail layanan yang ditawarkan',
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
                                hintText: '180000',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harga harus diisi';
                                }
                                if (int.tryParse(value) == null) {
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
                                hintText: '90',
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
                      
                      const SizedBox(height: 8),
                      const Text(
                        'Durasi dalam menit (contoh: 90 menit = 1.5 jam)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
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
                          'Aktifkan Layanan',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: const Text(
                          'Layanan akan muncul di daftar layanan yang tersedia',
                          style: TextStyle(fontSize: 14),
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
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveService,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Layanan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  // Di _saveService():
  void _saveService() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Bersihkan newline characters dari semua input
        final cleanedName = _nameController.text.replaceAll('\n', ' ').trim();
        final cleanedDesc = _descriptionController.text.replaceAll('\n', ' ').trim();
        final cleanedSuitableFor = _suitableForController.text.replaceAll('\n', ' ').trim();
        
        // Convert details dan benefits
        final detailsString = _details
            .where((detail) => detail.trim().isNotEmpty)
            .map((detail) => detail.replaceAll('\n', ' ').trim())
            .join(' | ');
        
        final benefitsString = _benefits
            .where((benefit) => benefit.trim().isNotEmpty)
            .map((benefit) => benefit.replaceAll('\n', ' ').trim())
            .join(' | ');
        
        print('🔍 Data sebelum dikirim:');
        print('   Name: $cleanedName');
        print('   Description: $cleanedDesc');
        print('   Price: ${_priceController.text}');
        print('   Duration: ${_durationController.text}');
        print('   Details: $detailsString');
        print('   Benefits: $benefitsString');
        
        // Buat service dengan data yang sudah dibersihkan
        final newService = ServiceModel(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          name: cleanedName,
          description: cleanedDesc,
          price: _priceController.text,
          duration: _durationController.text,
          category: _selectedCategory,
          icon: _selectedIcon,
          color: _selectedColor,
          details: detailsString,
          benefits: benefitsString,
          suitable_for: cleanedSuitableFor,
          is_active: _isActive ? '1' : '0',
          created_at: DateTime.now().toIso8601String().split('.')[0], // Tanpa milidetik
        );
        
        // Gunakan method yang sudah diperbaiki
        final serviceService = ServiceService();
        final createdService = await serviceService.createService(newService);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan "$cleanedName" berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop(createdService);
        
      } catch (e) {
        print('❌ Error details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}