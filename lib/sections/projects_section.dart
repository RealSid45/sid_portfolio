import 'package:flutter/material.dart';
import '../design_system.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/project_card.dart';
import '../data/portfolio_data.dart';

class ProjectsSection extends StatelessWidget {
  final bool isVisible;

  const ProjectsSection({Key? key, required this.isVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final padding = AppDesign.responsivePadding(context);
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);

    return AnimatedOpacity(
      duration: AppDesign.mediumDuration,
      opacity: isVisible ? 1.0 : 0.0,
      curve: AppDesign.defaultCurve,
      child: AnimatedContainer(
        duration: AppDesign.mediumDuration,
        curve: AppDesign.defaultCurve,
        transform: Matrix4.translationValues(0, isVisible ? 0 : 20, 0),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.45)),
        padding: EdgeInsets.symmetric(
            vertical: isMobile ? 50 : 70, horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Projects',
                style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('Where Innovation Meets Execution',
                style: TextStyle(
                    color: Colors.grey[400], fontSize: AppDesign.bodyM)),
            const SizedBox(height: 12),
            AnimatedLine(width: isMobile ? 100 : 150),
            const SizedBox(height: 30),
            ResponsiveLayout(
              mobile: Column(
                children: PortfolioData.projects
                    .map((project) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ProjectCard(project: project),
                        ))
                    .toList(),
              ),
              desktop: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.85,
                children: PortfolioData.projects
                    .map((project) => ProjectCard(project: project))
                    .toList(),
              ),
            ),
            const SizedBox(height: 40),
            Center(
                child: TextButton(
                    onPressed: () {},
                    child: const Text('See More',
                        style: TextStyle(
                            color: Colors.white70, fontSize: AppDesign.bodyS)))),
          ],
        ),
      ),
    );
  }
}
