import 'package:flutter/material.dart';

/// Consistent spacing system following 8px grid
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 8.0;

  // Spacing values
  static const double xs = 4.0;   // 0.5x
  static const double sm = 8.0;   // 1x
  static const double md = 16.0;  // 2x
  static const double lg = 24.0;  // 3x
  static const double xl = 32.0;  // 4x
  static const double xxl = 48.0; // 6x

  // Screen padding
  static const double screenHorizontal = 16.0;
  static const double screenVertical = 16.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12.0);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );

  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  // Bottom sheet
  static const double bottomSheetTopRadius = 16.0;
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(16, 8, 16, 16);

  // Input field
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );
}

/// Standard dimensions for UI elements
class AppDimensions {
  AppDimensions._();

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 80.0;

  // Button heights
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Input heights
  static const double inputHeight = 52.0;
  static const double searchBarHeight = 52.0;

  // Card
  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;

  // Bottom sheet
  static const double bottomSheetMinHeight = 200.0;
  static const double bottomSheetMaxHeight = 0.85; // 85% of screen

  // Map elements
  static const double mapMarkerSize = 40.0;
  static const double mapPinSize = 32.0;
  static const double currentLocationButtonSize = 48.0;

  // Divider
  static const double dividerHeight = 1.0;
  static const double dividerThick = 8.0;
}

/// Animation durations
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);

  // Specific animations
  static const Duration splash = Duration(milliseconds: 1500);
  static const Duration sheetSlide = Duration(milliseconds: 300);
  static const Duration mapZoom = Duration(milliseconds: 400);
  static const Duration searchingPulse = Duration(milliseconds: 1500);
  static const Duration driverMarkerMove = Duration(milliseconds: 1000);
}

/// Animation curves
class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeInOut;
  static const Curve sheetSlide = Curves.easeOutCubic;
  static const Curve mapZoom = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
}
