import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../constants/app_assets.dart';

class ProjectModel {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;

  ProjectModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
  });
}

class SocialModel {
  final IconData icon;
  final String label;
  final String url;

  SocialModel({
    required this.icon,
    required this.label,
    required this.url,
  });
}

class PortfolioData {
  static const String resumeDriveId = '1L6HrWjoj4RH5CSddjPsDUSGQfHoBNCKs';
  static const String resumeUrl = 'https://drive.google.com/file/d/$resumeDriveId/view?usp=sharing';

  static final List<String> techStack = [
    "Dart", "Flutter", "Provider", "GetX", "BLoC", "Riverpod",
    "sqflite", "Hive", "Figma", "Cursor", "Firebase", "REST API",
    "Git / GitHub", "Dependency Injection", "Payment Integration",
    "MVVM", "Responsive Design",
  ];

  static final List<ProjectModel> projects = [
    ProjectModel(
      title: 'Nike App Clone',
      description: 'Nike Clone – Clone Of The Official Nike Store',
      imageUrl: AppAssets.projectNike,
      tags: ['Flutter'],
    ),
    ProjectModel(
      title: 'Rivio',
      description: 'Track daily routines with charts & filters',
      imageUrl: AppAssets.projectRivio,
      tags: ['Flutter', 'Figma', 'Firebase'],
    ),
    ProjectModel(
      title: 'SnackSnap',
      description: 'Modern UI design exploration',
      imageUrl: AppAssets.projectSnackSnap,
      tags: ['Figma'],
    ),
  ];

  static final List<SocialModel> homeSocials = [
    SocialModel(
      icon: Icons.alternate_email,
      label: 'Gmail',
      url: 'mailto:sidhuxplore4@gmail.com',
    ),
    SocialModel(
      icon: FontAwesomeIcons.whatsapp,
      label: 'WhatsApp',
      url: 'https://wa.me/919544413854',
    ),
    SocialModel(
      icon: FontAwesomeIcons.instagram,
      label: 'Instagram',
      url: 'https://instagram.com/_the_realsid_',
    ),
    SocialModel(
      icon: FontAwesomeIcons.xTwitter,
      label: 'X',
      url: 'https://x.com/SidharthSidu1',
    ),
  ];

  static final List<SocialModel> contactSocials = [
    SocialModel(
      icon: FontAwesomeIcons.github,
      label: 'GitHub',
      url: 'https://github.com/RealSid45',
    ),
    SocialModel(
      icon: FontAwesomeIcons.linkedin,
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/sidharth-biju-414273310/',
    ),
    SocialModel(
      icon: Icons.email_outlined,
      label: 'Email',
      url: 'mailto:sidhuxplore4@outlook.com',
    ),
    SocialModel(
      icon: FontAwesomeIcons.dribbble,
      label: 'Dribbble',
      url: 'https://dribbble.com/',
    ),
  ];
}
