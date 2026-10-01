import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/language_controller.dart';
import '../../data/datasources/crop_master_data.dart';
import '../../domain/models/crop_model.dart';
import '../providers/crop_provider.dart';

/// Modal search & selection sheet for picking or adding crops.
class AddCropModalSheet extends StatefulWidget {
  const AddCropModalSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCropModalSheet(),
    );
  }

  @override
  State<AddCropModalSheet> createState() => _AddCropModalSheetState();
}

class _AddCropModalSheetState extends State<AddCropModalSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSinhala = LanguageController.instance.isSinhala;
    final activeCrops = CropProvider.instance.activeCrops;
    final activeCropIds = activeCrops.map((c) => c.id).toSet();

    // Filter master list based on search query and category chip
    final filteredMaster = CropMasterData.masterCrops.where((crop) {
      // Category filter
      if (_selectedCategory != 'ALL') {
        if (_selectedCategory == 'Fruit' && crop.category != 'Fruit') return false;
        if (_selectedCategory == 'Vegetable' && crop.category != 'Vegetable') return false;
        if (_selectedCategory == 'Ornamental Flower' && crop.category != 'Ornamental Flower') return false;
        if (_selectedCategory == 'Grain' && crop.category != 'Grain') return false;
        if (_selectedCategory == 'Spice' && (crop.category != 'Spice' && crop.category != 'Cash Crop')) return false;
      }

      // Search query filter
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final matchName = crop.name.toLowerCase().contains(q);
      final matchNameSi = crop.nameSi.toLowerCase().contains(q);
      final matchCat = crop.category.toLowerCase().contains(q);
      final matchCatSi = crop.categorySi.toLowerCase().contains(q);
      return matchName || matchNameSi || matchCat || matchCatSi;
    }).toList();

    final hasExactMatch = filteredMaster.any((c) {
      final q = _searchQuery.trim().toLowerCase();
      return c.name.toLowerCase() == q || c.nameSi.toLowerCase() == q;
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSinhala ? 'නව වගාවක් එකතු කරන්න' : 'Add New Crop',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lavenderDarkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSinhala
                              ? 'පළතුරු, එළවළු, විසිතුරු මල්, ධාන්‍ය කැටලොගයෙන් තෝරන්න'
                              : 'Pick Fruits, Vegetables, Flowers & more',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
              const SizedBox(height: 14),

              // 1. Search / Type Crop Name Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: isSinhala
                        ? 'වගාවේ නම ඇතුළත් කරන්න... (අඹ, පේර, තක්කාලි, රෝස...)'
                        : 'Type crop name... (Mango, Rose, Tomato...)',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Category Selector Chips Bar directly below input box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('ALL', isSinhala ? 'සියල්ල' : 'All'),
                      _buildCategoryChip('Fruit', isSinhala ? 'පළතුරු' : 'Fruit'),
                      _buildCategoryChip('Vegetable', isSinhala ? 'එළවළු' : 'Vegetable'),
                      _buildCategoryChip('Ornamental Flower', isSinhala ? 'විසිතුරු මල්' : 'Flowers'),
                      _buildCategoryChip('Grain', isSinhala ? 'ධාන්‍ය' : 'Grain'),
                      _buildCategoryChip('Spice', isSinhala ? 'කුළුබඩු/වාණිජ' : 'Spices'),
                    ],
                  ),
                ),
              ),

              const Divider(height: 20),

              // 3. Crops List View
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  children: [
                    // Option to add typed custom crop if typed text is non-empty and not exact match
                    if (_searchQuery.trim().isNotEmpty && !hasExactMatch)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardMint,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _buildCropEmoji('', _searchQuery, _searchQuery),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _searchQuery.trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.lavenderDarkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSinhala
                                        ? '(${_getCategorySi(_selectedCategory)} ලෙස එකතු කරන්න)'
                                        : '(Add as ${_getCategoryEn(_selectedCategory)})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addCustomCrop(context, _searchQuery.trim()),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(isSinhala ? 'එකතු කරන්න' : 'Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (filteredMaster.isEmpty && _searchQuery.trim().isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            isSinhala ? 'මෙම වර්ගයට අදාළ වගාවන් නොමැත' : 'No crops found in this category',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...filteredMaster.map((masterCrop) {
                        final isAlreadyAdded = activeCropIds.contains(masterCrop.id);
                        final String cropTitle = isSinhala ? masterCrop.nameSi : masterCrop.name;
                        final String categorySub = isSinhala
                            ? '(${masterCrop.categorySi})'
                            : '(${masterCrop.category})';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAlreadyAdded ? Colors.grey.shade300 : AppColors.lightLavender,
                            ),
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
                              // 1. Far Left: Image/Icon Circle
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.lightLavender.withAlpha(120),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _buildCropEmoji(
                                    masterCrop.iconName,
                                    masterCrop.name,
                                    masterCrop.nameSi,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // 2. Middle Column: Name & Category in Parentheses
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cropTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: AppColors.lavenderDarkText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      categorySub,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3. Far Right: Add Button (+ එකතු කරන්න / + Add)
                              ElevatedButton.icon(
                                onPressed: isAlreadyAdded
                                    ? null
                                    : () async {
                                        final nav = Navigator.of(context);
                                        final success = await CropProvider.instance.addCrop(masterCrop);
                                        if (mounted && success) {
                                          nav.pop();
                                        }
                                      },
                                icon: Icon(
                                  isAlreadyAdded ? Icons.check_rounded : Icons.add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  isAlreadyAdded
                                      ? (isSinhala ? 'එකතු කර ඇත' : 'Added')
                                      : (isSinhala ? 'එකතු කරන්න' : 'Add'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyAdded ? Colors.grey.shade300 : AppColors.darkPill,
                                  foregroundColor: isAlreadyAdded ? Colors.grey.shade700 : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String catKey, String label) {
    final isSelected = _selectedCategory == catKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = catKey;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPill : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkPill : AppColors.lightLavender,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.lavenderDarkText,
          ),
        ),
      ),
    );
  }

  String _getCategorySi(String cat) {
    switch (cat) {
      case 'Fruit':
        return 'පළතුරු';
      case 'Vegetable':
        return 'එළවළු';
      case 'Ornamental Flower':
        return 'විසිතුරු මල්';
      case 'Grain':
        return 'ධාන්‍ය';
      case 'Spice':
        return 'කුළුබඩු/වාණිජ';
      default:
        return 'පළතුරු';
    }
  }

  String _getCategoryEn(String cat) {
    switch (cat) {
      case 'Fruit':
        return 'Fruit';
      case 'Vegetable':
        return 'Vegetable';
      case 'Ornamental Flower':
        return 'Ornamental Flower';
      case 'Grain':
        return 'Grain';
      case 'Spice':
        return 'Spice/Cash Crop';
      default:
        return 'Fruit';
    }
  }

  Widget _buildCropEmoji(String iconName, String cropName, String cropNameSi) {
    final name = ('$iconName $cropName $cropNameSi').toLowerCase();

    // Fruits
    if (name.contains('mango') || name.contains('අඹ')) return const Text('🥭', style: TextStyle(fontSize: 26));
    if (name.contains('guava') || name.contains('පේර')) return const Text('🍈', style: TextStyle(fontSize: 26));
    if (name.contains('papaya') || name.contains('ගස්ලබු')) return const Text('🍈', style: TextStyle(fontSize: 26));
    if (name.contains('banana') || name.contains('කෙසෙල්')) return const Text('🍌', style: TextStyle(fontSize: 26));
    if (name.contains('pineapple') || name.contains('අන්නාසි')) return const Text('🍍', style: TextStyle(fontSize: 26));
    if (name.contains('avocado') || name.contains('අලිපේර')) return const Text('🥑', style: TextStyle(fontSize: 26));
    if (name.contains('rambutan') || name.contains('රම්බුටන්')) return const Text('🔴', style: TextStyle(fontSize: 26));
    if (name.contains('dragon') || name.contains('ඩ්‍රැගන්')) return const Text('🐲', style: TextStyle(fontSize: 26));
    if (name.contains('watermelon') || name.contains('කොමඩු')) return const Text('🍉', style: TextStyle(fontSize: 26));
    if (name.contains('woodapple') || name.contains('දිවුල්')) return const Text('🥥', style: TextStyle(fontSize: 26));
    if (name.contains('apple') || name.contains('ඇපල්')) return const Text('🍎', style: TextStyle(fontSize: 26));
    if (name.contains('grapes') || name.contains('මිදි')) return const Text('🍇', style: TextStyle(fontSize: 26));
    if (name.contains('strawberry') || name.contains('ස්ට්‍රෝබෙරි')) return const Text('🍓', style: TextStyle(fontSize: 26));
    if (name.contains('orange') || name.contains('දොඩම්')) return const Text('🍊', style: TextStyle(fontSize: 26));
    if (name.contains('lemon') || name.contains('දෙහි')) return const Text('🍋', style: TextStyle(fontSize: 26));

    // Vegetables
    if (name.contains('tomato') || name.contains('තක්කාලි')) return const Text('🍅', style: TextStyle(fontSize: 26));
    if (name.contains('chili') || name.contains('මිරිස්')) return const Text('🌶️', style: TextStyle(fontSize: 26));
    if (name.contains('brinjal') || name.contains('වම්බටු')) return const Text('🍆', style: TextStyle(fontSize: 26));
    if (name.contains('carrot') || name.contains('කැරට්')) return const Text('🥕', style: TextStyle(fontSize: 26));
    if (name.contains('pumpkin') || name.contains('වට්ටක්කා')) return const Text('🎃', style: TextStyle(fontSize: 26));
    if (name.contains('bittergourd') || name.contains('කරවිල')) return const Text('🥒', style: TextStyle(fontSize: 26));
    if (name.contains('cucumber') || name.contains('පිපිඤ්ඤා')) return const Text('🥒', style: TextStyle(fontSize: 26));
    if (name.contains('potato') || name.contains('අල')) return const Text('🥔', style: TextStyle(fontSize: 26));
    if (name.contains('cabbage') || name.contains('ගෝවා')) return const Text('🥬', style: TextStyle(fontSize: 26));
    if (name.contains('radish') || name.contains('රාබු')) return const Text('🥕', style: TextStyle(fontSize: 26));
    if (name.contains('corn') || name.contains('ඉරිඟු')) return const Text('🌽', style: TextStyle(fontSize: 26));
    if (name.contains('mushroom') || name.contains('හතු')) return const Text('🍄', style: TextStyle(fontSize: 26));
    if (name.contains('garlic') || name.contains('සුදුලූනු')) return const Text('🧄', style: TextStyle(fontSize: 26));
    if (name.contains('onion') || name.contains('ලූනු')) return const Text('🧅', style: TextStyle(fontSize: 26));
    if (name.contains('broccoli') || name.contains('බ්‍රොකොලි')) return const Text('🥦', style: TextStyle(fontSize: 26));

    // Flowers
    if (name.contains('rose') || name.contains('රෝස')) return const Text('🌹', style: TextStyle(fontSize: 26));
    if (name.contains('anthurium') || name.contains('ඇන්තූරියම්')) return const Text('🌺', style: TextStyle(fontSize: 26));
    if (name.contains('orchid') || name.contains('ඕකිට්')) return const Text('🌸', style: TextStyle(fontSize: 26));
    if (name.contains('jasmine') || name.contains('පිච්ච')) return const Text('💮', style: TextStyle(fontSize: 26));
    if (name.contains('lotus') || name.contains('නෙළුම්')) return const Text('🪷', style: TextStyle(fontSize: 26));
    if (name.contains('bougainvillea') || name.contains('කඩදාසි')) return const Text('🌸', style: TextStyle(fontSize: 26));
    if (name.contains('hibiscus') || name.contains('වද')) return const Text('🌺', style: TextStyle(fontSize: 26));
    if (name.contains('marigold') || name.contains('දස්පෙති')) return const Text('🌼', style: TextStyle(fontSize: 26));
    if (name.contains('sunflower') || name.contains('සූරියකාන්ත')) return const Text('🌻', style: TextStyle(fontSize: 26));
    if (name.contains('gerbera') || name.contains('ගර්බෙරා')) return const Text('🌼', style: TextStyle(fontSize: 26));
    if (name.contains('tulip') || name.contains('ටියුලිප්')) return const Text('🌷', style: TextStyle(fontSize: 26));
    if (name.contains('cherry') || name.contains('සකුරා')) return const Text('🌸', style: TextStyle(fontSize: 26));

    // Grains, Spices & Cash Crops
    if (name.contains('rice') || name.contains('paddy') || name.contains('ගොයම්') || name.contains('වී')) return const Text('🌾', style: TextStyle(fontSize: 26));
    if (name.contains('greengram') || name.contains('මුං')) return const Text('🫘', style: TextStyle(fontSize: 26));
    if (name.contains('cowpea') || name.contains('කව්පි')) return const Text('🫘', style: TextStyle(fontSize: 26));
    if (name.contains('tea') || name.contains('තේ')) return const Text('🍃', style: TextStyle(fontSize: 26));
    if (name.contains('cinnamon') || name.contains('කුරුඳු')) return const Text('🪵', style: TextStyle(fontSize: 26));
    if (name.contains('coconut') || name.contains('පොල්')) return const Text('🥥', style: TextStyle(fontSize: 26));
    if (name.contains('pepper') || name.contains('ගම්මිරිස්')) return const Text('🫑', style: TextStyle(fontSize: 26));
    if (name.contains('coffee') || name.contains('කෝපි')) return const Text('☕', style: TextStyle(fontSize: 26));
    if (name.contains('cocoa') || name.contains('කොකෝවා')) return const Text('🍫', style: TextStyle(fontSize: 26));
    if (name.contains('cardamom') || name.contains('කරාබුනැටි')) return const Text('🌿', style: TextStyle(fontSize: 26));

    return const Icon(Icons.eco_rounded, color: AppColors.primary, size: 28);
  }

  void _addCustomCrop(BuildContext context, String typedName) async {
    if (typedName.trim().isEmpty) return;

    final nav = Navigator.of(context);
    final catEn = _selectedCategory == 'ALL' ? 'Fruit' : _selectedCategory;
    final catSi = _getCategorySi(catEn);

    final customCrop = CropModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: typedName,
      nameSi: typedName,
      category: catEn,
      categorySi: catSi,
      iconName: typedName.toLowerCase(),
      imagePath: '',
      description: 'Custom added crop by farmer.',
      descriptionSi: 'ගොවියා විසින් එකතු කරන ලද වගාවකි.',
      soilType: 'Standard Garden Soil',
      soilTypeSi: 'සාමාන්‍ය ගෙවතු පස',
      harvestDays: 60,
      waterFrequency: 'Regular',
      waterFrequencySi: 'නිතිපතා',
      idealTemp: '25°C',
    );

    await CropProvider.instance.addCrop(customCrop);
    if (mounted) {
      nav.pop();
    }
  }
}