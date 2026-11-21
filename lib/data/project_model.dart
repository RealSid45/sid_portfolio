class ProjectModel {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> extraImages;
  final List<String> tags;
  final String? playStoreUrl;

  const ProjectModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.extraImages = const [],
    required this.tags,
    this.playStoreUrl,
  });

  List<String> get allImages => [imageUrl, ...extraImages];
}
