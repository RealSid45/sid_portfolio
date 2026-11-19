import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design_system.dart';
import '../data/portfolio_data.dart';

class SocialIcon extends StatefulWidget {
  final SocialModel social;
  final bool isHome;

  const SocialIcon({
    Key? key,
    required this.social,
    this.isHome = true,
  }) : super(key: key);

  @override
  State<SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.social.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Tooltip(
          message: widget.social.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isHome
                  ? (_isHovered
                      ? AppDesign.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05))
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(widget.isHome ? 8 : 10),
              border: Border.all(
                color: _isHovered
                    ? AppDesign.primary
                    : Colors.white.withOpacity(0.2),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppDesign.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              widget.social.icon,
              color: _isHovered ? AppDesign.primary : Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
