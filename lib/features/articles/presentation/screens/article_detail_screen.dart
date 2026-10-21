import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../domain/models/article_model.dart';

/// Read-Only Technical Crop Article Detail View Screen
/// (මෙම ලිපිය තොරතුරු දැන ගැනීමට App එක විසින් ලබා දෙන දෙයකි. පරිශීලකයාට වෙනස් කළ නොහැක.)
class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, child) {
        final isSinhala = LanguageController.instance.isSinhala;

        final displayTitle = isSinhala ? article.titleSi : article.title;
        final displaySubtitle = isSinhala ? article.subtitleSi : article.subtitle;
        final displayCategory = isSinhala ? article.categorySi : article.category;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HERO SLIVER APP BAR WITH COVER IMAGE & SCREENSHOT MATCHING STYLE
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.darkPill,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSinhala ? 'ලිපිය සාර්ථකව බෙදා ගන්නා ලදී' : 'Article link shared!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        article.coverImagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppColors.darkPill,
                          child: const Center(
                            child: Icon(Icons.eco_rounded, color: Colors.white, size: 60),
                          ),
                        ),
                      ),
                      // Gradient overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(60),
                              Colors.black.withAlpha(30),
                              Colors.black.withAlpha(200),
                            ],
                          ),
                        ),
                      ),
                      // Title & Subtitle Banner at bottom of image (Matching user screenshot style)
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                displayCategory,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('🌿 ', style: TextStyle(fontSize: 14)),
                                Text(
                                  displaySubtitle,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(230),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. READ-ONLY BODY CONTENT
              SliverPadding(
                padding: const EdgeInsets.all(18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Read-only indicator banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: Color(0xFFF57F17), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isSinhala
                                  ? 'මෙම ලිපිය තොරතුරු දැන ගැනීමට App එක විසින් ලබා දෙන නිල තාක්ෂණික මාර්ගෝපදේශයකි (පරිශීලකයාට වෙනස් කළ නොහැක).'
                                  : 'This is an official technical reference guide provided by the app (Read-Only).',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE65100),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Author & Read Time Pill Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary.withAlpha(40),
                          child: const Icon(Icons.nature_people_rounded, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.author,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightLavender,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: AppColors.darkPill),
                              const SizedBox(width: 4),
                              Text(
                                '${article.readTimeMinutes} ${isSinhala ? "මිනි." : "min"}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkPill,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // ARTICLE SECTIONS RENDERER
                    ...article.sections.map((section) => _buildSectionWidget(context, section, isSinhala)),

                    const SizedBox(height: 30),

                    // FOOTER ACKNOWLEDGEMENT CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkPill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_florist_rounded, color: Colors.greenAccent, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            isSinhala ? 'සාර්ථක පේර වගාවකට ආශිර්වාද!' : 'Happy & Prosperous Guava Farming!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSinhala
                                ? 'තවත් ගැටලු සඳහා මුල් පිටුවේ ඇති ගොවි AI සාකච්ඡාව භාවිතා කරන්න.'
                                : 'For further technical help, use Farm AI Chat on the home page.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to render individual technical section with heading, body, highlight cards & images
  Widget _buildSectionWidget(BuildContext context, ArticleSection section, bool isSinhala) {
    final title = isSinhala ? section.titleSi : section.title;
    final content = isSinhala ? section.contentSi : section.content;
    final bulletPoints = isSinhala ? section.bulletPointsSi : section.bulletPoints;
    final highlightBox = isSinhala ? section.highlightBoxSi : section.highlightBox;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Section Embedded Image (if present)
          if (section.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                section.imagePath!,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Main Text Paragraph
          if (content != null && content.isNotEmpty) ...[
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Bullet Points List Cards
          if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
            Column(
              children: bulletPoints.map((point) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌱 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2C2C2C),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
          ],

          // Highlight Callout Card (if present)
          if (highlightBox != null && highlightBox.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardMint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA3E2C9)),
              ),
              child: Text(
                highlightBox,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1B4D3E),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
