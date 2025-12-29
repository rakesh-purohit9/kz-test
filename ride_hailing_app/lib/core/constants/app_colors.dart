import 'package:flutter/material.dart';

/// App color palette following Uber's design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF000000);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF8F8F8F);
  static const Color textDisabled = Color(0xFFB3B3B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // UI Colors
  static const Color divider = Color(0xFFE5E5E5);
  static const Color border = Color(0xFFE5E5E5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Semantic Colors
  static const Color success = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info = Color(0xFF4285F4);

  // Map Colors
  static const Color mapRoute = Color(0xFF000000);
  static const Color mapRouteAlt = Color(0xFF6B6B6B);
  static const Color userLocation = Color(0xFF4285F4);
  static const Color driverLocation = Color(0xFF000000);

  // Ride Type Colors
  static const Color economyBg = Color(0xFFF5F5F5);
  static const Color premiumBg = Color(0xFFFFF9E6);
  static const Color xlBg = Color(0xFFE8F5E9);

  // Overlay
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayMedium = Color(0x4D000000);
  static const Color overlayDark = Color(0x80000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF333333)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
