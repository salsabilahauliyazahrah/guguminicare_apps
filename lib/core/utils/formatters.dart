import 'package:intl/intl.dart';

class Formatters {
  // Currency formatter (Rp)
  static String currency(double amount, {String symbol = 'Rp'}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Date formatters
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Relative time (e.g., "2 hours ago")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Phone number formatter (Indonesian format)
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (cleaned.startsWith('+62')) {
      return cleaned.replaceFirst('+62', '0');
    } else if (cleaned.startsWith('62')) {
      return '0${cleaned.substring(2)}';
    } else if (cleaned.startsWith('0')) {
      return cleaned;
    } else if (cleaned.length >= 10) {
      return '0$cleaned';
    }
    
    return cleaned;
  }

  // File size formatter
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Duration formatter (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '< 1m';
    }
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Mask email (e.g., "te***@gmail.com")
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    final maskedUsername = '${username.substring(0, 2)}${'*' * (username.length - 2)}';
    return '$maskedUsername@$domain';
  }
}