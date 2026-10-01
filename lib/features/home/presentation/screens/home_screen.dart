import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_app_drawer.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Top Custom Navigation Bar (Light Lavender with 3 lines, logo & language switch)
      appBar: const CustomAppBar(),

      // Side Drawer Navigation
      drawer: const CustomAppDrawer(),

      body: ValueListenableBuilder<String>(
        valueListenable: LanguageController.instance,
        builder: (context, lang, child) {
          final isSinhala = LanguageController.instance.isSinhala;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP WEATHER & GREETING CARD
                _buildWeatherGreetingCard(isSinhala),

                const SizedBox(height: 20),

                // 2. MAIN FEATURE CARDS LIST with Smooth Bold Press Animations (එකක් යට එකක් එන විදියට)
                AnimatedPressable(
                  pressedScale: 0.95,
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.myCrops);
                  },
                  child: _buildStackedFeatureCard(
                    title: LanguageController.instance.getText('my_crops'),
                    subtitle: LanguageController.instance.getText('my_crops_desc'),
                    icon: Icons.grass_rounded,
                    cardColor: AppColors.cardRose,
                    iconColor: const Color(0xFF8C3E52),
                  ),
                ),

                const SizedBox(height: 14),

                AnimatedPressable(
                  pressedScale: 0.95,
                  onTap: () {
                    // Navigate to Articles & Guides
                  },
                  child: _buildStackedFeatureCard(
                    title: LanguageController.instance.getText('articles'),
                    subtitle: LanguageController.instance.getText('articles_desc'),
                    icon: Icons.menu_book_rounded,
                    cardColor: AppColors.cardLavender,
                    iconColor: const Color(0xFF533B78),
                  ),
                ),

                const SizedBox(height: 14),

                AnimatedPressable(
                  pressedScale: 0.95,
                  onTap: () {
                    // Navigate to AI Chat
                  },
                  child: _buildStackedFeatureCard(
                    title: LanguageController.instance.getText('chat'),
                    subtitle: LanguageController.instance.getText('chat_desc'),
                    icon: Icons.forum_rounded,
                    cardColor: AppColors.cardMint,
                    iconColor: const Color(0xFF2E634F),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Top Card featuring Greeting, Date, Live Weather, and Rain Prediction
  Widget _buildWeatherGreetingCard(bool isSinhala) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkPill,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageController.instance.getText('welcome'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('📅 ', style: TextStyle(fontSize: 14)),
                        Text(
                          isSinhala ? '2026 සැප්තැම්බර් 30 | බදාදා' : 'Wed, Sep 30, 2026',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withAlpha(30), height: 1),
          const SizedBox(height: 16),

          // Weather Details Row (Live Temperature & Condition)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⛅ ', style: TextStyle(fontSize: 26)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '28°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        LanguageController.instance.getText('partly_cloudy'),
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Rain Prediction Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Text('🌧️ ', style: TextStyle(fontSize: 14)),
                    Text(
                      isSinhala ? 'වැසි: 20%' : 'Rain: 20%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Stacked Feature Card Widget
  Widget _buildStackedFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Icon Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800, // Extra bold font styling
                    color: AppColors.lavenderDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lavenderDarkText.withAlpha(190),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Arrow Navigation Button
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.darkPill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
