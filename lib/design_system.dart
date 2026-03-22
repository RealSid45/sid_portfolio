import 'package:flutter/material.dart';

class AppDesign {
  static const Color primary = Color(0xFFF86E5B);
  static const Color secondary = Color(0xFF924136);
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color surfaceDark = Color(0xFF1A1F3A);
  static const Color surfaceLight = Color(0xFF2A2F4A);

  static const double displayXL = 72.0;
  static const double displayL = 56.0;
  static const double displayM = 42.0;
  static const double headingL = 28.0;
  static const double headingM = 24.0;
  static const double bodyL = 20.0;
  static const double bodyM = 18.0;
  static const double bodyS = 16.0;
  static const double caption = 14.0;

  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 40.0;
  static const double spacingXL = 60.0;
  static const double spacingXXL = 80.0;

  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration slowDuration = Duration(milliseconds: 800);
  static const Curve defaultCurve = Curves.easeOut;

  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
          MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double responsivePadding(BuildContext context) {
    if (isMobile(context)) return spacingM;
    if (isTablet(context)) return spacingXL;
    return spacingXXL;
  }

  static double responsiveFontSize(BuildContext context, double desktop) {
    if (isMobile(context)) return desktop * 0.6;
    if (isTablet(context)) return desktop * 0.8;
    return desktop;
  }
}