import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:sid_portfolio/constants/app_assets.dart';
import 'package:sid_portfolio/data/project_model.dart';
import 'package:sid_portfolio/data/social_model.dart';

class PortfolioData {
  static const String resumeDriveId = '1L6HrWjoj4RH5CSddjPsDUSGQfHoBNCKs';
  static const String resumeUrl = 'https://drive.google.com/file/d/$resumeDriveId/view?usp=sharing';

  static final List<String> techStack = [
    "Dart", "Flutter", "Provider", "GetX", "BLoC", "Riverpod",
    "sqflite", "Hive", "Figma", "Cursor", "Firebase", "REST API",
    "Git / GitHub", "Dependency Injection", "Payment Integration",
    "MVVM", "Responsive Design", "AI Prompting",
  ];

  static final List<ProjectModel> projects = [
    const ProjectModel(
      title: 'Nike App Clone',
      description: 'Nike Clone – Clone Of The Official Nike Store',
      imageUrl: AppAssets.projectNike,
      tags: ['Flutter', 'Firebase'],
    ),
    const ProjectModel(
      title: 'Rivio',
      description: 'Track daily routines with charts & filters',
      imageUrl: AppAssets.projectRivio,
      extraImages: [
        AppAssets.projectRivio2,
        AppAssets.projectRivio3,
      ],
      tags: ['Flutter', 'Figma', 'Firebase', 'Supabase'],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.rivioapp.rivio',
    ),
    const ProjectModel(
      title: 'Nomad',
      description: 'Plan together. Travel better.',
      imageUrl: AppAssets.projectNomad,
      tags: ['Flutter', 'Figma', 'Firebase'],
    ),
  ];

  static final List<SocialModel> homeSocials = [
    const SocialModel(
      icon: BootstrapIcons.google,
      label: 'Gmail',
      url: 'mailto:sidhuxplore4@gmail.com',
    ),
    const SocialModel(
      icon: BootstrapIcons.whatsapp,
      label: 'WhatsApp',
      url: 'https://wa.me/919544413854',
    ),
    const SocialModel(
      icon: BootstrapIcons.instagram,
      label: 'Instagram',
      url: 'https://instagram.com/_the_realsid_',
    ),
    const SocialModel(
      icon: BootstrapIcons.twitter_x,
      label: 'X',
      url: 'https://x.com/SidharthSidu1',
    ),
  ];

  static final List<SocialModel> contactSocials = [
    const SocialModel(
      icon: BootstrapIcons.github,
      label: 'GitHub',
      url: 'https://github.com/RealSid45',
    ),
    const SocialModel(
      icon: BootstrapIcons.linkedin,
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/sidharth-biju-414273310/',
    ),
    const SocialModel(
      icon: BootstrapIcons.microsoft,
      label: 'Outlook',
      url: 'mailto:sidhuxplore4@outlook.com',
    ),
    const SocialModel(
      icon: BootstrapIcons.dribbble,
      label: 'Dribbble',
      url: 'https://dribbble.com/',
    ),
  ];
}
