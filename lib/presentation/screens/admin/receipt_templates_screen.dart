// lib/presentation/screens/admin/settings/receipt_templates_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';

class ReceiptTemplatesScreen extends StatefulWidget {
  const ReceiptTemplatesScreen({super.key});

  @override
  State<ReceiptTemplatesScreen> createState() => _ReceiptTemplatesScreenState();
}

class _ReceiptTemplatesScreenState extends State<ReceiptTemplatesScreen> {
  String _selectedTemplate = 'default';
  
  final Map<String, dynamic> _templateSettings = {
    'showLogo': true,
    'showQR': true,
    'showThankYou': true,
    'footerText': 'Terima kasih atas kunjungan Anda!',
    'fontSize': 12.0,
  };

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
          'Template Nota/Struk',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewTemplate,
            color: AppColors.orangeMedium,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
            color: AppColors.orangeMedium,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template selection
            _buildTemplateSelection(),
            
            const SizedBox(height: 24),
            
            // Template settings
            _buildTemplateSettings(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTemplate,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeMedium,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Template',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTemplateOption('default', 'Default'),
                _buildTemplateOption('modern', 'Modern'),
                _buildTemplateOption('simple', 'Simple'),
                _buildTemplateOption('professional', 'Professional'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedTemplate == value,
      onSelected: (selected) {
        setState(() {
          _selectedTemplate = value;
        });
      },
      selectedColor: AppColors.orangeMedium,
      labelStyle: TextStyle(
        color: _selectedTemplate == value ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTemplateSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Template',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSettingToggle(
              label: 'Tampilkan Logo',
              value: _templateSettings['showLogo'],
              onChanged: (value) => setState(() => _templateSettings['showLogo'] = value),
            ),
            _buildSettingToggle(
              label: 'Tampilkan QR Code',
              value: _templateSettings['showQR'],
              onChanged: (value) => setState(() => _templateSettings['showQR'] = value),
            ),
            _buildSettingToggle(
              label: 'Tampilkan Ucapan Terima Kasih',
              value: _templateSettings['showThankYou'],
              onChanged: (value) => setState(() => _templateSettings['showThankYou'] = value),
            ),
            
            const SizedBox(height: 16),
            
            // Footer text
            const Text(
              'Teks Footer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _templateSettings['footerText']),
              onChanged: (value) => _templateSettings['footerText'] = value,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan teks footer...',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Font size
            const Text(
              'Ukuran Font',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _templateSettings['fontSize'],
              min: 10,
              max: 16,
              divisions: 6,
              onChanged: (value) => setState(() => _templateSettings['fontSize'] = value),
              activeColor: AppColors.orangeMedium,
            ),
            Text(
              '${_templateSettings['fontSize'].toStringAsFixed(1)} pt',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orangeMedium,
          ),
        ],
      ),
    );
  }

  void _previewTemplate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Template'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Template preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text('PREVIEW NOTA/STRUK'),
                    SizedBox(height: 16),
                    Text('Isi preview template akan ditampilkan di sini'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }
}