import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: 'Bagaimana cara membuat booking?',
      answer: '1. Buka menu "Bookings"\n2. Pilih "Buat Booking Baru"\n3. Pilih hewan peliharaan\n4. Pilih layanan dan metode\n5. Pilih tanggal dan waktu\n6. Konfirmasi booking',
    ),
    FAQItem(
      question: 'Apa saja layanan yang tersedia?',
      answer: 'Kami menyediakan 5 jenis layanan:\n- Basic Grooming\n- Premium Grooming\n- Special Package\n- Spa Treatment\n- Medical Grooming\n\nDetail setiap layanan dapat dilihat di menu "Pilihan Layanan"',
    ),
    FAQItem(
      question: 'Berapa lama proses grooming?',
      answer: 'Durasi tergantung jenis layanan:\n- Basic Grooming: 1.5 jam\n- Premium Grooming: 2 jam\n- Special Package: 2.5 jam\n- Spa Treatment: 2 jam\n- Medical Grooming: 3 jam',
    ),
    FAQItem(
      question: 'Bagaimana metode pembayaran?',
      answer: 'Pembayaran dapat dilakukan melalui:\n- Transfer Bank\n- E-wallet (GoPay, OVO, Dana)\n- Kartu Kredit/Debit\n- Cash saat penjemputan',
    ),
    FAQItem(
      question: 'Apakah ada garansi layanan?',
      answer: 'Ya, kami memberikan garansi 3 hari untuk layanan grooming. Jika ada masalah dengan hasil grooming, silakan hubungi customer service kami.',
    ),
    FAQItem(
      question: 'Bagaimana jika perlu membatalkan booking?',
      answer: 'Pembatalan dapat dilakukan minimal 3 jam sebelum jadwal booking. Untuk pembatalan mendesak, hubungi customer service kami.',
    ),
    FAQItem(
      question: 'Apa syarat untuk Medical Grooming?',
      answer: 'Untuk Medical Grooming:\n1. Surat keterangan dokter hewan\n2. Riwayat kesehatan hewan\n3. Konsultasi awal dengan groomer kami',
    ),
    FAQItem(
      question: 'Apakah melayani hewan selain anjing dan kucing?',
      answer: 'Saat ini kami hanya melayani grooming untuk anjing dan kucing. Untuk hewan lain, silakan konsultasi terlebih dahulu.',
    ),
  ];

  // SIMPAN URL SEBAGAI STRING DI MODEL
  final List<ContactItem> contacts = [
    ContactItem(
      icon: Icons.phone,
      title: 'Telepon',
      value: '021-12345678',
      url: 'tel:02112345678',
    ),
    ContactItem(
      icon: Icons.message,
      title: 'WhatsApp',
      value: '+62 812-3456-7890',
      url: 'https://wa.me/6281234567890',
    ),
    ContactItem(
      icon: Icons.email,
      title: 'Email',
      value: 'help@petsalon.com',
      url: 'mailto:help@petsalon.com',
    ),
    ContactItem(
      icon: Icons.location_on,
      title: 'Alamat Salon',
      value: 'Jl. Peternakan No. 123, Jakarta',
      url: 'https://maps.google.com/?q=Jl.+Peternakan+No.+123,+Jakarta',
    ),
  ];

  // SIMPAN URL SEBAGAI STRING DI MODEL
  final List<SupportItem> supportItems = [
    SupportItem(
      icon: Icons.chat,
      title: 'Live Chat',
      subtitle: 'Chat langsung dengan customer service',
      color: AppColors.accentBlue,
      url: null, // Tidak ada URL untuk Live Chat
    ),
    SupportItem(
      icon: Icons.email,
      title: 'Email Support',
      subtitle: 'Kirim email ke tim support kami',
      color: AppColors.accentGreen,
      url: 'mailto:support@petsalon.com',
    ),
    SupportItem(
      icon: Icons.phone,
      title: 'Hotline',
      subtitle: 'Telepon customer service 24/7',
      color: AppColors.accentPink,
      url: 'tel:02112345678',
    ),
    SupportItem(
      icon: Icons.help,
      title: 'FAQ',
      subtitle: 'Pertanyaan yang sering diajukan',
      color: AppColors.accentOrange,
      url: null, // FAQ sudah ditampilkan di bawah
    ),
  ];

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka: $url'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini akan segera hadir!'),
        duration: Duration(seconds: 2),
      ),
    );
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
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Support Options
            _buildSupportSection(),
            const SizedBox(height: 32),

            // Contact Information
            _buildContactSection(),
            const SizedBox(height: 32),

            // FAQ Section
            _buildFAQSection(),
            const SizedBox(height: 20),

            // Report Problem Button
            _buildReportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.homePrimaryGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.homePrimary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pusat Bantuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kami siap membantu Anda 24/7',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dukungan Tersedia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: supportItems.length,
          itemBuilder: (context, index) {
            final item = supportItems[index];
            return _buildSupportCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildSupportCard(SupportItem item) {
    // Tentukan action berdasarkan apakah ada URL atau tidak
    VoidCallback? onTap;
    if (item.url != null) {
      onTap = () => _launchUrl(item.url!);
    } else if (item.title == 'Live Chat') {
      onTap = _showComingSoon;
    } else if (item.title == 'FAQ') {
      onTap = () {
        // Scroll ke FAQ section (bisa diimplementasikan jika perlu)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FAQ sudah ditampilkan di bawah'),
            duration: Duration(seconds: 1),
          ),
        );
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kontak Kami',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: contacts.map((contact) => _buildContactItem(contact)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(ContactItem contact) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          contact.icon,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        contact.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        contact.value,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
        onPressed: () => _launchUrl(contact.url),
      ),
      onTap: () => _launchUrl(contact.url),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Umum (FAQ)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildFAQItem(faqs[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${faqs.indexOf(faq) + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
          child: Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigasi ke halaman report problem atau show dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Laporkan Masalah'),
              content: const Text('Fitur pelaporan masalah akan segera hadir!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.error.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_problem, size: 20),
            SizedBox(width: 8),
            Text(
              'Laporkan Masalah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class ContactItem {
  final IconData icon;
  final String title;
  final String value;
  final String url; // SIMPAN URL SEBAGAI STRING

  ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.url,
  });
}

class SupportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? url; // URL OPSIONAL, BISA NULL

  SupportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.url,
  });
}