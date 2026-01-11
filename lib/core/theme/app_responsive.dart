// core/theme/app_responsive.dart
import 'package:flutter/material.dart';

class AppResponsive {
  static double title(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width * 0.045).clamp(16.0, 20.0);
  }

  static double spacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return (height * 0.02).clamp(12.0, 24.0);
  }

  static double gridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width * 0.03).clamp(10.0, 20.0);
  }

  static double gridRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.05;
    if (width < 600) return 1.15;
    return 1.3;
  }

  static double actionIcon(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width * 0.12).clamp(36.0, 52.0);
  }

  static double actionText(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width * 0.045).clamp(14.0, 18.0);
  }

}
