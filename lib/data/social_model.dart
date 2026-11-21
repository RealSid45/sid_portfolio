import 'package:flutter/widgets.dart';

class SocialModel {
  final IconData? icon;
  final String? vector;
  final String label;
  final String url;

  const SocialModel({
    this.icon,
    this.vector,
    required this.label,
    required this.url,
  });
}
