import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/language_controller.dart';

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

          // 3. Right side: Language Switcher Box (සිං | EN)
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  LanguageController.instance.toggleLanguage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkPill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(76)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSinhala ? 'සිං' : 'EN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
          ],
        );
      },
    );
  }
}
