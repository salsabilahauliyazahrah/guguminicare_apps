// lib/presentation/screens/admin/drivers/add_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  
  String _selectedStatus = 'active';
  
  // Variabel untuk menyimpan file yang diupload
  Map<String, String> _uploadedDocuments = {
    'ktp': '',
    'sim': '',
    'foto': '',
  };

  // Progress upload
  Map<String, double> _uploadProgress = {
    'ktp': 0.0,
    'sim': 0.0,
    'foto': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Driver Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDriver,
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
              // Informasi Pribadi
              _buildSectionHeader('Informasi Pribadi'),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                isRequired: true,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                isRequired: true,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Alamat',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _idCardController,
                label: 'No. KTP',
                icon: Icons.badge,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 24),
              
              // Kendaraan
              _buildSectionHeader('Informasi Kendaraan'),
              _buildTextField(
                controller: _vehicleController,
                label: 'Jenis Kendaraan',
                icon: Icons.directions_car,
              ),
              _buildTextField(
                controller: _plateController,
                label: 'Nomor Plat',
                icon: Icons.confirmation_number,
                hint: 'B 1234 ABC',
              ),
              
              const SizedBox(height: 24),
              
              // Status
              _buildSectionHeader('Status Driver'),
              _buildStatusSelector(),
              
              const SizedBox(height: 32),
              
              // Upload Dokumen - PERUBAHAN: Ganti button dengan status
              _buildSectionHeader('Dokumen'),
              _buildDocumentStatus('ktp'),
              _buildDocumentStatus('sim'),
              _buildDocumentStatus('foto'),
              
              const SizedBox(height: 16),
              
              // Tombol Upload (opsional)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _uploadDocument('ktp'),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload KTP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _uploadDocument('sim'),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload SIM'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _uploadDocument('foto'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Upload Foto Driver'),
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeMedium,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Data Driver'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          hintText: hint,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Aktif'),
          selected: _selectedStatus == 'active',
          selectedColor: Colors.green.withOpacity(0.2),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedStatus = 'active';
              });
            }
          },
        ),
        ChoiceChip(
          label: const Text('Offline'),
          selected: _selectedStatus == 'inactive',
          selectedColor: Colors.grey.withOpacity(0.2),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedStatus = 'inactive';
              });
            }
          },
        ),
        ChoiceChip(
          label: const Text('Cuti'),
          selected: _selectedStatus == 'leave',
          selectedColor: Colors.blue.withOpacity(0.2),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedStatus = 'leave';
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDocumentStatus(String type) {
    final hasDocument = _uploadedDocuments[type]!.isNotEmpty;
    final progress = _uploadProgress[type]!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: hasDocument ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasDocument ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument ? Icons.check_circle : Icons.circle,
            color: hasDocument ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDocumentTypeName(type),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: hasDocument ? Colors.green[800] : Colors.grey[800],
                  ),
                ),
                if (!hasDocument && progress > 0)
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                  ),
                if (hasDocument)
                  Text(
                    path.basename(_uploadedDocuments[type]!),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (hasDocument)
            IconButton(
              icon: const Icon(Icons.visibility, size: 20),
              onPressed: () => _showFilePreview(
                type, 
                File(_uploadedDocuments[type]!)
              ),
            ),
        ],
      ),
    );
  }

  void _uploadDocument(String type) async {
    print('Upload document called for: $type');
    
    // Debug: Cek permission status
    print('Camera status: ${await Permission.camera.status}');
    print('Storage status: ${await Permission.storage.status}');
    print('Photos status: ${await Permission.photos.status}');
    
    // Tampilkan pilihan sumber file
    _showUploadSourceDialog(type);
  }
  
  void _showUploadSourceDialog(String type) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera(type);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery(type);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.purple),
                title: const Text('Pilih File Dokumen'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentFile(type);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera(String type) async {
    try {
      // Cek izin kamera - PERBAIKAN: Gunakan status yang benar
      final cameraStatus = await Permission.camera.status;
      
      if (!cameraStatus.isGranted) {
        final requested = await Permission.camera.request();
        if (!requested.isGranted) {
          _showPermissionDeniedDialog('kamera');
          return;
        }
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (image != null) {
        await _processAndUploadFile(type, File(image.path));
      }
    } catch (e) {
      print('Error camera: $e');
      _showErrorDialog('Gagal membuka kamera: $e');
    }
  }

  Future<void> _pickImageFromGallery(String type) async {
    try {
      // Untuk Android & iOS yang berbeda
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        status = PermissionStatus.granted;
      }
      
      if (!status.isGranted) {
        _showPermissionDeniedDialog('galeri foto');
        return;
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (image != null) {
        await _processAndUploadFile(type, File(image.path));
      }
    } catch (e) {
      print('Error gallery: $e');
      _showErrorDialog('Gagal membuka galeri: $e');
    }
  }

  Future<void> _pickDocumentFile(String type) async {
    try {
      // Permission untuk file picker
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        // iOS butuh permission khusus
        status = PermissionStatus.granted; // iOS biasanya tidak butuh permission untuk file picker
      } else {
        status = PermissionStatus.granted;
      }
      
      if (!status.isGranted) {
        _showPermissionDeniedDialog('penyimpanan');
        return;
      }
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.path != null) {
          await _processAndUploadFile(type, File(file.path!));
        } else {
          _showErrorDialog('Path file tidak valid');
        }
      }
    } catch (e) {
      print('Error file picker: $e');
      _showErrorDialog('Gagal memilih file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processAndUploadFile(String type, File file) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Memproses File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeMedium),
            ),
            const SizedBox(height: 16),
            Text(
              'Menyiapkan ${_getDocumentTypeName(type)}...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // 1. Kompresi gambar (jika file gambar dan ukuran > 2MB)
      File processedFile = file;
      if (file.path.toLowerCase().endsWith('.jpg') || 
          file.path.toLowerCase().endsWith('.jpeg') || 
          file.path.toLowerCase().endsWith('.png')) {
        
        final fileSize = await file.length();
        if (fileSize > 2 * 1024 * 1024) { // 2MB
          processedFile = await _compressImage(file);
        }
      }

      // 2. Upload ke server (simulasi)
      await _uploadToServer(type, processedFile);
      
      // 3. Tutup loading dialog
      if (context.mounted) Navigator.pop(context);
      
      // 4. Tampilkan notifikasi sukses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentTypeName(type)} berhasil diupload'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 5. Simpan path file
      setState(() {
        _uploadedDocuments[type] = processedFile.path;
      });

      // 6. Tampilkan preview file
      if (context.mounted) {
        _showFilePreview(type, processedFile);
      }

    } catch (e) {
      // Tutup loading dialog jika error
      if (context.mounted) Navigator.pop(context);
      
      // Tampilkan error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<File> _compressImage(File originalFile) async {
    // Simulasi kompresi gambar
    // Untuk implementasi nyata, gunakan package seperti 'flutter_image_compress'
    return originalFile;
  }

  Future<void> _uploadToServer(String type, File file) async {
    // Tampilkan progress dialog
    bool isUploading = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Simulasi upload progress
          Future.delayed(const Duration(milliseconds: 100), () {
            if (isUploading) {
              setStateDialog(() {
                _uploadProgress[type] = (_uploadProgress[type]! + 0.1).clamp(0.0, 1.0);
              });
            }
          });
          
          return AlertDialog(
            title: Text('Upload ${_getDocumentTypeName(type)}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: _uploadProgress[type],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeMedium),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_uploadProgress[type]! * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_getFileSize(file)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      // Upload ke server (simulasi)
      await Future.delayed(const Duration(seconds: 2));
      
      // Set progress ke 100%
      setState(() {
        _uploadProgress[type] = 1.0;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      isUploading = false;
      
      if (context.mounted) Navigator.pop(context);
      
    } catch (e) {
      isUploading = false;
      if (context.mounted) Navigator.pop(context);
      rethrow;
    }
  }

  void _showFilePreview(String type, File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview ${_getDocumentTypeName(type)}'),
        content: Container(
          height: 300,
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: file.path.toLowerCase().endsWith('.pdf')
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('File PDF'),
                    Text('Tidak dapat menampilkan preview PDF'),
                  ],
                )
              : Image.file(file, fit: BoxFit.contain),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Hapus file
              setState(() {
                _uploadedDocuments[type] = '';
                _uploadProgress[type] = 0.0;
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getDocumentTypeName(type)} dihapus'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getDocumentTypeName(type)} sudah diupload'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gunakan File Ini'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: Text(
          'Aplikasi memerlukan akses $permission untuk mengupload dokumen. '
          'Silakan berikan izin di pengaturan perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  String _getDocumentTypeName(String type) {
    switch (type) {
      case 'ktp': return 'KTP';
      case 'sim': return 'SIM';
      case 'foto': return 'Foto Driver';
      default: return type.toUpperCase();
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  void _saveDriver() {
    if (_formKey.currentState!.validate()) {
      // Cek apakah dokumen sudah diupload
      final requiredDocs = ['ktp', 'sim', 'foto'];
      final missingDocs = requiredDocs.where((doc) => _uploadedDocuments[doc]!.isEmpty).toList();
      
      if (missingDocs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harap upload: ${missingDocs.map(_getDocumentTypeName).join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simpan data driver
      final newDriver = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text.isEmpty 
            ? '${_nameController.text.replaceAll(' ', '.').toLowerCase()}@gugumini.com'
            : _emailController.text,
        'vehicle': _vehicleController.text.isNotEmpty && _plateController.text.isNotEmpty
            ? '${_vehicleController.text} - ${_plateController.text}'
            : _vehicleController.text.isNotEmpty
                ? _vehicleController.text
                : 'Kendaraan Pribadi',
        'status': _selectedStatus,
        'status_text': _selectedStatus == 'active' ? 'Aktif' : 
                      _selectedStatus == 'inactive' ? 'Offline' : 'Cuti',
        'status_color': _selectedStatus == 'active' ? Colors.green :
                       _selectedStatus == 'inactive' ? Colors.grey : Colors.blue,
        'address': _addressController.text,
        'id_card': _idCardController.text,
        'documents': _uploadedDocuments,
        'assigned_tasks': 0,
        'completed_tasks': 0,
        'rating': 4.0,
        'total_trips': 0,
        'join_date': DateTime.now(),
      };
      
      // Kirim data ke backend atau simpan lokal
      print('Driver baru: $newDriver');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Driver berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Kembali ke halaman sebelumnya dengan data driver baru
      Navigator.pop(context, newDriver);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleController.dispose();
    _plateController.dispose();
    _addressController.dispose();
    _idCardController.dispose();
    super.dispose();
  }
}