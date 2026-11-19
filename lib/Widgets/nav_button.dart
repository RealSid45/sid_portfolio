import 'package:flutter/material.dart';
import '../design_system.dart';

class NavButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isActive;

  const NavButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: AppDesign.bodyM,
                  color: widget.isActive || _isHovered
                      ? AppDesign.primary
                      : Colors.white70,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: AppDesign.fastDuration,
              height: 2,
              width: _isHovered || widget.isActive ? 40 : 0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppDesign.primary, AppDesign.secondary]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
