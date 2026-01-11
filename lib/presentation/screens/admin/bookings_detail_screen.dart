import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  
  const AdminBookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<AdminBookingDetailScreen> createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  // ignore: unused_field
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm');
  
  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Booking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editBooking(booking),
            tooltip: 'Edit Booking',
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Colors.green),
            onPressed: () => _printReceipt(booking),
            tooltip: 'Cetak Nota',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) => _handleMenuAction(value, booking),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Hubungi Customer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'chat',
                child: Row(
                  children: [
                    Icon(Icons.chat, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Kirim Pesan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 18, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Bagikan Detail'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Booking'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(booking),
            
            const SizedBox(height: 20),
            
            // Booking Information Section
            _buildSection(
              title: 'Informasi Booking',
              icon: Icons.calendar_today,
              children: [
                _buildInfoRow(
                  icon: Icons.confirmation_number,
                  label: 'ID Booking',
                  value: booking['id'],
                  showCopy: true,
                ),
                _buildInfoRow(
                  icon: Icons.calendar_month,
                  label: 'Tanggal & Waktu',
                  value: '${_dateFormat.format(booking['date'])} • ${booking['time']}',
                ),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Durasi Perkiraan',
                  value: '2-3 jam',
                  optional: true,
                ),
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Pemesan',
                  value: booking['customer_name'],
                ),
                _buildInfoRow(
                  icon: Icons.pets,
                  label: 'Nama Hewan',
                  value: booking['pet_name'],
                ),
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'Jenis Layanan',
                  value: booking['service'],
                  valueColor: AppColors.orangeMedium,
                ),
                _buildInfoRow(
                  icon: Icons.delivery_dining,
                  label: 'Metode Service',
                  value: booking['method'],
                  badge: _getMethodBadge(booking['method']),
                ),
                if (booking['driver_name'] != null && booking['driver_name'] != '-')
                  _buildInfoRow(
                    icon: Icons.person_pin_circle,
                    label: 'Driver',
                    value: booking['driver_name'],
                    showAction: true,
                    actionIcon: Icons.phone,
                    onAction: () => _callDriver(booking),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Customer Information Section
            _buildSection(
              title: 'Informasi Pelanggan',
              icon: Icons.person,
              children: [
                // Customer Details
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.orangeMedium.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: AppColors.orangeMedium,
                            size: 30,
                          ),
                          radius: 25,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['customer_name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: CUST-001',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.phone, size: 18, color: Colors.blue),
                                    onPressed: () => _callCustomer(booking),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Telepon',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.message, size: 18, color: Colors.green),
                                    onPressed: () => _messageCustomer(booking),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Pesan',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.person, size: 18, color: Colors.purple),
                                    onPressed: () => _viewCustomerProfile(booking),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Profil',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Pet Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getPetColor(booking['pet_type'] ?? 'Kucing').withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getPetIcon(booking['pet_type'] ?? 'Kucing'),
                            color: _getPetColor(booking['pet_type'] ?? 'Kucing'),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['pet_name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${booking['pet_type'] ?? 'Kucing'} • ${booking['pet_breed'] ?? 'Tidak diketahui'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (booking['pet_age'] != null || booking['pet_weight'] != null)
                                const SizedBox(height: 4),
                              if (booking['pet_age'] != null)
                                Text(
                                  'Umur: ${booking['pet_age']} tahun',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (booking['pet_weight'] != null)
                                Text(
                                  'Berat: ${booking['pet_weight']} kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.medical_services, color: Colors.red),
                          onPressed: () => _viewPetMedicalInfo(booking),
                          tooltip: 'Info Medis',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Payment Information Section
            _buildSection(
              title: 'Informasi Pembayaran',
              icon: Icons.payments,
              children: [
                _buildPaymentRow(
                  label: 'Total Tagihan',
                  value: currencyFormat.format(booking['total_price']),
                  isTotal: true,
                ),
                _buildPaymentRow(
                  label: 'Diskon',
                  value: '-',
                  optional: true,
                ),
                _buildPaymentRow(
                  label: 'Biaya Tambahan',
                  value: booking['additional_charges'] != null 
                      ? currencyFormat.format(booking['additional_charges'])
                      : '-',
                  optional: true,
                ),
                _buildPaymentRow(
                  label: 'Pajak (10%)',
                  value: currencyFormat.format((booking['total_price'] * 0.1).toInt()),
                ),
                const Divider(height: 20),
                _buildPaymentRow(
                  label: 'Grand Total',
                  value: currencyFormat.format(booking['total_price'] + (booking['total_price'] * 0.1).toInt()),
                  isTotal: true,
                  isGrandTotal: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentStatusChip(booking['payment_status']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentMethodChip(booking['payment_method']),
                    ),
                  ],
                ),
                if (booking['payment_proof'] != null && booking['payment_status'] == 'pending')
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _viewPaymentProof(booking),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text('Lihat Bukti Pembayaran'),
                              const Spacer(),
                              Icon(Icons.chevron_right, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Notes Section (if any)
            if (booking['notes'] != null && booking['notes'].isNotEmpty)
              _buildSection(
                title: 'Catatan Khusus',
                icon: Icons.note,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      booking['notes'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            
            // Rejection Reason (if rejected)
            if (booking['status'] == 'rejected' && booking['rejection_reason'] != null)
              _buildSection(
                title: 'Alasan Penolakan',
                icon: Icons.cancel,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Text(
                      booking['rejection_reason'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 20),
            
            // History/Log Section
            _buildSection(
              title: 'Riwayat Status',
              icon: Icons.history,
              children: [
                _buildTimelineItem(
                  status: 'Dibuat',
                  time: '${_dateTimeFormat.format(booking['date'])}',
                  icon: Icons.add_circle,
                  color: Colors.blue,
                  isActive: true,
                ),
                _buildTimelineItem(
                  status: booking['status'] == 'pending' ? 'Menunggu Konfirmasi' : 'Diterima',
                  time: booking['status'] == 'pending' ? 'Menunggu...' : '${_dateTimeFormat.format(booking['date'].add(const Duration(minutes: 30)))}',
                  icon: booking['status'] == 'pending' ? Icons.pending : Icons.check_circle,
                  color: booking['status'] == 'pending' ? Colors.orange : Colors.green,
                  isActive: booking['status'] != 'pending',
                ),
                _buildTimelineItem(
                  status: booking['status'] == 'in_progress' ? 'Sedang Diproses' : 'Proses Grooming',
                  time: booking['status'] == 'in_progress' ? 'Sedang berlangsung...' : 'Belum dimulai',
                  icon: Icons.cut,
                  color: booking['status'] == 'in_progress' ? Colors.blue : Colors.grey,
                  isActive: booking['status'] == 'in_progress' || booking['status'] == 'completed',
                ),
                _buildTimelineItem(
                  status: 'Selesai',
                  time: booking['status'] == 'completed' ? '${_dateTimeFormat.format(booking['date'].add(const Duration(hours: 3)))}' : 'Belum selesai',
                  icon: Icons.check_circle_outline,
                  color: booking['status'] == 'completed' ? Colors.purple : Colors.grey,
                  isActive: booking['status'] == 'completed',
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons based on status
            _buildActionButtons(booking),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: booking['status_color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: booking['status_color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: booking['status_color'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(booking['status']),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['status_text'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: booking['status_color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(booking['status']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.orangeMedium),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showCopy = false,
    bool showAction = false,
    IconData? actionIcon,
    VoidCallback? onAction,
    Widget? badge,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: optional ? Colors.grey[400] : AppColors.grey500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: optional ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: valueColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    if (badge != null) badge,
                  ],
                ),
              ],
            ),
          ),
          if (showCopy)
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: Colors.blue),
              onPressed: () => _copyToClipboard(value),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showAction && actionIcon != null)
            IconButton(
              icon: Icon(actionIcon, size: 18, color: Colors.blue),
              onPressed: onAction,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    bool isTotal = false,
    bool isGrandTotal = false,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: optional ? Colors.grey[400] : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              color: isGrandTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    String text;
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'lunas':
        text = 'Lunas';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        text = 'Menunggu';
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'dibatalkan':
        text = 'Dibatalkan';
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        text = status;
        color = Colors.grey;
        icon = Icons.payment;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      avatar: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildPaymentMethodChip(String method) {
    String text;
    Color color;
    IconData icon;
    
    switch (method.toLowerCase()) {
      case 'cod':
        text = 'COD';
        color = Colors.orange;
        icon = Icons.money;
        break;
      case 'transfer bank':
        text = 'Transfer';
        color = Colors.blue;
        icon = Icons.account_balance;
        break;
      case 'qris':
        text = 'QRIS';
        color = Colors.green;
        icon = Icons.qr_code;
        break;
      case 'e-wallet':
        text = 'E-Wallet';
        color = Colors.purple;
        icon = Icons.wallet;
        break;
      default:
        text = method;
        color = Colors.grey;
        icon = Icons.payment;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
      avatar: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildTimelineItem({
    required String status,
    required String time,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.white : Colors.grey[500],
                ),
              ),
              if (!isActive)
                Container(
                  height: 40,
                  width: 2,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? color : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    switch (booking['status']) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _acceptBooking(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text('Terima Booking'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectBooking(booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 20),
                    SizedBox(width: 8),
                    Text('Tolak'),
                  ],
                ),
              ),
            ),
          ],
        );
        
      case 'accepted':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _startGrooming(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 20),
                    SizedBox(width: 8),
                    Text('Mulai Grooming'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rescheduleBooking(booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 8),
                    Text('Reschedule'),
                  ],
                ),
              ),
            ),
          ],
        );
        
      case 'in_progress':
        return ElevatedButton(
          onPressed: () => _completeGrooming(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 20),
              SizedBox(width: 8),
              Text('Selesaikan Grooming'),
            ],
          ),
        );
        
      case 'completed':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _generateReceipt(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt, size: 20),
                    SizedBox(width: 8),
                    Text('Cetak Nota'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rateBooking(booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Beri Rating'),
                  ],
                ),
              ),
            ),
          ],
        );
        
      case 'rejected':
        return ElevatedButton(
          onPressed: () => _reviewRejection(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.replay, size: 20),
              SizedBox(width: 8),
              Text('Tinjau Ulang'),
            ],
          ),
        );
        
      default:
        return Container();
    }
  }

  Widget _getMethodBadge(String method) {
    Color color;
    String text;
    
    switch (method.toLowerCase()) {
      case 'antar jemput':
        color = Colors.blue;
        text = 'Antar Jemput';
        break;
      case 'home service':
        color = Colors.green;
        text = 'Home Service';
        break;
      case 'datang ke salon':
        color = Colors.orange;
        text = 'Datang ke Salon';
        break;
      default:
        color = Colors.grey;
        text = method;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper Methods
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending;
      case 'accepted': return Icons.check_circle;
      case 'in_progress': return Icons.play_circle_fill;
      case 'completed': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel;
      default: return Icons.info;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending': return 'Booking menunggu konfirmasi dari admin';
      case 'accepted': return 'Booking telah diterima dan menunggu proses grooming';
      case 'in_progress': return 'Proses grooming sedang berlangsung';
      case 'completed': return 'Booking telah selesai diproses';
      case 'rejected': return 'Booking telah ditolak';
      default: return 'Status tidak diketahui';
    }
  }

  Color _getPetColor(String type) {
    switch (type.toLowerCase()) {
      case 'kucing': return Colors.orange;
      case 'anjing': return Colors.blue;
      case 'kelinci': return Colors.purple;
      case 'burung': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getPetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kucing': return Icons.pets;
      case 'anjing': return Icons.psychology;
      case 'kelinci': return Icons.health_and_safety;
      case 'burung': return Icons.flight;
      default: return Icons.pets;
    }
  }

  // Action Methods
  void _editBooking(Map<String, dynamic> booking) {
    context.push('/admin/bookings/${booking['id']}/edit', extra: booking);
  }

  void _printReceipt(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cetak Nota'),
        content: const Text('Pilih format nota yang ingin dicetak:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPrint(booking, 'pdf');
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPrint(booking, 'thermal');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeMedium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thermal Printer'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPrint(Map<String, dynamic> booking, String format) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Menyiapkan dokumen...'),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nota ${booking['id']} berhasil dicetak dalam format $format'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> booking) {
    switch (action) {
      case 'call':
        _callCustomer(booking);
        break;
      case 'chat':
        _messageCustomer(booking);
        break;
      case 'share':
        _shareBookingDetails(booking);
        break;
      case 'delete':
        _deleteBooking(booking);
        break;
    }
  }

  Future<void> _callCustomer(Map<String, dynamic> booking) async {
    // Simulate phone call
    final phoneNumber = '081234567890';
    final url = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka aplikasi telepon'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _callDriver(Map<String, dynamic> booking) async {
    final phoneNumber = '081298765432';
    final url = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka aplikasi telepon'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _messageCustomer(Map<String, dynamic> booking) {
    final phoneNumber = '081234567890';
    final message = 'Halo ${booking['customer_name']}, ini dari Pet Grooming Salon mengenai booking ${booking['id']}';
    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    launchUrl(url).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    });
  }

  void _viewCustomerProfile(Map<String, dynamic> booking) {
    // Navigate to customer profile
    context.push('/admin/customers/1'); // Replace with actual customer ID
  }

  void _viewPetMedicalInfo(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Info Medis - ${booking['pet_name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (booking['medical_notes'] != null)
                Text(booking['medical_notes']),
              if (booking['medical_notes'] == null)
                const Text('Tidak ada catatan medis'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _viewPaymentProof(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.receipt, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Transfer Bank - BCA'),
              const Text('Rp 220.000'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verifikasi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks disalin ke clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareBookingDetails(Map<String, dynamic> booking) {
    final shareText = '''
Booking Details - ${booking['id']}
Customer: ${booking['customer_name']}
Pet: ${booking['pet_name']}
Service: ${booking['service']}
Date: ${_dateFormat.format(booking['date'])} ${booking['time']}
Status: ${booking['status_text']}
Total: Rp ${NumberFormat('#,##0').format(booking['total_price'])}
''';
    
    // Show share dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Detail Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(shareText),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () => _copyToClipboard(shareText),
                  tooltip: 'Salin',
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  onPressed: () {},
                  tooltip: 'Bagikan',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _deleteBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Booking'),
        content: const Text('Apakah Anda yakin ingin menghapus booking ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop({'deleted': true});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking['id']} berhasil dihapus'),
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

  // Booking Actions
  void _acceptBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Booking'),
        content: const Text('Apakah Anda yakin ingin menerima booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking['status'] = 'accepted';
                booking['status_text'] = 'Diterima';
                booking['status_color'] = Colors.green;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking['id']} diterima'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(Map<String, dynamic> booking) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap masukkan alasan penolakan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() {
                booking['status'] = 'rejected';
                booking['status_text'] = 'Ditolak';
                booking['status_color'] = Colors.red;
                booking['rejection_reason'] = reasonController.text;
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking['id']} ditolak'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _startGrooming(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Grooming'),
        content: const Text('Apakah Anda ingin memulai proses grooming untuk booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking['status'] = 'in_progress';
                booking['status_text'] = 'Sedang Diproses';
                booking['status_color'] = Colors.blue;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memulai grooming untuk ${booking['id']}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mulai Grooming'),
          ),
        ],
      ),
    );
  }

  void _rescheduleBooking(Map<String, dynamic> booking) {
    // Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur reschedule akan segera tersedia'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeGrooming(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Grooming'),
        content: const Text('Apakah Anda telah menyelesaikan proses grooming untuk booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking['status'] = 'completed';
                booking['status_text'] = 'Selesai';
                booking['status_color'] = Colors.purple;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Grooming selesai untuk ${booking['id']}'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(Map<String, dynamic> booking) {
    _printReceipt(booking);
  }

  void _rateBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Rating'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              const Text('Bagaimana pengalaman grooming kali ini?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < 4 ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {},
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Tambahkan komentar (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rating berhasil disimpan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan Rating'),
          ),
        ],
      ),
    );
  }

  void _reviewRejection(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tinjau Ulang Booking'),
        content: const Text('Apakah Anda ingin mengaktifkan kembali booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking['status'] = 'pending';
                booking['status_text'] = 'Menunggu Konfirmasi';
                booking['status_color'] = Colors.orange;
                booking['rejection_reason'] = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking['id']} dikembalikan ke status pending'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aktifkan Kembali'),
          ),
        ],
      ),
    );
  }
}