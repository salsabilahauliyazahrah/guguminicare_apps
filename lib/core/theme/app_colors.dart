import 'package:flutter/material.dart';

class AppColors {
  // ==================== PALETTE DARI GAMBAR ====================
  static const Color creamYellow = Color(0xFFFCEF91);     // Cream kuning muda
  static const Color orangeMedium = Color(0xFFFB9E3A);    // Orange sedang
  static const Color orangeRed = Color(0xFFE6521F);       // Orange kemerahan
  static const Color redVibrant = Color(0xFFEA2F14);      // Merah terang

  // ==================== PRIMARY COLORS (dari palet) ====================
  static const Color primary = Color(0xFFFB9E3A);         // Orange sedang dari palet
  static const Color primaryDark = Color(0xFFE6521F);     // Orange kemerahan dari palet
  static const Color primaryLight = Color(0xFFFCEF91);    // Cream kuning dari palet
  static const Color primaryContainer = Color(0xFFFFF3CD); // Cream lebih lembut
  
  // ==================== SECONDARY COLORS ====================
  static const Color secondary = Color(0xFFEA2F14);       // Merah terang dari palet
  static const Color secondaryDark = Color(0xFFC91C0D);   // Merah lebih gelap
  static const Color secondaryLight = Color(0xFFFF6B4A);  // Orange-merah muda
  
  // ==================== ACCENT COLORS ====================
  static const Color accent = Color(0xFFFF7043);          // Deep Orange 400
  static const Color accentLight = Color(0xFFFFAB91);     // Deep Orange 200
  static const Color accentDark = Color(0xFFD84315);      // Deep Orange 800
  
  // ==================== CREAM COLORS ====================
  static const Color cream = Color(0xFFFCEF91);           // Dari palet
  static const Color creamDark = Color(0xFFF5E07A);       // Cream lebih gelap
  static const Color creamLight = Color(0xFFFEF9E6);      // Cream sangat ringan
  static const Color creamBackground = Color(0xFFFFF8E1); // Background cream
  
  // ==================== ORANGE-RED GRADIENT ====================
  static const Color orange1 = Color(0xFFFB9E3A);         // Orange
  static const Color orange2 = Color(0xFFF57C00);         // Orange gelap
  static const Color red1 = Color(0xFFEA2F14);           // Merah dari palet
  static const Color red2 = Color(0xFFD32F2F);           // Merah lebih dalam

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF66BB6A);        // Green 400
  static const Color warning = Color(0xFFFFA726);        // Orange 400
  static const Color error = Color(0xFFEF5350);          // Red 400
  static const Color info = Color(0xFF29B6F6);           // Light Blue 400
  
  static const Color red = Color(0xFFEA2F14);            // Dari palet
  static const Color redLight = Color(0xFFFFEBEE);
  static const Color green = Color(0xFF43A047);
  static const Color greenLight = Color(0xFFE8F5E9);

  // ==================== NEUTRAL COLORS ====================
  static const Color black = Color(0xFF424242);          // Gray 800 (lebih hangat)
  static const Color grey900 = Color(0xFF616161);        // Gray 700
  static const Color grey800 = Color(0xFF757575);        // Gray 600
  static const Color grey700 = Color(0xFF9E9E9E);        // Gray 500
  static const Color grey600 = Color(0xFFBDBDBD);        // Gray 400
  static const Color grey500 = Color(0xFFE0E0E0);        // Gray 300
  static const Color grey400 = Color(0xFFEEEEEE);        // Gray 200
  static const Color grey300 = Color(0xFFF5F5F5);        // Gray 100
  static const Color grey200 = Color(0xFFFAFAFA);        // Gray 50
  static const Color white = Color(0xFFFFFFFF);
  
  // ==================== BACKGROUND & SURFACE ====================
  static const Color background = Color(0xFFFFFFFF);       // Cream background
  static const Color surface = Color(0xFFFFFFFF);        // Putih
  static const Color onSurface = Color(0xFF424242);      // Gray gelap

  // ==================== GRADIENTS ====================
  // Gradient utama dari palet
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [creamYellow, orangeMedium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient orange ke merah
  static const LinearGradient orangeRedGradient = LinearGradient(
    colors: [orangeMedium, redVibrant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient cream lembut
  static const LinearGradient creamGradient = LinearGradient(
    colors: [creamLight, cream],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient untuk action cards
  static const Gradient actionCardOrangeRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange dari palet
      Color(0xFFEA2F14), // Merah dari palet
    ],
  );

  static const Gradient actionCardWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCEF91), // Cream kuning
      Color(0xFFFB9E3A), // Orange
    ],
  );

  static const Gradient actionCardFiery = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6521F), // Orange kemerahan
      Color(0xFFEA2F14), // Merah terang
    ],
  );

  // ==================== HOME SCREEN COLORS ====================
  static const Color homePrimary = Color(0xFFFB9E3A);     // Orange dari palet
  static const Color homeSecondary = Color(0xFFEA2F14);   // Merah dari palet
  
  // GRADIENTS untuk Home Screen (yang hilang saya tambahkan kembali)
  static const Gradient homePrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange dari palet
      Color(0xFFEA2F14), // Merah dari palet
    ],
  );
  
  static const Gradient homeWarmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCEF91), // Cream kuning
      Color(0xFFFB9E3A), // Orange
    ],
  );
  
  static const Gradient homeFieryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange
      Color(0xFFEA2F14), // Merah
    ],
  );
  
  // Gradients yang ada di kode asli (saya tambahkan versi baru)
  static const Gradient orangeCreamGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCEF91), // Cream kuning dari palet
      Color(0xFFFFF8E1), // Cream background
    ],
  );
  
  static const Gradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange dari palet
      Color(0xFFF57C00), // Orange gelap
    ],
  );
  
  // Soft gradient untuk background
  static const Gradient softGradient = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFFEF9E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent colors untuk home screen
  static const Color accentCream = Color(0xFFFCEF91);     // Cream dari palet
  static const Color accentOrange = Color(0xFFFB9E3A);    // Orange dari palet
  static const Color accentRed = Color(0xFFEA2F14);       // Merah dari palet
  
  static const Color accentBlue = Color(0xFF4FC3F7);      // Light Blue 300
  static const Color accentGreen = Color(0xFFAED581);     // Light Green 300
  static const Color accentPink = Color(0xFFF48FB1);      // Pink 300
  
  // Semantic Colors
  static const Color semanticSuccess = Color(0xFF66BB6A);  // Green 400
  static const Color semanticWarning = Color(0xFFFB9E3A);  // Orange dari palet
  static const Color semanticError = Color(0xFFEA2F14);    // Merah dari palet
  static const Color semanticInfo = Color(0xFF42A5F5);     // Blue 400

  // Gradient untuk action cards (versi lama dengan warna baru)
  static const Gradient actionCardOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange dari palet
      Color(0xFFE6521F), // Orange kemerahan
    ],
  );

  static const Gradient actionCardAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFB9E3A), // Orange dari palet
      Color(0xFFF57C00), // Orange gelap
    ],
  );

  static const Gradient actionCardCream = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8E1), // Cream background
      Color(0xFFFCEF91), // Cream kuning
    ],
  );

  static const Gradient actionCardYellow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCEF91), // Cream kuning
      Color(0xFFF5E07A), // Cream lebih gelap
    ],
  );
  
  // New colors for yellow-orange-cream theme
  static const Color yellowLight = Color(0xFFFCEF91);     // Cream kuning dari palet
  static const Color yellow = Color(0xFFFB9E3A);         // Orange dari palet
  static const Color yellowDark = Color(0xFFE6521F);     // Orange kemerahan
  
  static const Color orangeLight = Color(0xFFFCEF91);    // Cream kuning
  static const Color orange = Color(0xFFFB9E3A);         // Orange dari palet
  static const Color orangeDark = Color(0xFFE6521F);     // Orange kemerahan

  // Transparent
  static const Color transparent = Colors.transparent;
}