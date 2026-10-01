import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/animated_pressable.dart';
import 'add_crop_modal.dart';

/// Floating 'Add New Crop' Card widget styled like a crop card under the crop list.
class AddCropCardTile extends StatelessWidget {
  const AddCropCardTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;

    return AnimatedPressable(
      pressedScale: 0.95,
      onTap: () {
        AddCropModalSheet.show(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardMint,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withAlpha(100),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Floating Plus Icon Circle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSinhala ? 'නව වගාවක් එකතු කරන්න' : 'Add New Crop',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lavenderDarkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSinhala
                        ? 'ලැයිස්තුවෙන් හෝ නව වගාවක් තෝරා එකතු කරගන්න'
                        : 'Tap to pick or search from catalog',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lavenderDarkText.withAlpha(190),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow button
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.darkPill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
