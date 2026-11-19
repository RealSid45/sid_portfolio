import 'package:flutter/material.dart';
import '../design_system.dart';

class TechChip extends StatefulWidget {
  final String text;
  final int delay;

  const TechChip({
    Key? key,
    required this.text,
    this.delay = 0,
  }) : super(key: key);

  @override
  State<TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<TechChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: _isHovered ? 0 : 2, bottom: _isHovered ? 2 : 0),
        transform: Matrix4.identity()..scale(_isHovered ? 1.08 : 1.0),
        decoration: BoxDecoration(
          color: AppDesign.surfaceDark.withOpacity(_isHovered ? 0.8 : 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? AppDesign.primary : AppDesign.primary.withOpacity(0.2),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppDesign.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppDesign.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + widget.delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.8 + (value * 0.2), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppDesign.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppDesign.primary.withOpacity(_isHovered ? 0.8 : 0.5),
                        blurRadius: _isHovered ? 8 : 4,
                        spreadRadius: _isHovered ? 2 : 1,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: _isHovered ? 0.4 : 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
