//ini penting disimpen buat dummy dulu 

import 'package:flutter/material.dart';

class ServiceConstants {
  // Data layanan dengan penjelasan detail
  static final List<Map<String, dynamic>> services = [
    {
      'id': 1,
      'name': 'Basic Grooming',
      'price': 120000,
      'duration': '1.5 jam',
      'icon': Icons.cleaning_services,
      'color': 0xFF4FC3F7,
      'description': 'Layanan grooming dasar untuk hewan peliharaan',
      'details': [
        'Pemandian dengan shampoo khusus',
        'Pengeringan dengan handuk',
        'Penyisiran bulu',
        'Pemotongan kuku',
        'Pembersihan telinga',
        'Parfum wangi segar'
      ],
      'benefits': [
        'Bersih dan wangi',
        'Bebas kutu dan parasit',
        'Bulu lebih lembut',
        'Kuku tidak melukai'
      ],
      'suitableFor': 'Semua jenis anjing dan kucing',
    },
    {
      'id': 2,
      'name': 'Premium Grooming',
      'price': 180000,
      'duration': '2 jam',
      'icon': Icons.spa,
      'color': 0xFFAED581,
      'description': 'Grooming lengkap dengan perawatan ekstra',
      'details': [
        'Semua layanan Basic Grooming',
        'Scrubbing kulit dengan scrub khusus',
        'Masker bulu dengan vitamin',
        'Pijat relaksasi',
        'Stripping bulu mati',
        'Creative styling (opsional)'
      ],
      'benefits': [
        'Kulit lebih sehat',
        'Bulu lebih berkilau',
        'Relaksasi untuk hewan',
        'Penampilan lebih menarik'
      ],
      'suitableFor': 'Hewan yang membutuhkan perawatan ekstra',
    },
    {
      'id': 3,
      'name': 'Special Package',
      'price': 250000,
      'duration': '2.5 jam',
      'icon': Icons.star,
      'color': 0xFFFFB74D,
      'description': 'Paket spesial perawatan lengkap',
      'details': [
        'Semua layanan Premium Grooming',
        'Whitening treatment untuk bulu putih',
        'Conditioning treatment khusus',
        'Hot oil treatment',
        'Facial treatment',
        'Sikat gigi dan perawatan mulut'
      ],
      'benefits': [
        'Bulu putih lebih bersinar',
        'Kondisi bulu optimal',
        'Kesehatan mulut terjaga',
        'Perawatan menyeluruh'
      ],
      'suitableFor': 'Hewan show atau persiapan kontes',
    },
    {
      'id': 4,
      'name': 'Spa Treatment',
      'price': 200000,
      'duration': '2 jam',
      'icon': Icons.water_drop,
      'color': 0xFFF48FB1,
      'description': 'Perawatan spa khusus untuk relaksasi',
      'details': [
        'Aromatherapy bath',
        'Hot stone massage',
        'Hydrotherapy',
        'Mud bath treatment',
        'Essential oil treatment',
        'Relaxing music therapy'
      ],
      'benefits': [
        'Meredakan stres',
        'Meningkatkan sirkulasi darah',
        'Melemaskan otot',
        'Meningkatkan mood hewan'
      ],
      'suitableFor': 'Hewan yang mudah stres atau tua',
    },
    {
      'id': 5,
      'name': 'Medical Grooming',
      'price': 300000,
      'duration': '3 jam',
      'icon': Icons.medical_services,
      'color': 0xFFEF5350,
      'description': 'Grooming dengan perawatan medis',
      'details': [
        'Konsultasi dengan groomer berpengalaman',
        'Perawatan kulit dengan kondisi khusus',
        'Pengobatan kutu dan parasit',
        'Perawatan luka ringan',
        'Perawatan mata dan telinga khusus',
        'Pemeriksaan kesehatan dasar'
      ],
      'benefits': [
        'Aman untuk hewan sakit',
        'Perawatan medis terintegrasi',
        'Pencegahan infeksi',
        'Monitoring kesehatan'
      ],
      'suitableFor': 'Hewan dengan kondisi medis khusus',
    },
  ];

  // Data metode layanan dengan penjelasan
  static final List<Map<String, dynamic>> serviceMethods = [
    {
      'id': 'salon',
      'name': 'Datang ke Salon',
      'icon': Icons.store,
      'fee': 0,
      'description': 'Kunjungi salon kami untuk layanan langsung',
      'details': [
        'Layanan di salon kami yang nyaman',
        'Fasilitas lengkap dan higienis',
        'Staf profesional siap membantu',
        'Area tunggu yang nyaman'
      ],
      'estimatedTime': 'Sesuai durasi layanan',
      'availability': 'Setiap hari 08:00 - 20:00',
    },
    {
      'id': 'home',
      'name': 'Home Service',
      'icon': Icons.home,
      'fee': 0,
      'description': 'Groomer datang ke rumah Anda',
      'details': [
        'Groomer datang ke lokasi Anda',
        'Perawatan di lingkungan familiar hewan',
        'Mengurangi stres perjalanan',
        'Fleksibel waktu (sesuai jadwal)'
      ],
      'estimatedTime': 'Durasi layanan + persiapan alat',
      'availability': 'Area terjangkau 10km dari salon',
    },
    {
      'id': 'pickup',
      'name': 'Antar Jemput',
      'icon': Icons.directions_car,
      'fee': 25000,
      'description': 'Kami jemput dan antar hewan Anda',
      'details': [
        'Penjemputan dari lokasi Anda',
        'Pengantaran setelah selesai',
        'Kendaraan khusus hewan',
        'Pengemudi berpengalaman'
      ],
      'estimatedTime': 'Durasi layanan + waktu perjalanan',
      'availability': 'Area terjangkau 15km dari salon',
      'additionalInfo': 'Termasuk kandang transportasi yang aman',
    },
  ];
}