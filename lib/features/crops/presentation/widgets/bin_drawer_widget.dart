import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../domain/models/crop_model.dart';
import '../providers/crop_provider.dart';

/// Modal Bottom Sheet for viewing & restoring items in the Recycle Bin.
class BinModalSheet extends StatefulWidget {
  const BinModalSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BinModalSheet(),
    );
  }

  @override
  State<BinModalSheet> createState() => _BinModalSheetState();
}

class _BinModalSheetState extends State<BinModalSheet> {
  @override
  Widget build(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;
    final binCrops = CropProvider.instance.binCrops;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isSinhala ? 'ඉවත් කළ වගාවන් (Recycle Bin)' : 'Recycle Bin',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lavenderDarkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: binCrops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_sweep_outlined,
                              size: 54,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isSinhala ? 'බින් එක හිස්ව පවතී' : 'Recycle Bin is empty',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lavenderDarkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSinhala
                                  ? 'ඉවත් කරන ලද වගාවන් මෙහි සටහන් වේ'
                                  : 'Crops moved to bin will appear here',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: binCrops.length,
                        itemBuilder: (context, index) {
                          final crop = binCrops[index];
                          final String namePrimary = isSinhala
                              ? (crop.nameSi.isNotEmpty ? crop.nameSi : crop.name)
                              : (crop.name.isNotEmpty ? crop.name : crop.nameSi);
                          final String nameSecondary = isSinhala ? crop.name : crop.nameSi;
                          final String displayName = (nameSecondary.isNotEmpty && nameSecondary != namePrimary)
                              ? ' ()'
                              : namePrimary;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardRose.withAlpha(120),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.lavenderDarkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isSinhala ? crop.categorySi : crop.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Restore Button
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    CropProvider.instance.restoreFromBin(crop);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.restore_from_trash_rounded, size: 18),
                                  label: Text(
                                    isSinhala ? 'නැවත ගන්න' : 'Restore',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                // Permanent Delete Button
                                IconButton(
                                  tooltip: isSinhala ? 'සදාකාලිකවම මකන්න' : 'Permanently Delete',
                                  icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                                  onPressed: () => _confirmPermanentDelete(context, crop),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmPermanentDelete(BuildContext context, CropModel crop) {
    final isSinhala = LanguageController.instance.isSinhala;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSinhala ? 'සදාකාලිකවම මකා දැමීම' : 'Permanently Delete'),
        content: Text(
          isSinhala
              ? 'ඔබට මෙම වගාව () දත්ත ගබඩාවෙන් සදාකාලිකවම මකා දැමීමට අවශ්‍යද?'
              : 'Are you sure you want to permanently delete "" from local storage?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSinhala ? 'අවලංගු කරන්න' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              CropProvider.instance.deletePermanently(crop);
              setState(() {});
            },
            child: Text(
              isSinhala ? 'මකන්න' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
