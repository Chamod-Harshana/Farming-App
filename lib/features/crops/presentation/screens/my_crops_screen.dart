import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_app_drawer.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_card.dart';
import '../widgets/add_crop_card_tile.dart';
import '../widgets/bin_drawer_widget.dart';
import 'crop_detail_screen.dart';

/// Fully functional "My Crops" Screen for Agriculture App
class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    CropProvider.instance.init();
    CropProvider.instance.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    CropProvider.instance.removeListener(_onProviderChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, child) {
        final isSinhala = LanguageController.instance.isSinhala;
        final provider = CropProvider.instance;
        final crops = provider.filteredActiveCrops;

        final cardColors = [
          AppColors.cardRose,
          AppColors.cardLavender,
          AppColors.cardMint,
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(),
          drawer: const CustomAppDrawer(),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SafeArea(
                  child: Column(
                    children: [
                      // Scrollable Main Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Page Header Title styled matching Home Page
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.darkPill,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LanguageController.instance.getText('my_crops'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isSinhala
                                              ? 'ඔබ විසින් සුරකින ලද සියලුම වගාවන්'
                                              : 'Manage & track your saved crops',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(190),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.grass_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 2. Active Crops List Grid
                              if (crops.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.eco_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        provider.searchQuery.isNotEmpty
                                            ? (isSinhala
                                                ? 'සෙවුමට ගැළපෙන වගාවන් නොමැත'
                                                : 'No crops match your search')
                                            : (isSinhala
                                                ? 'තවම කිසිදු වගාවක් එකතු කර නොමැත'
                                                : 'No crops added yet'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lavenderDarkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSinhala
                                            ? 'පහත බෝතනයෙන් නව වගාවක් එකතු කරගන්න'
                                            : 'Tap "Add New Crop" card below to add crops',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: crops.length,
                                  itemBuilder: (context, index) {
                                    final crop = crops[index];
                                    final cardColor = cardColors[index % cardColors.length];

                                    return CropCard(
                                      crop: crop,
                                      cardColor: cardColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CropDetailScreen(crop: crop),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),

                              // 3. Floating 'Add New Crop' Card Tile (placed under crop list)
                              const AddCropCardTile(),
                            ],
                          ),
                        ),
                      ),

                      // 4. CENTERED RECYCLE BIN BUTTON RIGHT ABOVE SEARCH BAR
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              BinModalSheet.show(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.darkPill,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSinhala ? 'ඉවත් කළ වගාවන් (Bin)' : 'Recycle Bin',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (provider.binCrops.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 5. SEARCH BAR (Positioned at the bottom of the page)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            CropProvider.instance.setSearchQuery(val);
                          },
                          decoration: InputDecoration(
                            hintText: isSinhala
                                ? 'වගාවන් සෙවීම... (Mango, Guava, Papaya, අඹ, පේර...)'
                                : 'Search crops (Mango, Guava, Papaya...)...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      CropProvider.instance.setSearchQuery('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
