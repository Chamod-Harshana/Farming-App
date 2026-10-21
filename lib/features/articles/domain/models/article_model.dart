class ArticleSection {
  final String title;
  final String titleSi;
  final String? content;
  final String? contentSi;
  final List<String>? bulletPoints;
  final List<String>? bulletPointsSi;
  final String? imagePath;
  final String? highlightBox;
  final String? highlightBoxSi;

  const ArticleSection({
    required this.title,
    required this.titleSi,
    this.content,
    this.contentSi,
    this.bulletPoints,
    this.bulletPointsSi,
    this.imagePath,
    this.highlightBox,
    this.highlightBoxSi,
  });
}

class ArticleModel {
  final String id;
  final String cropId;
  final String title;
  final String titleSi;
  final String subtitle;
  final String subtitleSi;
  final String coverImagePath;
  final String category;
  final String categorySi;
  final int readTimeMinutes;
  final String author;
  final List<ArticleSection> sections;

  const ArticleModel({
    required this.id,
    required this.cropId,
    required this.title,
    required this.titleSi,
    required this.subtitle,
    required this.subtitleSi,
    required this.coverImagePath,
    required this.category,
    required this.categorySi,
    required this.readTimeMinutes,
    required this.author,
    required this.sections,
  });
}
