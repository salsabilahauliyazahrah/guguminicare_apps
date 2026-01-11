import 'package:flutter/material.dart';

class AppTextStyles {
  // Display - Warm theme dengan warna yang lebih hangat
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.25,
    color: Color(0xFF37474F), // Warm dark gray
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22,
    color: Color(0xFF37474F),
  );
  
  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: Color(0xFF37474F),
  );
  
  // Title - Untuk judul dengan warna orange
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: Color(0xFF546E7A), // Gray 600
  );
  
  // Body - Untuk teks utama
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: Color(0xFF546E7A), // Medium gray
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: Color(0xFF546E7A),
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: Color(0xFF78909C), // Light gray
  );
  
  // Label - Untuk label dan caption
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
    color: Color(0xFF37474F),
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
    color: Color(0xFF546E7A),
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
    color: Color(0xFF78909C),
  );
  
  // Button - Style khusus untuk tombol
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.42,
    letterSpacing: 0.1,
    color: Colors.white,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: Color(0xFF78909C),
  );
  
  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.5,
    color: Color(0xFF78909C),
  );
  
  // Custom Text Styles untuk tema kuning-oranye
  static TextStyle accentTitleLarge = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    color: Color(0xFFF57C00), // Orange 700
  );
  
  static TextStyle accentTitleMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: Color(0xFFF57C00),
  );
  
  static TextStyle orangeText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.25,
    color: Color(0xFFFF9800), // Orange 500
  );
  
  static TextStyle creamText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: Color(0xFF5D4037), // Brown untuk kontras di background cream
  );
  
  static TextStyle warmGrayText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: Color(0xFF546E7A), // Warm gray
  );
}