import 'package:flutter/material.dart';
import '../design_system.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/social_icon.dart';
import '../data/portfolio_data.dart';
import '../constants/app_assets.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onProjectTap;
  final VoidCallback onResumeTap;
  final bool isDownloading;
  final double downloadProgress;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const HeroSection({
    Key? key,
    required this.onProjectTap,
    required this.onResumeTap,
    required this.isDownloading,
    required this.downloadProgress,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = AppDesign.responsivePadding(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: AppDesign.isMobile(context) ? 40 : 60,
      ),
      child: ResponsiveLayout(
        mobile: Column(
          children: [
            SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: _HeroContent(
                  onProjectTap: onProjectTap,
                  onResumeTap: onResumeTap,
                  isDownloading: isDownloading,
                  downloadProgress: downloadProgress,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _HeroImage(fadeAnimation: fadeAnimation),
          ],
        ),
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: _HeroContent(
                    onProjectTap: onProjectTap,
                    onResumeTap: onResumeTap,
                    isDownloading: isDownloading,
                    downloadProgress: downloadProgress,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: _HeroImage(fadeAnimation: fadeAnimation),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onProjectTap;
  final VoidCallback onResumeTap;
  final bool isDownloading;
  final double downloadProgress;

  const _HeroContent({
    required this.onProjectTap,
    required this.onResumeTap,
    required this.isDownloading,
    required this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final displaySize =
        AppDesign.responsiveFontSize(context, AppDesign.displayXL);
    final headingSize =
        AppDesign.responsiveFontSize(context, AppDesign.displayL);

    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text('Hello',
                style: TextStyle(
                    fontSize: displaySize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            TweenAnimationBuilder<double>(
              duration: AppDesign.mediumDuration,
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: const Text('.',
                  style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppDesign.primary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedLine(width: isMobile ? 150 : 230),
        const SizedBox(height: 30),
        Text("I'm Sidharth",
            style: TextStyle(
                fontSize:
                    AppDesign.responsiveFontSize(context, AppDesign.displayM),
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 0.5),
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 5),
        Text('Flutter Developer',
            style: TextStyle(
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1),
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        const SizedBox(height: 40),
        isMobile
            ? Column(children: [
                GradientButton(
                    text: 'Got a Project?',
                    onPressed: onProjectTap,
                    filled: true),
                const SizedBox(height: 16),
                GradientButton(
                    text: isDownloading ? 'Downloading...' : 'My Resume',
                    onPressed: isDownloading ? null : onResumeTap,
                    filled: false,
                    showProgress: isDownloading,
                    progress: downloadProgress),
              ])
            : Row(children: [
                GradientButton(
                    text: 'Got a Project?',
                    onPressed: onProjectTap,
                    filled: true),
                const SizedBox(width: 30),
                GradientButton(
                    text: isDownloading ? 'Downloading...' : 'My Resume',
                    onPressed: isDownloading ? null : onResumeTap,
                    filled: false,
                    showProgress: isDownloading,
                    progress: downloadProgress),
              ]),
        const SizedBox(height: 60),
        const AvailabilityIndicator(),
        const SizedBox(height: 30),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: PortfolioData.homeSocials
              .map((social) => SocialIcon(social: social))
              .toList(),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const _HeroImage({required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final imageWidth =
        isMobile ? MediaQuery.of(context).size.width * 0.8 : 450.0;
    final imageHeight = isMobile ? imageWidth * 1.2 : 550.0;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(20 * (1 - value), 0),
        child: Opacity(opacity: value, child: child),
      ),
      child: Align(
        child: Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage(AppAssets.profile),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black, blurRadius: 15, offset: Offset(0, 8))
            ],
          ),
        ),
      ),
    );
  }
}
