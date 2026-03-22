import 'package:flutter/material.dart';
import '../design_system.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppDesign.mobileBreakpoint) {
          return mobile;
        } else if (constraints.maxWidth < AppDesign.tabletBreakpoint) {
          return tablet ?? desktop;
        } else {
          return desktop;
        }
      },
    );
  }
}