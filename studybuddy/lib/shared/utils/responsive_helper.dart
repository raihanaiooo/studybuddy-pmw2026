import 'package:flutter/material.dart';

/// Responsive breakpoint utility for adaptive layouts
class ResponsiveHelper {
  ResponsiveHelper._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileMax && w < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMax;

  /// Returns number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileMax) return 1;
    if (w < tabletMax) return 2;
    if (w < desktopMax) return 3;
    return 4;
  }

  /// Returns max content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileMax) return w;
    if (w < tabletMax) return 720;
    if (w < desktopMax) return 1000;
    return 1200;
  }

  /// Horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileMax) return 16;
    if (w < tabletMax) return 24;
    return 32;
  }

  /// Content padding with symmetry
  static EdgeInsets contentPadding(BuildContext context) {
    final h = horizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: h);
  }
}

/// Responsive wrapper widget that adapts layout based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Constrained content wrapper for wide screens
class ContentConstraint extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ContentConstraint({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
