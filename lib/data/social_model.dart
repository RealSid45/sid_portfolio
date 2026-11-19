class SocialModel {
  final String vector;
  final String label;
  final String url;

  const SocialModel({
    required this.vector,
    required this.label,
    required this.url,
  });

  // Safety factory to prevent null pointer issues during hot reload/restart
  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      vector: json['vector'] ?? '',
      label: json['label'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
