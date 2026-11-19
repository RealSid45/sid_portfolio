import 'package:flutter/material.dart';
import '../design_system.dart';

class AnimatedLine extends StatelessWidget {
  final double width;

  const AnimatedLine({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: width),
      curve: Curves.easeOut,
      builder: (context, value, child) => Container(
        width: value,
        height: 3,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppDesign.primary, AppDesign.secondary, AppDesign.secondary],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class AvailabilityIndicator extends StatelessWidget {
  const AvailabilityIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) => Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.transparent, AppDesign.primary, value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppDesign.primary.withOpacity(value * 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Available For Work',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool filled;
  final bool showProgress;
  final double progress;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.filled = true,
    this.showProgress = false,
    this.progress = 0.0,
  }) : super(key: key);

  static const gradient = LinearGradient(
    colors: [AppDesign.primary, AppDesign.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: filled ? gradient : null,
            color: filled
                ? null
                : (onPressed == null ? AppDesign.surfaceLight : const Color(0xFF1a2332)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: filled && onPressed != null
                ? [
                    BoxShadow(
                      color: AppDesign.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(onPressed == null ? 0.5 : 1.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
