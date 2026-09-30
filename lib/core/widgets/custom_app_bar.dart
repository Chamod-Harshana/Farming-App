import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/language_controller.dart';
import 'animated_pressable.dart';

/// Reusable Custom Top Navigation Bar displaying Govi Mithuru official logo
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleOverride;

  const CustomAppBar({super.key, this.titleOverride});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, currentLang, child) {
        final isSinhala = currentLang == 'si';
        return AppBar(
          backgroundColor: AppColors.lightLavender,
          elevation: 1,
          surfaceTintColor: AppColors.lightLavender,
          centerTitle: true,

          // 1. Left side: Hamburger 3-lines menu icon
          leading: Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppColors.lavenderDarkText,
                size: 28,
              ),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
              tooltip: 'Open Menu',
            ),
          ),

          // 2. Center: Official "Govi Mithuru" Logo Image (Does not change on language switch)
          title: Image.asset(
            'assets/images/logo.png',
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.eco_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Govi Mithuru',
                    style: TextStyle(
                      color: AppColors.lavenderDarkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Right side: Language Switcher Box (සිං | EN) with Animated Press Feedback
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedPressable(
                pressedScale: 0.90,
                onTap: () {
                  LanguageController.instance.toggleLanguage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.darkPill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withAlpha(90), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Row(
                      key: ValueKey<bool>(isSinhala),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSinhala ? 'සිං' : 'EN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
