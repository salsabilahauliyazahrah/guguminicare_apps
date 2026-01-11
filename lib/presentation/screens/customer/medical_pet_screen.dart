import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class MedicalNotesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> petData;
  final Map<String, dynamic>? initialRecord;
  
  const MedicalNotesDetailScreen({
    super.key,
    required this.petData,
    this.initialRecord,
  });

  @override
  State<MedicalNotesDetailScreen> createState() => _MedicalNotesDetailScreenState();
}

class _MedicalNotesDetailScreenState extends State<MedicalNotesDetailScreen> {
  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'id': '1',
      'date': '2024-03-15',
      'title': 'Vaksinasi Tahunan',
      'description': 'Vaksinasi rabies dan DHPPiL',
      'doctor': 'Dr. Andi Wijaya',
      'clinic': 'Klinik Hewan Sejahtera',
      'notes': 'Hewan dalam kondisi sehat. Tidak ada reaksi alergi terhadap vaksin. Temperatur normal, nafsu makan baik.',
      'followUp': 'Kontrol 1 tahun lagi untuk vaksinasi booster',
      'medications': [
        {'name': 'Vaksin Rabies', 'dosage': '1 dosis'},
        {'name': 'Vaksin DHPPiL', 'dosage': '1 dosis'},
        {'name': 'Vitamin B Complex', 'dosage': '1 ml'},
      ],
      'attachments': ['vaksin_certificate.pdf'],
      'isVaccine': true,
      'isSurgery': false,
      'isRoutine': true,
      'cost': 250000,
    },
    {
      'id': '2',
      'date': '2024-02-28',
      'title': 'Pemeriksaan Kulit',
      'description': 'Kontrol alergi kulit',
      'doctor': 'Dr. Sari Dewi',
      'clinic': 'Animal Care Center',
      'notes': 'Kulit masih sensitif dengan tanda-tanda kemerahan dan gatal. Ditemukan sedikit infeksi bakteri sekunder.',
      'followUp': 'Gunakan salep 2x sehari selama 2 minggu. Kontrol ulang jika gejala tidak membaik.',
      'medications': [
        {'name': 'Salep Antibiotik', 'dosage': 'Oles tipis 2x sehari'},
        {'name': 'Omega-3 Supplement', 'dosage': '1 kapsul sehari'},
        {'name': 'Antihistamin', 'dosage': '1/2 tablet 1x sehari'},
      ],
      'attachments': ['skin_test_results.pdf'],
      'isVaccine': false,
      'isSurgery': false,
      'isRoutine': false,
      'cost': 175000,
    },
    {
      'id': '3',
      'date': '2024-01-10',
      'title': 'Sterilisasi',
      'description': 'Operasi sterilisasi',
      'doctor': 'Dr. Budi Santoso',
      'clinic': 'Rumah Sakit Hewan Jakarta',
      'notes': 'Operasi berjalan lancar selama 45 menit. Pasien sadar dengan baik setelah operasi. Tidak ada komplikasi.',
      'followUp': 'Kontrol jahitan setelah 7 hari. Hindari aktivitas berat selama 2 minggu.',
      'medications': [
        {'name': 'Antibiotik', 'dosage': '1 tablet 2x sehari selama 7 hari'},
        {'name': 'Pain Killer', 'dosage': '1/2 tablet 1x sehari jika perlu'},
        {'name': 'Salep Antibiotik', 'dosage': 'Oles pada jahitan 2x sehari'},
      ],
      'attachments': ['surgery_report.pdf', 'lab_results.pdf', 'consent_form.pdf'],
      'isVaccine': false,
      'isSurgery': true,
      'isRoutine': false,
      'cost': 850000,
    },
  ];

  final List<Map<String, dynamic>> _allergies = [
    {
      'id': '1',
      'name': 'Antibiotik tertentu',
      'severity': 'Tinggi',
      'symptoms': 'Muntah, diare, ruam kulit, sesak nafas',
      'notes': 'Hindari penicillin dan turunannya. Jika terjadi reaksi, segera bawa ke klinik.',
      'discovered': '2023-05-15',
      'doctor': 'Dr. Andi Wijaya',
    },
    {
      'id': '2',
      'name': 'Makanan laut',
      'severity': 'Sedang',
      'symptoms': 'Gatal-gatal, mata berair, muntah ringan',
      'notes': 'Terutama udang dan kerang. Ikan masih bisa ditoleransi dalam jumlah kecil.',
      'discovered': '2023-08-22',
      'doctor': 'Dr. Sari Dewi',
    },
    {
      'id': '3',
      'name': 'Serbuk sari',
      'severity': 'Rendah',
      'symptoms': 'Bersin-bersin, mata merah',
      'notes': 'Hanya terjadi di musim tertentu',
      'discovered': '2024-01-10',
      'doctor': 'Dr. Budi Santoso',
    },
  ];

  final List<Map<String, dynamic>> _medications = [
    {
      'id': '1',
      'name': 'Vitamin Skin Care',
      'dosage': '1 tablet sehari',
      'frequency': 'Setelah makan pagi',
      'duration': '30 hari',
      'purpose': 'Kesehatan kulit dan bulu',
      'startDate': '2024-02-28',
      'endDate': '2024-03-29',
      'doctor': 'Dr. Sari Dewi',
      'notes': 'Meningkatkan kelembaban kulit dan mengurangi gatal',
    },
    {
      'id': '2',
      'name': 'Salep Anti Gatal',
      'dosage': 'Oles tipis',
      'frequency': '2x sehari (pagi & malam)',
      'duration': '14 hari',
      'purpose': 'Mengurangi gatal pada kulit',
      'startDate': '2024-02-28',
      'endDate': '2024-03-13',
      'doctor': 'Dr. Sari Dewi',
      'notes': 'Oleskan pada area yang gatal. Hindari mata dan mulut.',
    },
    {
      'id': '3',
      'name': 'Omega-3 Supplement',
      'dosage': '1 kapsul',
      'frequency': 'Setiap hari',
      'duration': 'Berkelanjutan',
      'purpose': 'Kesehatan kulit dan sendi',
      'startDate': '2024-01-15',
      'endDate': '-',
      'doctor': 'Dr. Andi Wijaya',
      'notes': 'Membantu mengurangi peradangan kulit',
    },
  ];

  String _selectedTab = 'records';
  final List<String> _tabs = ['records', 'allergies', 'medications'];

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
            Text(
              widget.petData['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'Catatan Medis',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(
                '/add-medical-record',
                extra: widget.petData,
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: _tabs.map((tab) {
                return Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getTabLabel(tab),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedTab == tab 
                                ? FontWeight.w700 
                                : FontWeight.w500,
                            color: _selectedTab == tab
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_selectedTab == tab)
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Konten berdasarkan tab
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'records':
        return _buildRecordsContent();
      case 'allergies':
        return _buildAllergiesContent();
      case 'medications':
        return _buildMedicationsContent();
      default:
        return _buildRecordsContent();
    }
  }

  Widget _buildRecordsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_medicalRecords.length} Catatan Medis',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir diperbarui: ${_getLastUpdate()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Records List
        Column(
          children: _medicalRecords.map((record) {
            return _buildMedicalRecordCard(record);
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(DateTime.parse(record['date']));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewRecordDetail(record),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRecordColor(record),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getRecordIcon(record),
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  record['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Doctor & Clinic
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      record['doctor'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_hospital, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      record['clinic'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Cost
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Rp ${NumberFormat('#,###').format(record['cost'])}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),

                // Medications Preview
                if (record['medications'] != null && record['medications'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: record['medications'].take(2).map<Widget>((med) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Text(
                            '${med['name']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergiesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_allergies.length} Alergi Tercatat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pastikan informasi ini diketahui oleh groomer/dokter hewan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Allergies List
        Column(
          children: _allergies.map((allergy) {
            return _buildAllergyDetailCard(allergy);
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAllergyDetailCard(Map<String, dynamic> allergy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(allergy['severity']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning,
                      size: 18,
                      color: _getSeverityColor(allergy['severity']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      allergy['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(allergy['severity']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getSeverityColor(allergy['severity']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      allergy['severity'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getSeverityColor(allergy['severity']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Symptoms
              Text(
                'Gejala:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                allergy['symptoms'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              Text(
                'Catatan:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                allergy['notes'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Doctor & Date
              Row(
                children: [
                  Icon(Icons.person, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    allergy['doctor'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ditemukan: ${DateFormat('dd MMM yyyy').format(DateTime.parse(allergy['discovered']))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.medication, color: Colors.blue[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_medications.length} Obat Rutin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pastikan jadwal pemberian obat tepat waktu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Medications List
        Column(
          children: _medications.map((medication) {
            return _buildMedicationDetailCard(medication);
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMedicationDetailCard(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      medication['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (medication['endDate'] != '-')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Dosage & Frequency
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dosis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          medication['dosage'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frekuensi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          medication['frequency'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Duration
              Text(
                'Durasi: ${medication['duration']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Purpose
              Text(
                'Tujuan: ${medication['purpose']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              if (medication['notes'] != null && medication['notes'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication['notes'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

              // Doctor & Dates
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      medication['doctor'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Mulai: ${DateFormat('dd MMM yyyy').format(DateTime.parse(medication['startDate']))}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Functions
  String _getTabLabel(String tab) {
    switch (tab) {
      case 'records':
        return 'Riwayat';
      case 'allergies':
        return 'Alergi';
      case 'medications':
        return 'Obat';
      default:
        return 'Riwayat';
    }
  }

  String _getLastUpdate() {
    if (_medicalRecords.isEmpty) return 'Belum ada catatan';
    
    final latestRecord = _medicalRecords.reduce((a, b) {
      return DateTime.parse(a['date']).isAfter(DateTime.parse(b['date'])) ? a : b;
    });
    
    final dateFormat = DateFormat('dd MMMM yyyy');
    return dateFormat.format(DateTime.parse(latestRecord['date']));
  }

  Color _getRecordColor(Map<String, dynamic> record) {
    if (record['isVaccine']) return Colors.green;
    if (record['isSurgery']) return Colors.red;
    if (record['isRoutine']) return Colors.blue;
    return Colors.orange;
  }

  IconData _getRecordIcon(Map<String, dynamic> record) {
    if (record['isVaccine']) return Icons.medical_services;
    if (record['isSurgery']) return Icons.healing;
    if (record['isRoutine']) return Icons.assignment;
    return Icons.local_hospital;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'tinggi':
        return Colors.red;
      case 'sedang':
        return Colors.orange;
      case 'rendah':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  // ignore: unused_element
  void _addNewRecord() {
    // TODO: Implement add new medical record
    print('Add new medical record');
  }

  void _viewRecordDetail(Map<String, dynamic> record) {
    // TODO: Implement view record detail
    print('View record detail: ${record['title']}');
  }
}