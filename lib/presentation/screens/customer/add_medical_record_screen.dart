import 'package:flutter/material.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final Map<String, dynamic> petData;
  
  const AddMedicalRecordScreen({
    super.key,
    required this.petData,
  });

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Form data
  String _recordType = 'pemeriksaan'; // pemeriksaan, vaksinasi, operasi, rutin
  String _title = '';
  String _description = '';
  String _doctor = '';
  String _clinic = '';
  String _notes = '';
  String _followUp = '';
  double _cost = 0;
  
  // Medications
  final List<Map<String, String>> _medications = [];
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();

  // Record types
  final List<String> _recordTypes = [
    'pemeriksaan',
    'vaksinasi', 
    'operasi',
    'rutin',
    'darurat'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd MMMM yyyy').format(DateTime.now());
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _medNameController.dispose();
    _medDosageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  void _addMedication() {
    if (_medNameController.text.isNotEmpty && _medDosageController.text.isNotEmpty) {
      setState(() {
        _medications.add({
          'name': _medNameController.text,
          'dosage': _medDosageController.text,
        });
        _medNameController.clear();
        _medDosageController.clear();
      });
    }
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': _selectedDate?.toIso8601String().split('T')[0] ?? '',
        'title': _title,
        'description': _description,
        'doctor': _doctor,
        'clinic': _clinic,
        'notes': _notes,
        'followUp': _followUp,
        'medications': List.from(_medications),
        'isVaccine': _recordType == 'vaksinasi',
        'isSurgery': _recordType == 'operasi',
        'isRoutine': _recordType == 'rutin',
        'cost': _cost,
      };

      // TODO: Save to database/state management
      print('New medical record added: $newRecord');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan medis berhasil ditambahkan untuk ${widget.petData['name']}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back
      Navigator.of(context).pop(newRecord);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Catatan Medis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.petData['name'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
              ),
            ),
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
              // Pet Info Card
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.petData['photo']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.petData['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.petData['breed']} • ${widget.petData['age']} tahun',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (widget.petData['medical_notes'] != null)
                            Text(
                              widget.petData['medical_notes'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Date Selection
              _buildFormField(
                label: 'Tanggal *',
                hintText: 'Pilih tanggal',
                icon: Icons.calendar_today,
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Record Type
              _buildDropdownField(
                label: 'Jenis Catatan *',
                value: _recordType,
                items: _recordTypes,
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _recordType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Title
              _buildFormField(
                label: 'Judul / Jenis Perawatan *',
                hintText: 'Contoh: Vaksinasi Rabies, Pemeriksaan Kulit',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Description
              _buildFormField(
                label: 'Deskripsi Singkat',
                hintText: 'Deskripsi perawatan yang diberikan',
                icon: Icons.description,
                maxLines: 2,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),

              // Doctor & Clinic
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Dokter',
                      hintText: 'Nama dokter',
                      icon: Icons.person,
                      onSaved: (value) => _doctor = value ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'Klinik / Rumah Sakit',
                      hintText: 'Nama klinik',
                      icon: Icons.local_hospital,
                      onSaved: (value) => _clinic = value ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Medical Notes
              _buildFormField(
                label: 'Catatan Medis Detail *',
                hintText: 'Keterangan kondisi, diagnosis, dan tindakan yang dilakukan',
                icon: Icons.notes,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Catatan medis harus diisi';
                  }
                  return null;
                },
                onSaved: (value) => _notes = value!,
              ),
              const SizedBox(height: 16),

              // Follow Up Instructions
              _buildFormField(
                label: 'Instruksi Tindak Lanjut',
                hintText: 'Instruksi untuk perawatan di rumah, kontrol ulang, dll.',
                icon: Icons.next_plan,
                maxLines: 3,
                onSaved: (value) => _followUp = value ?? '',
              ),
              const SizedBox(height: 16),

              // Medications Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medication, color: Colors.blue[400]),
                        const SizedBox(width: 8),
                        const Text(
                          'Obat yang Diberikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Medications List
                    if (_medications.isNotEmpty)
                      Column(
                        children: _medications.asMap().entries.map((entry) {
                          final index = entry.key;
                          final medication = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medication['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        medication['dosage']!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeMedication(index),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    // Add Medication Form
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _medNameController,
                            decoration: InputDecoration(
                              hintText: 'Nama obat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _medDosageController,
                            decoration: InputDecoration(
                              hintText: 'Dosis',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addMedication,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan obat yang diberikan selama perawatan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Catatan Medis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    int? maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey[500]),
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey[500]),
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'pemeriksaan':
                  displayText = 'Pemeriksaan';
                  break;
                case 'vaksinasi':
                  displayText = 'Vaksinasi';
                  break;
                case 'operasi':
                  displayText = 'Operasi';
                  break;
                case 'rutin':
                  displayText = 'Perawatan Rutin';
                  break;
                case 'darurat':
                  displayText = 'Darurat';
                  break;
                default:
                  displayText = value;
              }
              
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}