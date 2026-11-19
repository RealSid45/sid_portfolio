import 'package:flutter/material.dart';
import '../design_system.dart';
import '../widgets/custom_widgets.dart';
import '../constants/app_assets.dart';

class ExperienceSection extends StatelessWidget {
  final bool isVisible;
  final bool showViewMoreButton;
  final VoidCallback onViewMorePressed;

  const ExperienceSection({
    Key? key,
    required this.isVisible,
    required this.showViewMoreButton,
    required this.onViewMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppDesign.mediumDuration,
      opacity: isVisible ? 1.0 : 0.0,
      curve: AppDesign.defaultCurve,
      child: AnimatedContainer(
        duration: AppDesign.mediumDuration,
        curve: AppDesign.defaultCurve,
        transform: Matrix4.translationValues(0, isVisible ? 0 : 20, 0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.experienceBg),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('Experience',
                      style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(width: 8),
                  Text('& Journey',
                      style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppDesign.primary)),
                ],
              ),
              const SizedBox(height: 8),
              const AnimatedLine(width: 200),
              const SizedBox(height: 50),
              _MainExperienceCard(),
              if (showViewMoreButton) ...[
                const SizedBox(height: 50),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onViewMorePressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppDesign.primary, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('View More Experiences',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: AppDesign.primary,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_downward,
                                color: AppDesign.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MainExperienceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppDesign.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppDesign.surfaceLight, width: 1),
        boxShadow: [
          BoxShadow(
              color: AppDesign.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Flutter Developer Intern',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Luminar Technolab',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppDesign.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppDesign.primary, AppDesign.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('2025 - Present',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 25),
          Text('Reflection of what I\'ve been doing so far, so long.',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                  height: 1.6)),
          const SizedBox(height: 30),
          const Text(
              'As a Flutter Developer Intern at Luminar Technolab, I\'m actively involved in:',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Column(
            children: const [
              _ExperienceBullet(
                  'Developing cross-platform mobile applications using Flutter framework'),
              SizedBox(height: 12),
              _ExperienceBullet(
                  'Collaborating with design teams to implement pixel-perfect UI/UX designs'),
              SizedBox(height: 12),
              _ExperienceBullet(
                  'Integrating REST APIs and managing state using Provider/GetX'),
              SizedBox(height: 12),
              _ExperienceBullet(
                  'Working with Firebase for authentication, database, and cloud functions'),
              SizedBox(height: 12),
              _ExperienceBullet(
                  'Participating in code reviews and following best development practices'),
              SizedBox(height: 12),
              _ExperienceBullet(
                  'Learning and implementing clean architecture patterns'),
            ],
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ExperienceSkillChip('Flutter'),
              _ExperienceSkillChip('Dart'),
              _ExperienceSkillChip('Firebase'),
              _ExperienceSkillChip('REST API'),
              _ExperienceSkillChip('Git'),
              _ExperienceSkillChip('Figma'),
              _ExperienceSkillChip('Provider'),
              _ExperienceSkillChip('Clean Architecture'),
            ],
          ),
        ],
      ),
    );
  }
}

class AdditionalExperienceSection extends StatelessWidget {
  final VoidCallback onShowLessPressed;

  const AdditionalExperienceSection({Key? key, required this.onShowLessPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(AppAssets.additionalExperienceBg),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppDesign.surfaceDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppDesign.surfaceLight, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppDesign.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Live Project - POS by ORAVCO',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 4),
                          Text('ORAVCO Private Limited',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppDesign.primary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppDesign.primary, AppDesign.secondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Dec 2025',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Divider(color: Colors.white.withOpacity(0.2), height: 1),
                  const SizedBox(height: 25),
                  Text(
                    'Successfully completed a Live Project titled "POS by ORAVCO" from 01/12/2025 to 06/12/2025',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        height: 1.6),
                  ),
                  const SizedBox(height: 30),
                  const Text('Key Contributions:',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Column(
                    children: const [
                      _ExperienceBullet(
                          'Integrated developed APIs into the client Application built with Flutter'),
                      SizedBox(height: 12),
                      _ExperienceBullet(
                          'Collaborated with the team to deliver project outcomes within timelines'),
                      SizedBox(height: 12),
                      _ExperienceBullet(
                          'Effectively contributed to the successful completion of the project'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppDesign.backgroundDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppDesign.primary.withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Certificate Excerpt:',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppDesign.primary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text(
                          '"We found him to be hardworking, dedicated, proactive, and a keen learner, who contributed effectively to the successful completion of the project."',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                              height: 1.6),
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('- ORAVCO Private Limited',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _ExperienceSkillChip('Flutter'),
                      _ExperienceSkillChip('API Integration'),
                      _ExperienceSkillChip('Team Collaboration'),
                      _ExperienceSkillChip('Project Delivery'),
                      _ExperienceSkillChip('Problem Solving'),
                      _ExperienceSkillChip('Time Management'),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onShowLessPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppDesign.primary, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_upward,
                            color: AppDesign.primary, size: 20),
                        SizedBox(width: 12),
                        Text('Show Less Experiences',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppDesign.primary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceBullet extends StatelessWidget {
  final String text;

  const _ExperienceBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppDesign.primary)),
        const SizedBox(width: 16),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5))),
      ],
    );
  }
}

class _ExperienceSkillChip extends StatelessWidget {
  final String skill;

  const _ExperienceSkillChip(this.skill);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppDesign.backgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppDesign.surfaceLight, width: 1),
      ),
      child: Text(skill,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
    );
  }
}
