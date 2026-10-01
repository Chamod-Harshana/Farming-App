import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/models/crop_model.dart';
import '../providers/crop_provider.dart';

/// Reusable Crop Card Widget strictly matching Home Page styling.
class CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onTap;
  final Color cardColor;

  const CropCard({
    super.key,
    required this.crop,
    required this.onTap,
    this.cardColor = AppColors.cardLavender,
  });

  @override
  Widget build(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;

    final String nameSiClean = crop.nameSi.trim();
    final String nameClean = crop.name.trim();

    String displayName = '';
    if (isSinhala) {
      displayName = nameSiClean.isNotEmpty && nameSiClean != '()'
          ? nameSiClean
          : (nameClean.isNotEmpty && nameClean != '()' ? nameClean : 'වගාව');
    } else {
      displayName = nameClean.isNotEmpty && nameClean != '()'
          ? nameClean
          : (nameSiClean.isNotEmpty && nameSiClean != '()' ? nameSiClean : 'Crop');
    }

    final categoryText = isSinhala
        ? (crop.categorySi.trim().isNotEmpty ? crop.categorySi : crop.category)
        : (crop.category.trim().isNotEmpty ? crop.category : crop.categorySi);

    return AnimatedPressable(
      pressedScale: 0.96,
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: crop.isPinned
              ? Border.all(color: AppColors.primary.withAlpha(180), width: 2)
              : Border.all(color: Colors.white.withAlpha(120), width: 1),
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
            // Crop Icon Avatar Container
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: _buildCropIcon(
                      crop.iconName,
                      crop.name,
                      crop.nameSi,
                      crop.category,
                    ),
                  ),
                ),
                if (crop.isPinned)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.push_pin,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Crop Details (Name, Category, Harvest Info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lavenderDarkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkPill.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoryText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkPill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action Icons when crop is Pinned or default navigation button
            if (crop.isPinned) ...[
              GestureDetector(
                onTap: () {
                  CropProvider.instance.togglePin(crop);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.push_pin_rounded,
                    color: Colors.amber.shade900,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  CropProvider.instance.moveToBin(crop);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Navigation Arrow Button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.darkPill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to pick appropriate Icon/Emoji for crop
  Widget _buildCropIcon(String iconName, String cropName, String cropNameSi, String category) {
    final name = ('$iconName $cropName $cropNameSi $category').toLowerCase();

    // Fruits
    if (name.contains('mango') || name.contains('අඹ')) return const Text('🥭', style: TextStyle(fontSize: 28));
    if (name.contains('guava') || name.contains('පේර')) return const Text('🍈', style: TextStyle(fontSize: 28));
    if (name.contains('papaya') || name.contains('ගස්ලබු')) return const Text('🍈', style: TextStyle(fontSize: 28));
    if (name.contains('banana') || name.contains('කෙසෙල්')) return const Text('🍌', style: TextStyle(fontSize: 28));
    if (name.contains('pineapple') || name.contains('අන්නාසි')) return const Text('🍍', style: TextStyle(fontSize: 28));
    if (name.contains('avocado') || name.contains('අලිපේර')) return const Text('🥑', style: TextStyle(fontSize: 28));
    if (name.contains('rambutan') || name.contains('රම්බුටන්')) return const Text('🔴', style: TextStyle(fontSize: 28));
    if (name.contains('dragon') || name.contains('ඩ්‍රැගන්')) return const Text('🐲', style: TextStyle(fontSize: 28));
    if (name.contains('watermelon') || name.contains('කොමඩු')) return const Text('🍉', style: TextStyle(fontSize: 28));
    if (name.contains('woodapple') || name.contains('දිවුල්')) return const Text('🥥', style: TextStyle(fontSize: 28));
    if (name.contains('apple') || name.contains('ඇපල්')) return const Text('🍎', style: TextStyle(fontSize: 28));
    if (name.contains('grapes') || name.contains('මිදි')) return const Text('🍇', style: TextStyle(fontSize: 28));
    if (name.contains('strawberry') || name.contains('ස්ට්‍රෝබෙරි')) return const Text('🍓', style: TextStyle(fontSize: 28));
    if (name.contains('orange') || name.contains('දොඩම්')) return const Text('🍊', style: TextStyle(fontSize: 28));
    if (name.contains('lemon') || name.contains('දෙහි')) return const Text('🍋', style: TextStyle(fontSize: 28));

    // Vegetables
    if (name.contains('tomato') || name.contains('තක්කාලි')) return const Text('🍅', style: TextStyle(fontSize: 28));
    if (name.contains('chili') || name.contains('මිරිස්')) return const Text('🌶️', style: TextStyle(fontSize: 28));
    if (name.contains('brinjal') || name.contains('වම්බටු')) return const Text('🍆', style: TextStyle(fontSize: 28));
    if (name.contains('carrot') || name.contains('කැරට්')) return const Text('🥕', style: TextStyle(fontSize: 28));
    if (name.contains('pumpkin') || name.contains('වට්ටක්කා')) return const Text('🎃', style: TextStyle(fontSize: 28));
    if (name.contains('bittergourd') || name.contains('කරවිල')) return const Text('🥒', style: TextStyle(fontSize: 28));
    if (name.contains('cucumber') || name.contains('පිපිඤ්ඤා')) return const Text('🥒', style: TextStyle(fontSize: 28));
    if (name.contains('potato') || name.contains('අල')) return const Text('🥔', style: TextStyle(fontSize: 28));
    if (name.contains('cabbage') || name.contains('ගෝවා')) return const Text('🥬', style: TextStyle(fontSize: 28));
    if (name.contains('radish') || name.contains('රාබු')) return const Text('🥕', style: TextStyle(fontSize: 28));
    if (name.contains('corn') || name.contains('ඉරිඟු')) return const Text('🌽', style: TextStyle(fontSize: 28));
    if (name.contains('mushroom') || name.contains('හතු')) return const Text('🍄', style: TextStyle(fontSize: 28));
    if (name.contains('garlic') || name.contains('සුදුලූනු')) return const Text('🧄', style: TextStyle(fontSize: 28));
    if (name.contains('onion') || name.contains('ලූනු')) return const Text('🧅', style: TextStyle(fontSize: 28));
    if (name.contains('broccoli') || name.contains('බ්‍රොකොලි')) return const Text('🥦', style: TextStyle(fontSize: 28));

    // Flowers
    if (name.contains('rose') || name.contains('රෝස')) return const Text('🌹', style: TextStyle(fontSize: 28));
    if (name.contains('anthurium') || name.contains('ඇන්තූරියම්')) return const Text('🌺', style: TextStyle(fontSize: 28));
    if (name.contains('orchid') || name.contains('ඕකිට්')) return const Text('🌸', style: TextStyle(fontSize: 28));
    if (name.contains('jasmine') || name.contains('පිච්ච')) return const Text('💮', style: TextStyle(fontSize: 28));
    if (name.contains('lotus') || name.contains('නෙළුම්')) return const Text('🪷', style: TextStyle(fontSize: 28));
    if (name.contains('bougainvillea') || name.contains('කඩදාසි')) return const Text('🌸', style: TextStyle(fontSize: 28));
    if (name.contains('hibiscus') || name.contains('වද')) return const Text('🌺', style: TextStyle(fontSize: 28));
    if (name.contains('marigold') || name.contains('දස්පෙති')) return const Text('🌼', style: TextStyle(fontSize: 28));
    if (name.contains('sunflower') || name.contains('සූරියකාන්ත')) return const Text('🌻', style: TextStyle(fontSize: 28));
    if (name.contains('gerbera') || name.contains('ගර්බෙරා')) return const Text('🌼', style: TextStyle(fontSize: 28));
    if (name.contains('tulip') || name.contains('ටියුලිප්')) return const Text('🌷', style: TextStyle(fontSize: 28));
    if (name.contains('cherry') || name.contains('සකුරා')) return const Text('🌸', style: TextStyle(fontSize: 28));

    // Grains, Spices & Cash Crops
    if (name.contains('rice') || name.contains('paddy') || name.contains('ගොයම්') || name.contains('වී')) return const Text('🌾', style: TextStyle(fontSize: 28));
    if (name.contains('greengram') || name.contains('මුං')) return const Text('🫘', style: TextStyle(fontSize: 28));
    if (name.contains('cowpea') || name.contains('කව්පි')) return const Text('🫘', style: TextStyle(fontSize: 28));
    if (name.contains('tea') || name.contains('තේ')) return const Text('🍃', style: TextStyle(fontSize: 28));
    if (name.contains('cinnamon') || name.contains('කුරුඳු')) return const Text('🪵', style: TextStyle(fontSize: 28));
    if (name.contains('coconut') || name.contains('පොල්')) return const Text('🥥', style: TextStyle(fontSize: 28));
    if (name.contains('pepper') || name.contains('ගම්මිරිස්')) return const Text('🫑', style: TextStyle(fontSize: 28));
    if (name.contains('coffee') || name.contains('කෝපි')) return const Text('☕', style: TextStyle(fontSize: 28));
    if (name.contains('cocoa') || name.contains('කොකෝවා')) return const Text('🍫', style: TextStyle(fontSize: 28));
    if (name.contains('cardamom') || name.contains('කරාබුනැටි')) return const Text('🌿', style: TextStyle(fontSize: 28));

    // Category fallbacks
    if (category.contains('Fruit') || category.contains('පළතුරු')) return const Text('🍎', style: TextStyle(fontSize: 28));
    if (category.contains('Vegetable') || category.contains('එළවළු')) return const Text('🥬', style: TextStyle(fontSize: 28));
    if (category.contains('Flower') || category.contains('මල්')) return const Text('🌸', style: TextStyle(fontSize: 28));
    if (category.contains('Grain') || category.contains('ධාන්‍ය')) return const Text('🌾', style: TextStyle(fontSize: 28));

    return const Icon(Icons.eco_rounded, color: AppColors.primary, size: 30);
  }

  /// Context menu triggered on Long Press
  void _showContextMenu(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;
    final isPinned = crop.isPinned;

    final String nameSiClean = crop.nameSi.trim();
    final String nameClean = crop.name.trim();
    final String displayName = isSinhala
        ? (nameSiClean.isNotEmpty && nameSiClean != '()' ? nameSiClean : nameClean)
        : (nameClean.isNotEmpty && nameClean != '()' ? nameClean : nameSiClean);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCropIcon(crop.iconName, crop.name, crop.nameSi, crop.category),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lavenderDarkText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPinned ? Colors.amber.shade100 : AppColors.lightLavender,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                      color: isPinned ? Colors.amber.shade900 : AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    isPinned
                        ? (isSinhala ? 'පින් එක ඉවත් කරන්න (Unpin)' : 'Unpin from Top')
                        : (isSinhala ? 'ඉහළටම පින් කරන්න (Pin to Top)' : 'Pin to Top'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    CropProvider.instance.togglePin(crop);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                  title: Text(
                    isSinhala ? 'බින් එකට දමන්න (Move to Bin)' : 'Move to Bin',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    CropProvider.instance.moveToBin(crop);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}