import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility class for responsive design and screen size calculations
class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileBreakpoint) {
      return baseSize * 0.8; // Mobile: 80% of base size
    } else if (screenWidth < tabletBreakpoint) {
      return baseSize * 0.9; // Tablet: 90% of base size
    } else {
      return baseSize; // Desktop: 100% of base size
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive width percentage
  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Get responsive height percentage
  static double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view padding (safe area + responsive padding)
  static EdgeInsets getViewPadding(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    final responsivePadding = getResponsivePadding(context);

    return EdgeInsets.only(
      left: safeArea.left + responsivePadding.left,
      top: safeArea.top + responsivePadding.top,
      right: safeArea.right + responsivePadding.right,
      bottom: safeArea.bottom + responsivePadding.bottom,
    );
  }

  /// Get responsive container width
  static double getContainerWidth(BuildContext context, {double maxWidth = 1200}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsivePadding(context);

    final availableWidth = screenWidth - padding.left - padding.right;
    return availableWidth.clamp(0.0, maxWidth);
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing * 0.75;
    } else if (isTablet(context)) {
      return baseSpacing * 0.9;
    } else {
      return baseSpacing;
    }
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    return getResponsiveFontSize(context, baseSize);
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    if (isMobile(context)) {
      return baseRadius * 0.8;
    } else {
      return baseRadius;
    }
  }

  /// Check if device has small screen (<4 inches)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    final inches = diagonal / 160; // 160 DPI is common
    return inches < 4.0;
  }

  /// Get responsive elevation
  static double getElevation(BuildContext context, double baseElevation) {
    if (isMobile(context)) {
      return baseElevation * 0.8;
    } else {
      return baseElevation;
    }
  }
}

/// Extension on BuildContext for easier responsive access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);

  double responsiveFontSize(double size) => ResponsiveUtils.getResponsiveFontSize(this, size);
  double responsiveSpacing(double spacing) => ResponsiveUtils.getSpacing(this, spacing);
  double responsiveIconSize(double size) => ResponsiveUtils.getIconSize(this, size);
  double responsiveBorderRadius(double radius) => ResponsiveUtils.getBorderRadius(this, radius);
  double responsiveElevation(double elevation) => ResponsiveUtils.getElevation(this, elevation);

  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.getResponsiveMargin(this);
  EdgeInsets get viewPadding => ResponsiveUtils.getViewPadding(this);

  double widthPercentage(double percentage) => ResponsiveUtils.getWidthPercentage(this, percentage);
  double heightPercentage(double percentage) => ResponsiveUtils.getHeightPercentage(this, percentage);

  double get containerWidth => ResponsiveUtils.getContainerWidth(this);
  int get gridCrossAxisCount => ResponsiveUtils.getGridCrossAxisCount(this);
  double get buttonHeight => ResponsiveUtils.getButtonHeight(this);
}
