import 'package:flutter/material.dart';
import '../design_system.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/tech_chip.dart';
import '../data/portfolio_data.dart';
import '../constants/app_assets.dart';

class AboutSection extends StatelessWidget {
  final bool isVisible;

  const AboutSection({Key? key, required this.isVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = AppDesign.responsivePadding(context);
    return AnimatedOpacity(
      duration: AppDesign.mediumDuration,
      opacity: isVisible ? 1.0 : 0.0,
      curve: AppDesign.defaultCurve,
      child: AnimatedContainer(
        duration: AppDesign.mediumDuration,
        curve: AppDesign.defaultCurve,
        transform: Matrix4.translationValues(0, isVisible ? 0 : 20, 0),
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: AppDesign.isMobile(context) ? 60 : 100,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.aboutBg),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: _AboutContent(isVisible: isVisible),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final bool isVisible;

  const _AboutContent({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Text('About',
                    style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            const SizedBox(width: 8),
            Flexible(
                child: Text('Me',
                    style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppDesign.primary))),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedLine(width: isMobile ? 100 : 150),
        SizedBox(height: isMobile ? 30 : 50),
        ResponsiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAboutText(),
              const SizedBox(height: 40),
              _buildTechStackSection(context),
              const SizedBox(height: 40),
              _SkillsColumn(isVisible: isVisible),
            ],
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildAboutText(),
                    const SizedBox(height: 40),
                    _buildTechStackSection(context),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(flex: 4, child: _SkillsColumn(isVisible: isVisible)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a multidisciplinary creative technologist specializing in Cross-Platform Mobile Development and User Interface Design. With a strong foundation in Flutter and expert proficiency in Figma, I help startups and businesses transform abstract ideas into deployable, high-performance products.',
          style: TextStyle(
              fontSize: AppDesign.bodyM,
              color: Colors.white.withOpacity(0.8),
              height: 1.8,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        Text(
          'My journey in mobile development has equipped me with a strong foundation in UI/UX principles, state management, and modern development practices. I constantly strive to learn new technologies and improve my craft.',
          style: TextStyle(
              fontSize: AppDesign.bodyM,
              color: Colors.white.withOpacity(0.8),
              height: 1.8,
              letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildTechStackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tech Stack',
            style: TextStyle(
                fontSize:
                    AppDesign.responsiveFontSize(context, AppDesign.headingL),
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        Text('Great products need great tools — here are the ones I use daily.',
            style: TextStyle(
                fontSize: AppDesign.bodyS,
                color: Colors.white.withOpacity(0.7),
                height: 1.4)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: PortfolioData.techStack
              .asMap()
              .entries
              .map((entry) => TechChip(text: entry.value, delay: entry.key * 50))
              .toList(),
        ),
      ],
    );
  }
}

class _SkillsColumn extends StatelessWidget {
  final bool isVisible;

  const _SkillsColumn({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Technical Skills',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 30),
        _SkillProgress('Flutter & Dart', 90, isVisible),
        const SizedBox(height: 25),
        _SkillProgress('UI/UX Design', 85, isVisible),
        const SizedBox(height: 25),
        _SkillProgress('C++', 75, isVisible),
        const SizedBox(height: 25),
        _SkillProgress('Git & GitHub', 80, isVisible),
        const SizedBox(height: 25),
        _SkillProgress('Firebase', 70, isVisible),
      ],
    );
  }
}

class _SkillProgress extends StatelessWidget {
  final String skill;
  final double percentage;
  final bool isVisible;

  const _SkillProgress(this.skill, this.percentage, this.isVisible);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(skill,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${percentage.toInt()}%',
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withOpacity(0.7))),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: isVisible ? percentage / 100 : 0.0),
              curve: Curves.easeOut,
              builder: (context, value, child) => FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppDesign.primary, AppDesign.secondary]),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                          color: AppDesign.primary.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 0.5)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
