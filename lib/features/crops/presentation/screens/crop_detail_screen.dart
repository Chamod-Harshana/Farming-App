import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_app_drawer.dart';
import '../../data/datasources/crop_database_helper.dart';
import '../../domain/models/crop_model.dart';
import '../../domain/models/irrigation_log_model.dart';
import '../../domain/models/fertilizer_log_model.dart';
import '../../domain/models/pesticide_log_model.dart';
import '../../domain/models/financial_record_model.dart';

/// Production-Ready Smart Agriculture Crop Detail Screen
/// Configured per user specifications:
/// 1. Section Order: Irrigation -> Fertilizer -> Pesticides -> Financial -> General Notes
/// 2. Initially Empty logs (no hardcoded items) with Add, Edit, and Delete actions
/// 3. Growth Progress Bar Removed
/// 4. Footer Pin/Bin buttons Removed
/// 5. Irrigation log card matching reference image with notification card placed under the list.
class CropDetailScreen extends StatefulWidget {
  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  late CropModel _crop;
  List<IrrigationLogModel> _irrigationLogs = [];
  List<FertilizerLogModel> _fertilizerLogs = [];
  List<PesticideLogModel> _pesticideLogs = [];
  List<FinancialRecordModel> _financialRecords = [];

  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _irrigationKey = GlobalKey();
  final GlobalKey _fertilizerKey = GlobalKey();
  final GlobalKey _pesticideKey = GlobalKey();
  final GlobalKey _financialKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();

  bool _isSavingNotes = false;
  bool _isLoadingLogs = true;
  String _activeTab = 'Irrigation';

  @override
  void initState() {
    super.initState();
    _crop = widget.crop;
    _notesController.text = _crop.notes;
    _loadAllLogs();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLogs() async {
    setState(() => _isLoadingLogs = true);
    final db = CropDatabaseHelper.instance;
    final irrigs = await db.getIrrigationLogs(_crop.id);
    final ferts = await db.getFertilizerLogs(_crop.id);
    final pests = await db.getPesticideLogs(_crop.id);
    final fins = await db.getFinancialRecords(_crop.id);

    if (mounted) {
      setState(() {
        _irrigationLogs = irrigs;
        _fertilizerLogs = ferts;
        _pesticideLogs = pests;
        _financialRecords = fins;
        _isLoadingLogs = false;
      });
    }
  }

  void _scrollToKey(GlobalKey key, String tabName) {
    setState(() => _activeTab = tabName);
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // ==========================================
  // CALCULATIONS (Financial Summary)
  // ==========================================
  double get _totalIncome => _financialRecords
      .where((r) => r.isIncome)
      .fold(0.0, (sum, r) => sum + r.amount);

  double get _totalExpenses => _financialRecords
      .where((r) => r.isExpense)
      .fold(0.0, (sum, r) => sum + r.amount);

  double get _netProfitLoss => _totalIncome - _totalExpenses;

  String get _estimatedHarvestDateStr {
    final plantDate = _crop.plantDate ?? _crop.createdAt;
    final totalHarvestDays = _crop.harvestDays > 0 ? _crop.harvestDays : 90;
    final estDate = plantDate.add(Duration(days: totalHarvestDays));
    final remainingDays = totalHarvestDays - DateTime.now().difference(plantDate).inDays;

    final formattedDate = DateFormat('yyyy-MM-dd').format(estDate);
    if (remainingDays <= 0) {
      return '$formattedDate (Ready!)';
    }
    final months = (remainingDays / 30).ceil();
    return '$formattedDate (In ${remainingDays > 30 ? "$months Mos" : "$remainingDays Days"})';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, child) {
        final isSinhala = LanguageController.instance.isSinhala;

        final String nameSiClean = _crop.nameSi.trim();
        final String nameClean = _crop.name.trim();

        String displayName = '';
        if (isSinhala) {
          displayName = nameSiClean.isNotEmpty && nameSiClean != '()'
              ? '$nameSiClean (${nameClean.isNotEmpty ? nameClean : nameSiClean})'
              : (nameClean.isNotEmpty ? nameClean : 'වගාව');
        } else {
          displayName = nameClean.isNotEmpty && nameClean != '()'
              ? '$nameClean (${nameSiClean.isNotEmpty ? nameSiClean : nameClean})'
              : (nameSiClean.isNotEmpty ? nameSiClean : 'Crop');
        }

        final categoryText = isSinhala
            ? (_crop.categorySi.trim().isNotEmpty ? _crop.categorySi : _crop.category)
            : (_crop.category.trim().isNotEmpty ? _crop.category : _crop.categorySi);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F6F4),
          appBar: const CustomAppBar(),
          drawer: const CustomAppDrawer(),
          body: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER BANNER CARD
                _buildTopBannerHeader(displayName, categoryText, isSinhala),

                const SizedBox(height: 16),

                // 2. OVERVIEW & QUICK STATS CARDS (Without Growth Progress Bar)
                _buildOverviewAndQuickStats(isSinhala),

                const SizedBox(height: 16),

                // 3. NAVIGATION TAB SELECTOR BAR (Irrigation, Fertilizer, Pesticide, Financial, Notes)
                _buildNavigationTabs(isSinhala),

                const SizedBox(height: 18),

                // 4. IRRIGATION LOG SECTION (1st Stacked Card - Placed above Fertilizer & Pesticides)
                KeyedSubtree(
                  key: _irrigationKey,
                  child: _buildIrrigationSection(isSinhala),
                ),

                const SizedBox(height: 18),

                // 5. FERTILIZER MANAGEMENT SECTION (2nd Stacked Card)
                KeyedSubtree(
                  key: _fertilizerKey,
                  child: _buildFertilizerSection(isSinhala),
                ),

                const SizedBox(height: 18),

                // 6. PESTICIDE / CROP PROTECTION SECTION (3rd Stacked Card)
                KeyedSubtree(
                  key: _pesticideKey,
                  child: _buildPesticideSection(isSinhala),
                ),

                const SizedBox(height: 18),

                // 7. FINANCIAL MANAGEMENT SECTION (4th Stacked Card - Placed after Fertilizer & Pesticides)
                KeyedSubtree(
                  key: _financialKey,
                  child: _buildFinancialSection(isSinhala),
                ),

                const SizedBox(height: 18),

                // 8. GENERAL NOTES & OBSERVATIONS SECTION
                KeyedSubtree(
                  key: _notesKey,
                  child: _buildGeneralNotesSection(isSinhala),
                ),

                const SizedBox(height: 20),

                // 9. VIEW COMPLETE GUIDE BUTTON (Pin & Bin buttons removed)
                _buildFooterGuideButton(isSinhala),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. TOP BANNER HEADER CARD
  // ==========================================
  Widget _buildTopBannerHeader(String displayName, String categoryText, bool isSinhala) {
    final dateStr = _crop.plantDate != null
        ? DateFormat('yyyy-MM-dd').format(_crop.plantDate!)
        : DateFormat('yyyy-MM-dd').format(_crop.createdAt);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A2B), Color(0xFF2E5A44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.eco,
              size: 160,
              color: Colors.white.withAlpha(15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSinhala ? 'බෝග විස්තර' : 'Crop Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
                      onPressed: () => _showEditCropModal(isSinhala),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade300, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Center(
                        child: _buildCropIcon(_crop.iconName, _crop.name, _crop.nameSi, _crop.category),
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
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            categoryText.isNotEmpty ? categoryText : 'Oryza sativa',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.spa_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  isSinhala ? 'වර්ධනය වෙමින්' : 'Growing',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A2B),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _showEditCropModal(isSinhala),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(isSinhala ? 'සංස්කරණය' : 'Edit', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStatChip(Icons.calendar_month_rounded, dateStr),
                        _buildHeaderStatDivider(),
                        _buildHeaderStatChip(Icons.square_foot_rounded, _crop.landSize),
                        _buildHeaderStatDivider(),
                        _buildHeaderStatChip(Icons.numbers_rounded, '${_crop.plantCount} Plants'),
                        _buildHeaderStatDivider(),
                        _buildHeaderStatChip(Icons.wb_sunny_rounded, '28°C - Partly Cloudy'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF81C784), size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatDivider() {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withAlpha(50),
    );
  }

  // ==========================================
  // 2. OVERVIEW & QUICK STATS CARDS (No Progress Bar)
  // ==========================================
  Widget _buildOverviewAndQuickStats(bool isSinhala) {
    final dateStr = _crop.plantDate != null
        ? DateFormat('yyyy-MM-dd').format(_crop.plantDate!)
        : DateFormat('yyyy-MM-dd').format(_crop.createdAt);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        Widget overviewCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grass_rounded, color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isSinhala ? 'බෝග සාරාංශය' : 'Crop Overview',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showEditOverviewDialog(isSinhala),
                    child: const ContainerPill(label: 'Edit', icon: Icons.edit),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildMiniDetailTile(
                      icon: Icons.calendar_today_rounded,
                      title: isSinhala ? 'රෝපණ දිනය' : 'Planting Date',
                      value: dateStr,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniDetailTile(
                      icon: Icons.aspect_ratio_rounded,
                      title: isSinhala ? 'ඉඩම් ප්‍රමාණය' : 'Land Size',
                      value: _crop.landSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniDetailTile(
                      icon: Icons.eco_outlined,
                      title: isSinhala ? 'පැල ගණන' : 'Plant Count',
                      value: '${_crop.plantCount}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniDetailTile(
                      icon: Icons.event_available_rounded,
                      title: isSinhala ? 'අස්වනු දිනය' : 'Estimated Harvest',
                      value: _estimatedHarvestDateStr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        Widget quickStatsCard = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'ඉක්මන් සංඛ්‍යාලේඛන' : 'Quick Stats',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatChipBox(
                      icon: Icons.forest_rounded,
                      title: isSinhala ? 'පැල' : 'Plants',
                      value: '${_crop.plantCount}',
                      subtitle: isSinhala ? '(වර්තමාන)' : '(Current)',
                      bgColor: const Color(0xFFE8F5E9),
                      textColor: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatChipBox(
                      icon: Icons.attach_money_rounded,
                      title: isSinhala ? 'මුළු ආදායම' : 'Total Income',
                      value: 'Rs. ${_totalIncome.toStringAsFixed(0)}',
                      subtitle: isSinhala ? '(මෙම බෝගය)' : '(This Crop)',
                      bgColor: const Color(0xFFE8F5E9),
                      textColor: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatChipBox(
                      icon: Icons.receipt_long_rounded,
                      title: isSinhala ? 'මුළු වියදම' : 'Total Expense',
                      value: 'Rs. ${_totalExpenses.toStringAsFixed(0)}',
                      subtitle: isSinhala ? '(මෙම බෝගය)' : '(This Crop)',
                      bgColor: const Color(0xFFFFEBEE),
                      textColor: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: overviewCard),
              const SizedBox(width: 16),
              Expanded(child: quickStatsCard),
            ],
          );
        } else {
          return Column(
            children: [
              overviewCard,
              const SizedBox(height: 14),
              quickStatsCard,
            ],
          );
        }
      },
    );
  }

  Widget _buildMiniDetailTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChipBox({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 16),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9, color: textColor.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. TAB SELECTOR NAVIGATION BAR
  // ==========================================
  Widget _buildNavigationTabs(bool isSinhala) {
    final tabs = [
      {'id': 'Irrigation', 'label': isSinhala ? 'ජල සම්පාදනය' : 'Irrigation', 'icon': Icons.water_drop_rounded, 'key': _irrigationKey},
      {'id': 'Fertilizer', 'label': isSinhala ? 'පොහොර' : 'Fertilizer', 'icon': Icons.eco_rounded, 'key': _fertilizerKey},
      {'id': 'Pesticide', 'label': isSinhala ? 'පළිබෝධ' : 'Pesticide', 'icon': Icons.security_rounded, 'key': _pesticideKey},
      {'id': 'Financial', 'label': isSinhala ? 'මුදල්' : 'Financial', 'icon': Icons.account_balance_wallet_rounded, 'key': _financialKey},
      {'id': 'Notes', 'label': isSinhala ? 'සටහන්' : 'Notes', 'icon': Icons.article_rounded, 'key': _notesKey},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = _activeTab == tab['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  tab['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF00897B),
                ),
                label: Text(
                  tab['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF1E3A2B),
                backgroundColor: const Color(0xFFF1F5F2),
                onSelected: (val) {
                  _scrollToKey(tab['key'] as GlobalKey, tab['id'] as String);
                },
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // 4. IRRIGATION LOG SECTION (PLACED ABOVE FERTILIZER & PESTICIDES)
  // ==========================================
  Widget _buildIrrigationSection(bool isSinhala) {
    final hasScheduledLog = _irrigationLogs.any((log) => log.nextDate != null);
    final nextScheduledLog = _irrigationLogs.firstWhere(
      (log) => log.nextDate != null,
      orElse: () => IrrigationLogModel(
        id: '',
        cropId: _crop.id,
        date: DateTime.now(),
        amount: '',
        time: '',
        method: '',
        nextDate: null,
        notify: false,
      ),
    );

    final nextDateStr = nextScheduledLog.nextDate != null
        ? DateFormat('yyyy-MM-dd').format(nextScheduledLog.nextDate!)
        : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matching design image
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: Color(0xFF00897B), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSinhala ? 'ජල සම්පාදනය' : 'Irrigation Log',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      isSinhala
                          ? 'නියමිත පරිදි ජලය සම්පාදනය කිරීම'
                          : 'Watering helps maintain soil moisture.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showIrrigationModal(isSinhala),
                icon: const Icon(Icons.add, size: 16),
                label: Text(isSinhala ? 'එක්කරන්න' : 'Add', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),

          // Main Irrigation Logs List
          if (_isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (_irrigationLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      isSinhala ? 'තවම ජල සම්පාදන සටහන් එකතු කර නොමැත.' : 'No irrigation logs added yet.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSinhala ? '" එකතු කරන්න" ඔබා පළමු සටහන එක්කරන්න.' : 'Tap "+ Add" to add your first record.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _irrigationLogs.length,
              itemBuilder: (context, index) {
                final log = _irrigationLogs[index];
                final dateStr = DateFormat('yyyy-MM-dd').format(log.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2F9E8)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2F1),
                        radius: 16,
                        child: Icon(Icons.water_drop, color: Color(0xFF00897B), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Text(log.time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Spacer(),
                      if (log.amount.isNotEmpty && log.amount != 'Watered' && log.amount != 'ජලය යෙදීම') ...[
                        Text(log.amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFB2DFDB)),
                        ),
                        child: Text(log.method, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00695C))),
                      ),
                      const SizedBox(width: 6),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showIrrigationModal(isSinhala, existingLog: log);
                          } else if (val == 'delete') {
                            _confirmDeleteLog(
                              isSinhala: isSinhala,
                              title: '$dateStr ${log.time}',
                              onDelete: () async {
                                await CropDatabaseHelper.instance.deleteIrrigationLog(_crop.id, log.id);
                                await _loadAllLogs();
                              },
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 16), const SizedBox(width: 8), Text(isSinhala ? 'සංස්කරණය' : 'Edit')])),
                          PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, size: 16, color: Colors.red), const SizedBox(width: 8), Text(isSinhala ? 'මකන්න' : 'Delete', style: const TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          if (hasScheduledLog && nextScheduledLog.nextDate != null) ...[
            const SizedBox(height: 14),

            // IRRIGATION NOTIFICATION REMINDER BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FDF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF2E7D32), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isSinhala ? 'ඊළඟ ජල සම්පාදන මතක් කිරීම' : 'Next Irrigation Reminder',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                      Switch(
                        value: nextScheduledLog.notify,
                        activeThumbColor: const Color(0xFF2E7D32),
                        onChanged: (val) async {
                          if (nextScheduledLog.id.isNotEmpty) {
                            final updated = IrrigationLogModel(
                              id: nextScheduledLog.id,
                              cropId: nextScheduledLog.cropId,
                              date: nextScheduledLog.date,
                              time: nextScheduledLog.time,
                              amount: nextScheduledLog.amount,
                              method: nextScheduledLog.method,
                              nextDate: nextScheduledLog.nextDate,
                              notify: val,
                            );
                            await CropDatabaseHelper.instance.insertIrrigationLog(updated);
                            await _loadAllLogs();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 6),
                      Text(
                        '$nextDateStr · ${nextScheduledLog.time}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDE7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFF59D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, color: Color(0xFFF57F17), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSinhala
                                ? 'ඊළඟ ජල සම්පාදන වේලාවට පෙර ඔබට මතක් කිරීමේ Notification එකක් ලැබෙනු ඇත.'
                                : "You'll receive a notification before the next irrigation time.",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                          ),
                        ),
                        const Icon(Icons.settings_outlined, color: Color(0xFF5D4037), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 5. FERTILIZER MANAGEMENT SECTION (SECOND)
  // ==========================================
  Widget _buildFertilizerSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSinhala ? 'පොහොර කළමනාකරණය' : 'Fertilizer Management',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showFertilizerModal(isSinhala),
                icon: const Icon(Icons.add, size: 16),
                label: Text(isSinhala ? 'එක්කරන්න' : 'Add', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),

          if (_isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (_fertilizerLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.eco_outlined, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      isSinhala ? 'තවම පොහොර යෙදීම් සටහන් එකතු කර නොමැත.' : 'No fertilizer records added yet.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSinhala ? '" Add Fertilizer" ඔබා පළමු සටහන එකතු කරන්න.' : 'Tap "+ Add Fertilizer" to record a application.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fertilizerLogs.length,
              itemBuilder: (context, index) {
                final log = _fertilizerLogs[index];
                final dateStr = DateFormat('yyyy-MM-dd').format(log.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text(log.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(log.quantity, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showFertilizerModal(isSinhala, existingLog: log);
                          } else if (val == 'delete') {
                            _confirmDeleteLog(
                              isSinhala: isSinhala,
                              title: log.name,
                              onDelete: () async {
                                await CropDatabaseHelper.instance.deleteFertilizerLog(_crop.id, log.id);
                                await _loadAllLogs();
                              },
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 16), const SizedBox(width: 8), Text(isSinhala ? 'සංස්කරණය' : 'Edit')])),
                          PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, size: 16, color: Colors.red), const SizedBox(width: 8), Text(isSinhala ? 'මකන්න' : 'Delete', style: const TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. PESTICIDE / CROP PROTECTION SECTION (THIRD)
  // ==========================================
  Widget _buildPesticideSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSinhala ? 'පළිබෝධ / බෝග ආරක්ෂණය' : 'Pesticide / Crop Protection',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showPesticideModal(isSinhala),
                icon: const Icon(Icons.add, size: 16),
                label: Text(isSinhala ? 'එක්කරන්න' : 'Add', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),

          if (_isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (_pesticideLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.shield_outlined, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      isSinhala ? 'තවම පළිබෝධ නාශක සටහන් එකතු කර නොමැත.' : 'No pesticide records added yet.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSinhala ? '" Add Pesticide" ඔබා සටහනක් එකතු කරන්න.' : 'Tap "+ Add Pesticide" to add crop protection record.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pesticideLogs.length,
              itemBuilder: (context, index) {
                final log = _pesticideLogs[index];
                final dateStr = DateFormat('yyyy-MM-dd').format(log.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bug_report_rounded, color: Color(0xFFE65100), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text(log.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(log.quantity, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showPesticideModal(isSinhala, existingLog: log);
                          } else if (val == 'delete') {
                            _confirmDeleteLog(
                              isSinhala: isSinhala,
                              title: log.name,
                              onDelete: () async {
                                await CropDatabaseHelper.instance.deletePesticideLog(_crop.id, log.id);
                                await _loadAllLogs();
                              },
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 16), const SizedBox(width: 8), Text(isSinhala ? 'සංස්කරණය' : 'Edit')])),
                          PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, size: 16, color: Colors.red), const SizedBox(width: 8), Text(isSinhala ? 'මකන්න' : 'Delete', style: const TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. FINANCIAL MANAGEMENT SECTION (FOURTH - PLACED AFTER FERTILIZER & PESTICIDES)
  // ==========================================
  Widget _buildFinancialSection(bool isSinhala) {
    final expenses = _financialRecords.where((r) => r.isExpense).toList();
    final incomes = _financialRecords.where((r) => r.isIncome).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2E7D32), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'මුදල් කළමනාකරණය' : 'Financial Management',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildSummaryBadge('Total Exp: Rs. ${_totalExpenses.toStringAsFixed(0)}', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
                  const SizedBox(width: 6),
                  _buildSummaryBadge('Total Inc: Rs. ${_totalIncome.toStringAsFixed(0)}', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              Widget expensesCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isSinhala ? 'වියදම්' : 'Expenses', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  if (expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(isSinhala ? 'තවම වියදම් සටහන් නොමැත.' : 'No expense records yet.', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    )
                  else
                    ...expenses.map((rec) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 6),
                                Text(DateFormat('yyyy-MM-dd').format(rec.date), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                Text(rec.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Rs. ${rec.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showFinancialModal(isSinhala, existingRecord: rec, isIncome: false);
                                    } else if (val == 'delete') {
                                      _confirmDeleteLog(
                                        isSinhala: isSinhala,
                                        title: rec.description,
                                        onDelete: () async {
                                          await CropDatabaseHelper.instance.deleteFinancialRecord(_crop.id, rec.id);
                                          await _loadAllLogs();
                                        },
                                      );
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(value: 'edit', child: Text(isSinhala ? 'සංස්කරණය' : 'Edit')),
                                    PopupMenuItem(value: 'delete', child: Text(isSinhala ? 'මකන්න' : 'Delete', style: const TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showFinancialModal(isSinhala, isIncome: false),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(isSinhala ? 'වියදම් එක්කරන්න' : 'Add Expense'),
                    ),
                  ),
                ],
              );

              Widget incomesCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isSinhala ? 'ආදායම් / අස්වැන්න' : 'Harvest / Income', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  if (incomes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(isSinhala ? 'තවම ආදායම් සටහන් නොමැත.' : 'No income records yet.', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    )
                  else
                    ...incomes.map((rec) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFF1F8F5), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 14),
                                const SizedBox(width: 6),
                                Text(DateFormat('yyyy-MM-dd').format(rec.date), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                Text(rec.yieldQuantity ?? rec.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Rs. ${rec.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showFinancialModal(isSinhala, existingRecord: rec, isIncome: true);
                                    } else if (val == 'delete') {
                                      _confirmDeleteLog(
                                        isSinhala: isSinhala,
                                        title: rec.description,
                                        onDelete: () async {
                                          await CropDatabaseHelper.instance.deleteFinancialRecord(_crop.id, rec.id);
                                          await _loadAllLogs();
                                        },
                                      );
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(value: 'edit', child: Text(isSinhala ? 'සංස්කරණය' : 'Edit')),
                                    PopupMenuItem(value: 'delete', child: Text(isSinhala ? 'මකන්න' : 'Delete', style: const TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showFinancialModal(isSinhala, isIncome: true),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(isSinhala ? 'ආදායම් එක්කරන්න' : 'Add Harvest / Income'),
                    ),
                  ),
                ],
              );

              Widget chartCol = Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(isSinhala ? 'ආදායම සහ වියදම' : 'Income vs Expenses', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CustomPaint(
                        painter: IncomeExpenseRingPainter(
                          incomeRatio: (_totalIncome + _totalExpenses) > 0 ? (_totalIncome / (_totalIncome + _totalExpenses)) : 0.5,
                          incomeColor: const Color(0xFF2E7D32),
                          expenseColor: const Color(0xFFE53935),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rs. ${_netProfitLoss.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A2B)),
                              ),
                              Text(
                                isSinhala ? 'ශුද්ධ ලාභය' : 'Net Profit',
                                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChartLegend(const Color(0xFF2E7D32), 'Income'),
                        const SizedBox(width: 12),
                        _buildChartLegend(const Color(0xFFE53935), 'Expenses'),
                      ],
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: expensesCol),
                    const SizedBox(width: 14),
                    Expanded(flex: 3, child: incomesCol),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: chartCol),
                  ],
                );
              } else {
                return Column(
                  children: [
                    expensesCol,
                    const SizedBox(height: 16),
                    incomesCol,
                    const SizedBox(height: 16),
                    chartCol,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildChartLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  // ==========================================
  // 8. GENERAL NOTES & OBSERVATIONS SECTION
  // ==========================================
  Widget _buildGeneralNotesSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_rounded, color: Color(0xFF2E7D32), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'විශේෂ සටහන්' : 'General Notes',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveNotes,
                icon: _isSavingNotes
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 14),
                label: Text(isSinhala ? 'සුරකින්න' : 'Save', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 20),

          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              hintText: isSinhala
                  ? 'පස් තත්ත්වය, බෝග වර්ධනය හෝ වෙනත් සටහන් මෙහි ටයිප් කරන්න...'
                  : 'Enter diary notes, soil conditions, observations...',
              fillColor: const Color(0xFFF7F9F8),
              filled: true,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildSoilNoteTile(
                  icon: Icons.landscape_rounded,
                  title: 'Soil Type',
                  value: _crop.soilType.isNotEmpty ? _crop.soilType : 'Loamy Soil',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSoilNoteTile(
                  icon: Icons.water_drop_rounded,
                  title: 'Watering',
                  value: _crop.waterFrequency.isNotEmpty ? _crop.waterFrequency : 'Regular',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSoilNoteTile(
                  icon: Icons.grass_rounded,
                  title: 'Growth Stage',
                  value: 'Growing',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoilNoteTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _saveNotes() async {
    setState(() => _isSavingNotes = true);
    final updated = _crop.copyWith(notes: _notesController.text.trim());
    await CropDatabaseHelper.instance.updateCrop(updated);
    setState(() {
      _crop = updated;
      _isSavingNotes = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageController.instance.isSinhala ? 'සටහන් සුරකින ලදී!' : 'Notes saved successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================
  // 9. FOOTER ACTIONS (Guide Button only)
  // ==========================================
  Widget _buildFooterGuideButton(bool isSinhala) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A2B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
        ),
        onPressed: () => _showFullGuideModal(context, _crop, isSinhala),
        icon: const Icon(Icons.menu_book_rounded, size: 20),
        label: Text(
          isSinhala ? 'සම්පූර්ණ වගා මාර්ගෝපදේශය බලන්න' : 'View Complete Crop Guide',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL SHEETS & DIALOGS
  // ==========================================

  void _confirmDeleteLog({required bool isSinhala, required String title, required VoidCallback onDelete}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSinhala ? 'තහවුරු කරන්න' : 'Confirm Delete'),
        content: Text(isSinhala ? '"$title" සටහන ඉවත් කිරීමට ඔබට විශ්වාසද?' : 'Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isSinhala ? 'අවලංගු කරන්න' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text(isSinhala ? 'මකන්න' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showIrrigationModal(bool isSinhala, {IrrigationLogModel? existingLog}) {
    DateTime selectedDate = existingLog?.date ?? DateTime.now();
    final timeCtrl = TextEditingController(
      text: existingLog?.time ?? DateFormat('hh:mm a').format(DateTime.now()),
    );
    final amtCtrl = TextEditingController(text: existingLog?.amount != 'Watered' && existingLog?.amount != 'ජලය යෙදීම' ? (existingLog?.amount ?? '') : '');
    String selectedMethod = existingLog?.method ?? 'Manual';
    DateTime? nextDate = existingLog?.nextDate;
    bool notify = existingLog?.notify ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setMState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingLog != null
                      ? (isSinhala ? 'ජල සම්පාදන සටහන සංස්කරණය' : 'Edit Irrigation Record')
                      : (isSinhala ? 'නව ජල සම්පාදන සටහනක් එක්කරන්න' : 'Quick Add Irrigation'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isSinhala
                      ? 'දිනය සහ වේලාව පමණක් පිරවීම ප්‍රමාණවත් වේ.'
                      : 'Selecting date and time is sufficient.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // 1. DATE PICKER ROW (Defaults to today)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF00897B), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${isSinhala ? "දිනය" : "Date"}: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setMState(() => selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                        label: Text(isSinhala ? 'වෙනස් කරන්න' : 'Change'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. TIME FIELD (Optional, defaults to current time)
                TextField(
                  controller: timeCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'වේලාව (අත්‍යවශ්‍ය නොවේ)' : 'Time (Optional, e.g. 08:00 AM)',
                    hintText: '08:00 AM',
                    prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFF00897B)),
                  ),
                ),

                const SizedBox(height: 10),

                // 3. OPTIONAL DETAILS (Amount, Method & Next Reminder)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    isSinhala ? 'අමතර තොරතුරු (ජල ප්‍රමාණය, ක්‍රමය) - අත්‍යවශ්‍ය නොවේ' : 'Additional Details (Water Amount, Method) - Optional',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    TextField(
                      controller: amtCtrl,
                      decoration: InputDecoration(
                        labelText: isSinhala ? 'ජල ප්‍රමාණය (උදා: 12 L)' : 'Water Amount (Optional, e.g. 12 L)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: InputDecoration(labelText: isSinhala ? 'ක්‍රමය (Method)' : 'Method'),
                      items: ['Manual', 'Drip', 'Sprinkler', 'Flood']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setMState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nextDate != null
                                ? '${isSinhala ? "ඊළඟ දිනය" : "Next Date"}: ${DateFormat('yyyy-MM-dd').format(nextDate!)}'
                                : (isSinhala ? 'ඊළඟ දිනය තෝරන්න' : 'Select Next Irrigation Date'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: nextDate ?? DateTime.now().add(const Duration(days: 2)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setMState(() => nextDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: Text(isSinhala ? 'තෝරන්න' : 'Pick'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 4. SAVE BUTTON (Saves without blocking!)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final timeStr = timeCtrl.text.trim().isNotEmpty
                          ? timeCtrl.text.trim()
                          : DateFormat('hh:mm a').format(DateTime.now());

                      final amountStr = amtCtrl.text.trim().isNotEmpty
                          ? amtCtrl.text.trim()
                          : (isSinhala ? 'ජලය යෙදීම' : 'Watered');

                      final log = IrrigationLogModel(
                        id: existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        cropId: _crop.id,
                        date: selectedDate,
                        time: timeStr,
                        amount: amountStr,
                        method: selectedMethod,
                        nextDate: nextDate,
                        notify: notify,
                      );

                      await CropDatabaseHelper.instance.insertIrrigationLog(log);

                      if (notify && nextDate != null) {
                        await NotificationService.instance.scheduleNotification(
                          id: log.id.hashCode,
                          title: isSinhala ? 'ජල සම්පාදන මතක් කිරීම 💧' : 'Irrigation Reminder 💧',
                          body: isSinhala
                              ? '${_crop.nameSi} සඳහා ජල සම්පාදනය කිරීමට කාලයයි!'
                              : 'Time to water ${_crop.name}!',
                          scheduledDate: nextDate!,
                        );
                      }

                      await _loadAllLogs();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(
                      isSinhala ? 'සුරකින්න (Quick Save)' : 'Quick Save',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFertilizerModal(bool isSinhala, {FertilizerLogModel? existingLog}) {
    final nameCtrl = TextEditingController(text: existingLog?.name ?? '');
    final qtyCtrl = TextEditingController(text: existingLog?.quantity ?? '');
    DateTime? nextDate = existingLog?.nextDate;
    bool notify = existingLog?.notify ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setMState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingLog != null
                      ? (isSinhala ? 'පොහොර සටහන සංස්කරණය' : 'Edit Fertilizer Record')
                      : (isSinhala ? 'නව පොහොර යෙදීමක් එක්කරන්න' : 'Add Fertilizer Record'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'පොහොර වර්ගය / නම (උදා: Urea)' : 'Fertilizer Name (e.g. Urea)',
                  ),
                ),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'ප්‍රමාණය (උදා: 50 kg)' : 'Quantity (e.g. 50 kg)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nextDate != null
                            ? '${isSinhala ? "ඊළඟ දිනය" : "Next Date"}: ${DateFormat('yyyy-MM-dd').format(nextDate!)}'
                            : (isSinhala ? 'ඊළඟ දිනය තෝරන්න' : 'Select Next Date'),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setMState(() => nextDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(isSinhala ? 'තෝරන්න' : 'Pick'),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: Text(isSinhala ? 'මතක් කිරීම් Notification සබල කරන්න' : 'Remind me via Notification'),
                  value: notify,
                  onChanged: (val) => setMState(() => notify = val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;

                      final log = FertilizerLogModel(
                        id: existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        cropId: _crop.id,
                        date: existingLog?.date ?? DateTime.now(),
                        name: nameCtrl.text.trim(),
                        quantity: qtyCtrl.text.trim(),
                        nextDate: nextDate,
                        notify: notify,
                      );

                      await CropDatabaseHelper.instance.insertFertilizerLog(log);

                      if (notify && nextDate != null) {
                        await NotificationService.instance.scheduleNotification(
                          id: log.id.hashCode,
                          title: isSinhala ? 'පොහොර යෙදීමේ මතක් කිරීම 🌿' : 'Fertilizer Reminder 🌿',
                          body: isSinhala
                              ? '${_crop.nameSi} සඳහා ${log.name} (${log.quantity}) යෙදීමට කාලයයි!'
                              : 'Time to apply ${log.name} (${log.quantity}) on ${_crop.name}!',
                          scheduledDate: nextDate!,
                        );
                      }

                      await _loadAllLogs();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(isSinhala ? 'සුරකින්න' : 'Save Record'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPesticideModal(bool isSinhala, {PesticideLogModel? existingLog}) {
    final nameCtrl = TextEditingController(text: existingLog?.name ?? '');
    final qtyCtrl = TextEditingController(text: existingLog?.quantity ?? '');
    DateTime? nextDate = existingLog?.nextDate;
    bool notify = existingLog?.notify ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setMState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingLog != null
                      ? (isSinhala ? 'පළිබෝධ නාශක සටහන සංස්කරණය' : 'Edit Pesticide Record')
                      : (isSinhala ? 'නව පළිබෝධ නාශක යෙදීමක් එක්කරන්න' : 'Add Pesticide Record'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'පළිබෝධ නාශක නම (උදා: Neem Oil)' : 'Pesticide Name (e.g. Neem Oil)',
                  ),
                ),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'මාත්‍රාව (උදා: 10 ml/10L)' : 'Dosage (e.g. 10 ml/10L)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nextDate != null
                            ? '${isSinhala ? "ඊළඟ දිනය" : "Next Date"}: ${DateFormat('yyyy-MM-dd').format(nextDate!)}'
                            : (isSinhala ? 'ඊළඟ දිනය තෝරන්න' : 'Select Next Date'),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 20)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setMState(() => nextDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(isSinhala ? 'තෝරන්න' : 'Pick'),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: Text(isSinhala ? 'මතක් කිරීම් Notification සබල කරන්න' : 'Remind me via Notification'),
                  value: notify,
                  onChanged: (val) => setMState(() => notify = val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;

                      final log = PesticideLogModel(
                        id: existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        cropId: _crop.id,
                        date: existingLog?.date ?? DateTime.now(),
                        name: nameCtrl.text.trim(),
                        quantity: qtyCtrl.text.trim(),
                        nextDate: nextDate,
                        notify: notify,
                      );

                      await CropDatabaseHelper.instance.insertPesticideLog(log);

                      if (notify && nextDate != null) {
                        await NotificationService.instance.scheduleNotification(
                          id: log.id.hashCode,
                          title: isSinhala ? 'පළිබෝධ පාලන මතක් කිරීම 🛡️' : 'Pesticide Reminder 🛡️',
                          body: isSinhala
                              ? '${_crop.nameSi} සඳහා ${log.name} යෙදීමට කාලයයි!'
                              : 'Time for ${log.name} application on ${_crop.name}!',
                          scheduledDate: nextDate!,
                        );
                      }

                      await _loadAllLogs();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(isSinhala ? 'සුරකින්න' : 'Save Record'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFinancialModal(bool isSinhala, {FinancialRecordModel? existingRecord, required bool isIncome}) {
    final descCtrl = TextEditingController(text: existingRecord?.description ?? '');
    final amtCtrl = TextEditingController(text: existingRecord != null ? '${existingRecord.amount}' : '');
    final yieldCtrl = TextEditingController(text: existingRecord?.yieldQuantity ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existingRecord != null
                  ? (isSinhala ? 'මුදල් සටහන සංස්කරණය' : 'Edit Financial Record')
                  : (isIncome
                      ? (isSinhala ? 'අස්වනු / ආදායම් සටහනක් එක්කරන්න' : 'Add Harvest / Income Entry')
                      : (isSinhala ? 'වියදම් සටහනක් එක්කරන්න' : 'Add Expense Entry')),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIncome ? const Color(0xFF2E7D32) : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: isIncome
                    ? (isSinhala ? 'විස්තරය (උදා: පළමු අස්වැන්න විකිණීම)' : 'Description (e.g. Batch 1 Sale)')
                    : (isSinhala ? 'වියදම් හේතුව (උදා: බීජ මිලදී ගැනීම)' : 'Expense Reason (e.g. Seed Purchase)'),
              ),
            ),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isSinhala ? 'මුදල (Rs.)' : 'Amount (Rs.)',
              ),
            ),
            if (isIncome)
              TextField(
                controller: yieldCtrl,
                decoration: InputDecoration(
                  labelText: isSinhala ? 'අස්වනු ප්‍රමාණය (උදා: 1,000 kg)' : 'Harvest Yield (e.g. 1,000 kg)',
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIncome ? const Color(0xFF2E7D32) : Colors.red.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                  if (descCtrl.text.trim().isEmpty || amt <= 0) return;

                  final record = FinancialRecordModel(
                    id: existingRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    cropId: _crop.id,
                    type: isIncome ? 'income' : 'expense',
                    date: existingRecord?.date ?? DateTime.now(),
                    amount: amt,
                    description: descCtrl.text.trim(),
                    yieldQuantity: isIncome ? yieldCtrl.text.trim() : null,
                  );

                  await CropDatabaseHelper.instance.insertFinancialRecord(record);
                  await _loadAllLogs();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(isSinhala ? 'සුරකින්න' : 'Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCropModal(bool isSinhala) {
    final nameCtrl = TextEditingController(text: _crop.name);
    final nameSiCtrl = TextEditingController(text: _crop.nameSi);
    final catCtrl = TextEditingController(text: _crop.category);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSinhala ? 'බෝග තොරතුරු සංස්කරණය' : 'Edit Crop Metadata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: isSinhala ? 'නම (English)' : 'Name (English)'),
            ),
            TextField(
              controller: nameSiCtrl,
              decoration: InputDecoration(labelText: isSinhala ? 'නම (සිංහල)' : 'Name (Sinhala)'),
            ),
            TextField(
              controller: catCtrl,
              decoration: InputDecoration(labelText: isSinhala ? 'වර්ගය' : 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = _crop.copyWith(
                name: nameCtrl.text.trim(),
                nameSi: nameSiCtrl.text.trim(),
                category: catCtrl.text.trim(),
              );
              await CropDatabaseHelper.instance.updateCrop(updated);
              setState(() => _crop = updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditOverviewDialog(bool isSinhala) {
    DateTime selectedDate = _crop.plantDate ?? DateTime.now();
    final landCtrl = TextEditingController(text: _crop.landSize);
    final countCtrl = TextEditingController(text: '${_crop.plantCount}');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            title: Text(isSinhala ? 'වගා විස්තර යාවත්කාලීන කරන්න' : 'Update Overview Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(isSinhala ? 'රෝපණ දිනය' : 'Planting Date'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDlgState(() => selectedDate = picked);
                    }
                  },
                ),
                TextField(
                  controller: landCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'ඉඩම් ප්‍රමාණය (උදා: 1.25 Acres)' : 'Land Size (e.g. 1.25 Acres)',
                  ),
                ),
                TextField(
                  controller: countCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'පැල / ගස් ගණන' : 'Plant Count',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final updated = _crop.copyWith(
                    plantDate: selectedDate,
                    landSize: landCtrl.text.trim(),
                    plantCount: int.tryParse(countCtrl.text.trim()) ?? _crop.plantCount,
                  );
                  await CropDatabaseHelper.instance.updateCrop(updated);
                  setState(() => _crop = updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCropIcon(String iconName, String cropName, String cropNameSi, String category) {
    final name = ('$iconName $cropName $cropNameSi $category').toLowerCase();

    if (name.contains('mango') || name.contains('අඹ')) return const Text('🥭', style: TextStyle(fontSize: 38));
    if (name.contains('guava') || name.contains('පේර')) return const Text('🍈', style: TextStyle(fontSize: 38));
    if (name.contains('papaya') || name.contains('ගස්ලබු')) return const Text('🍈', style: TextStyle(fontSize: 38));
    if (name.contains('banana') || name.contains('කෙසෙල්')) return const Text('🍌', style: TextStyle(fontSize: 38));
    if (name.contains('pineapple') || name.contains('අන්නාසි')) return const Text('🍍', style: TextStyle(fontSize: 38));
    if (name.contains('avocado') || name.contains('අලිපේර')) return const Text('🥑', style: TextStyle(fontSize: 38));
    if (name.contains('watermelon') || name.contains('කොමඩු')) return const Text('🍉', style: TextStyle(fontSize: 38));
    if (name.contains('tomato') || name.contains('තක්කාලි')) return const Text('🍅', style: TextStyle(fontSize: 38));
    if (name.contains('chili') || name.contains('මිරිස්')) return const Text('🌶️', style: TextStyle(fontSize: 38));
    if (name.contains('brinjal') || name.contains('වම්බටු')) return const Text('🍆', style: TextStyle(fontSize: 38));
    if (name.contains('carrot') || name.contains('කැරට්')) return const Text('🥕', style: TextStyle(fontSize: 38));
    if (name.contains('potato') || name.contains('අල')) return const Text('🥔', style: TextStyle(fontSize: 38));
    if (name.contains('rose') || name.contains('රෝස')) return const Text('🌹', style: TextStyle(fontSize: 38));
    if (name.contains('orchid') || name.contains('ඕකිට්')) return const Text('🌸', style: TextStyle(fontSize: 38));
    if (name.contains('rice') || name.contains('vī') || name.contains('ගොයම්') || name.contains('වී')) return const Text('🌾', style: TextStyle(fontSize: 38));
    if (name.contains('coconut') || name.contains('පොල්')) return const Text('🥥', style: TextStyle(fontSize: 38));

    return const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 38);
  }

  void _showFullGuideModal(BuildContext context, CropModel crop, bool isSinhala) {
    final String titleName = isSinhala ? (crop.nameSi.isNotEmpty ? crop.nameSi : crop.name) : crop.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F6F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(22),
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
                      const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSinhala ? '$titleName සම්පූර්ණ වගා මාර්ගෝපදේශය' : 'Complete Guide: $titleName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lavenderDarkText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildGuideSection(
                    icon: Icons.landscape_rounded,
                    title: isSinhala ? '1. පස් පිළියෙල කිරීම සහ රෝපණය' : '1. Soil Preparation & Planting',
                    content: isSinhala
                        ? 'හොඳින් කාබනික පොහොර එකතු කළ, ජලය බැසයන ${crop.soilTypeSi} පස වඩාත් සුදුසු වේ. රෝපණයට පෙර පස බුරුල් කර දින 3-4ක් හිරු එළියට නිරාවරණය කරන්න.'
                        : 'Use well-drained ${crop.soilType} enriched with organic compost. Loosen soil and expose to sunlight for 3-4 days before planting.',
                  ),
                  _buildGuideSection(
                    icon: Icons.water_drop_rounded,
                    title: isSinhala ? '2. ජල සම්පාදනය සහ රැකවරණය' : '2. Irrigation & Moisture Care',
                    content: isSinhala
                        ? 'මෙම වගාව සඳහා ${crop.waterFrequencySi} ජලය සම්පාදනය කිරීම සුදුසුය. මුල් ආසන්නයේ ජලය පිරීමෙන් වළකින්න.'
                        : 'Irrigate ${crop.waterFrequency}. Avoid waterlogging near roots to prevent root rot.',
                  ),
                  _buildGuideSection(
                    icon: Icons.eco_rounded,
                    title: isSinhala ? '3. පොහොර යෙදීම සහ කෘමි මර්දනය' : '3. Fertilizer & Pest Protection',
                    content: isSinhala
                        ? 'වගාවේ මුල් මාසයේදී කාබනික කොම්පෝස්ට් සහ පසුව මසකට වරක් NPK පොහොර යොදන්න. කෘමීන් පාලනයට නිම් තෙල් යොදන්න.'
                        : 'Apply organic compost in first month, followed by balanced NPK fertilizer monthly. Spray neem oil for pest prevention.',
                  ),
                  _buildGuideSection(
                    icon: Icons.timer_rounded,
                    title: isSinhala ? '4. අස්වනු නෙලීම' : '4. Harvesting',
                    content: isSinhala
                        ? 'රෝපණයෙන් දින ${crop.harvestDays}ක් පමණ ගතවූ පසු පළමු අස්වැන්න නෙලාගත හැක.'
                        : 'Harvesting can be started approximately ${crop.harvestDays} days after planting.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lavenderDarkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.lavenderDarkText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper container pill for quick action buttons
class ContainerPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const ContainerPill({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Income vs Expense doughnut ring visual chart
class IncomeExpenseRingPainter extends CustomPainter {
  final double incomeRatio;
  final Color incomeColor;
  final Color expenseColor;

  IncomeExpenseRingPainter({
    required this.incomeRatio,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = expenseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    final incomePaint = Paint()
      ..color = incomeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * incomeRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      incomePaint,
    );
  }

  @override
  bool shouldRepaint(covariant IncomeExpenseRingPainter oldDelegate) {
    return oldDelegate.incomeRatio != incomeRatio;
  }
}