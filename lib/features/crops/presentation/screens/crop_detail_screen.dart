import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_app_drawer.dart';
import '../../data/datasources/crop_database_helper.dart';
import '../../domain/models/crop_model.dart';
import '../../domain/models/fertilizer_log_model.dart';
import '../../domain/models/financial_record_model.dart';
import '../../domain/models/pesticide_log_model.dart';
import '../providers/crop_provider.dart';

/// Comprehensive, Production-Ready IoT Smart Agriculture Crop Detail Screen
class CropDetailScreen extends StatefulWidget {
  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  late CropModel _crop;
  List<FertilizerLogModel> _fertilizerLogs = [];
  List<PesticideLogModel> _pesticideLogs = [];
  List<FinancialRecordModel> _financialRecords = [];

  final TextEditingController _notesController = TextEditingController();
  bool _isSavingNotes = false;
  bool _isLoadingLogs = true;

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
    super.dispose();
  }

  Future<void> _loadAllLogs() async {
    setState(() => _isLoadingLogs = true);
    final db = CropDatabaseHelper.instance;
    final ferts = await db.getFertilizerLogs(_crop.id);
    final pests = await db.getPesticideLogs(_crop.id);
    final fins = await db.getFinancialRecords(_crop.id);

    if (mounted) {
      setState(() {
        _fertilizerLogs = ferts;
        _pesticideLogs = pests;
        _financialRecords = fins;
        _isLoadingLogs = false;
      });
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
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(),
          drawer: const CustomAppDrawer(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER CARD (Crop Name, Emoji Icon, Category & Edit Button)
                _buildHeaderCard(displayName, categoryText, isSinhala),

                const SizedBox(height: 18),

                // 2. CROP OVERVIEW CARD (Planting Date, Land Size, Plant Count)
                _buildOverviewCard(isSinhala),

                const SizedBox(height: 18),

                // 3. FERTILIZER MANAGEMENT SECTION
                _buildFertilizerSection(isSinhala),

                const SizedBox(height: 18),

                // 4. PESTICIDE / CROP PROTECTION SECTION
                _buildPesticideSection(isSinhala),

                const SizedBox(height: 18),

                // 5. FINANCIAL MANAGEMENT (Expenses & Income Summary)
                _buildFinancialSection(isSinhala),

                const SizedBox(height: 18),

                // 6. GENERAL NOTES SECTION
                _buildGeneralNotesSection(isSinhala),

                const SizedBox(height: 20),

                // 7. ACTION BUTTONS & FULL GUIDE MODAL
                _buildFooterActions(isSinhala),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. HEADER CARD
  // ==========================================
  Widget _buildHeaderCard(String displayName, String categoryText, bool isSinhala) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkPill,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
                onPressed: () => _showEditCropModal(isSinhala),
                tooltip: isSinhala ? 'තොරතුරු සංස්කරණය' : 'Edit Metadata',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildCropIcon(
                _crop.iconName,
                _crop.name,
                _crop.nameSi,
                _crop.category,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. CROP OVERVIEW CARD
  // ==========================================
  Widget _buildOverviewCard(bool isSinhala) {
    final dateStr = _crop.plantDate != null
        ? DateFormat('yyyy-MM-dd').format(_crop.plantDate!)
        : (isSinhala ? 'තවම සටහන් කර නැත' : 'Not set');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grass_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'වගා විස්තර සාරාංශය' : 'Crop Overview',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
                onPressed: () => _showEditOverviewDialog(isSinhala),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewTile(
                icon: Icons.calendar_today_rounded,
                title: isSinhala ? 'රෝපණය කළ දිනය' : 'Planting Date',
                value: dateStr,
                color: AppColors.cardMint,
              ),
              _buildOverviewTile(
                icon: Icons.square_foot_rounded,
                title: isSinhala ? 'ඉඩම් ප්‍රමාණය' : 'Land Size',
                value: _crop.landSize,
                color: AppColors.cardRose,
              ),
              _buildOverviewTile(
                icon: Icons.numbers_rounded,
                title: isSinhala ? 'පැල/ගස් ගණන' : 'Plant Count',
                value: '${_crop.plantCount}',
                color: AppColors.cardLavender,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkPill, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. FERTILIZER MANAGEMENT SECTION
  // ==========================================
  Widget _buildFertilizerSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'පොහොර යෙදීම් සටහන්' : 'Fertilizer Management',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddFertilizerModal(isSinhala),
                icon: const Icon(Icons.add, size: 18),
                label: Text(isSinhala ? 'එක්කරන්න' : 'Add Record', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(),
          if (_isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (_fertilizerLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  isSinhala ? 'තවම පොහොර සටහන් කිසිවක් නැත.' : 'No fertilizer records log added yet.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                final nextStr = log.nextDate != null
                    ? DateFormat('yyyy-MM-dd').format(log.nextDate!)
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardMint.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 18,
                        child: Icon(Icons.eco_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${isSinhala ? "ප්‍රමාණය" : "Qty"}: ${log.quantity}  |  $dateStr',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (nextStr != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alarm, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isSinhala ? "ඊළඟ දිනය" : "Next"}: $nextStr ${log.notify ? "🔔" : ""}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
  // 4. PESTICIDE / CROP PROTECTION SECTION
  // ==========================================
  Widget _buildPesticideSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'පළිබෝධ / බෝග ආරක්ෂණය' : 'Crop Protection',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddPesticideModal(isSinhala),
                icon: const Icon(Icons.add, size: 18),
                label: Text(isSinhala ? 'එක්කරන්න' : 'Add Record', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(),
          if (_isLoadingLogs)
            const Center(child: CircularProgressIndicator())
          else if (_pesticideLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  isSinhala ? 'තවම පළිබෝධ නාශක සටහන් කිසිවක් නැත.' : 'No pesticide records log added yet.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                final nextStr = log.nextDate != null
                    ? DateFormat('yyyy-MM-dd').format(log.nextDate!)
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 18,
                        child: Icon(Icons.bug_report_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${isSinhala ? "මාත්‍රාව" : "Dosage"}: ${log.quantity}  |  $dateStr',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (nextStr != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alarm, size: 12, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isSinhala ? "ඊළඟ දිනය" : "Next"}: $nextStr ${log.notify ? "🔔" : ""}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade900),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
  // 5. FINANCIAL MANAGEMENT SECTION
  // ==========================================
  Widget _buildFinancialSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'මුදල් සහ අස්වනු කළමනාකරණය' : 'Financial Management',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.redAccent),
                    onPressed: () => _showAddFinancialModal(isSinhala, isIncome: false),
                    tooltip: isSinhala ? 'වියදම් එක්කරන්න' : 'Add Expense',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_chart_rounded, color: Colors.green),
                    onPressed: () => _showAddFinancialModal(isSinhala, isIncome: true),
                    tooltip: isSinhala ? 'ආදායම් එක්කරන්න' : 'Add Income',
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 6),

          // SUMMARY CARDS (Income vs Expense vs Net)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(isSinhala ? 'මුළු ආදායම' : 'Total Income',
                          style: const TextStyle(fontSize: 11, color: Colors.green)),
                      const SizedBox(height: 2),
                      Text('Rs. ${_totalIncome.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(isSinhala ? 'මුළු වියදම' : 'Total Expense',
                          style: const TextStyle(fontSize: 11, color: Colors.red)),
                      const SizedBox(height: 2),
                      Text('Rs. ${_totalExpenses.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _netProfitLoss >= 0 ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(isSinhala ? 'ශුද්ධ ලාභය' : 'Net Profit',
                          style: TextStyle(
                              fontSize: 11,
                              color: _netProfitLoss >= 0 ? Colors.blue.shade800 : Colors.deepOrange)),
                      const SizedBox(height: 2),
                      Text('Rs. ${_netProfitLoss.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _netProfitLoss >= 0 ? Colors.blue.shade900 : Colors.deepOrange)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // FINANCIAL LOGS LIST
          if (_financialRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  isSinhala ? 'තවම මුදල් සටහන් කිසිවක් නැත.' : 'No financial records added yet.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _financialRecords.length,
              itemBuilder: (context, index) {
                final rec = _financialRecords[index];
                final dateStr = DateFormat('yyyy-MM-dd').format(rec.date);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: rec.isIncome ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      rec.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: rec.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    rec.description,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${rec.yieldQuantity != null ? " Yield: ${rec.yieldQuantity} | " : ""}$dateStr',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    '${rec.isIncome ? "+" : "-"} Rs. ${rec.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: rec.isIncome ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. GENERAL NOTES SECTION
  // ==========================================
  Widget _buildGeneralNotesSection(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: AppColors.darkPill),
                  const SizedBox(width: 8),
                  Text(
                    isSinhala ? 'විශේෂ සටහන් සහ නිරීක්ෂණ' : 'General Notes & Observations',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: _isSavingNotes
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_rounded, color: AppColors.primary),
                onPressed: _saveNotes,
                tooltip: isSinhala ? 'සුරකින්න' : 'Save Notes',
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isSinhala
                  ? 'පස් තත්ත්වය, බෝග වර්ධනය හෝ වෙනත් සටහන් මෙහි ටයිප් කරන්න...'
                  : 'Enter diary notes, soil conditions, observations...',
              fillColor: AppColors.background,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
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
          content: Text(LanguageController.instance.isSinhala
              ? 'සටහන් සුරකින ලදී!'
              : 'Notes saved successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================
  // 7. FOOTER ACTIONS
  // ==========================================
  Widget _buildFooterActions(bool isSinhala) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.darkPill),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  CropProvider.instance.togglePin(_crop);
                  setState(() {
                    _crop = _crop.copyWith(isPinned: !_crop.isPinned);
                  });
                },
                icon: Icon(_crop.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                label: Text(
                  _crop.isPinned ? 'Unpin' : 'Pin to Top',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  CropProvider.instance.moveToBin(_crop);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(isSinhala ? 'Move to Bin' : 'Move to Bin'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
            ),
            onPressed: () => _showFullGuideModal(context, _crop, isSinhala),
            icon: const Icon(Icons.menu_book_rounded, size: 22),
            label: Text(
              isSinhala ? 'සම්පූර්ණ වගා මාර්ගෝපදේශය බලන්න' : 'View Complete Crop Guide',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DIALOGS & MODAL SHEETS
  // ==========================================

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
                    labelText: isSinhala ? 'ඉඩම් ප්‍රමාණය (උදා: 2.5 Acres)' : 'Land Size (e.g. 2.5 Acres)',
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

  void _showAddFertilizerModal(bool isSinhala) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    DateTime? nextDate;
    bool notify = true;

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
                  isSinhala ? 'නව පොහොර යෙදීමක් එක්කරන්න' : 'Add Fertilizer Record',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'පොහොර වර්ගය / නම' : 'Fertilizer Name / Type',
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;

                      final log = FertilizerLogModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        cropId: _crop.id,
                        date: DateTime.now(),
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
                    child: Text(isSinhala ? 'එක්කරන්න' : 'Save Record'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPesticideModal(bool isSinhala) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    DateTime? nextDate;
    bool notify = true;

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
                  isSinhala ? 'නව පළිබෝධ නාශක යෙදීමක් එක්කරන්න' : 'Add Pesticide Record',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'පළිබෝධ නාශක නම' : 'Pesticide Name / Type',
                  ),
                ),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText: isSinhala ? 'මාත්‍රාව (උදා: 100 ml)' : 'Dosage / Quantity (e.g. 100 ml)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nextDate != null
                            ? '${isSinhala ? "ඊළඟ දිනය" : "Next Date"}: ${DateFormat('yyyy-MM-dd').format(nextDate!)}'
                            : (isSinhala ? 'ඊළඟ දිනය තෝරන්න' : 'Select Next Application Date'),
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
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;

                      final log = PesticideLogModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        cropId: _crop.id,
                        date: DateTime.now(),
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
                    child: Text(isSinhala ? 'එක්කරන්න' : 'Save Record'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddFinancialModal(bool isSinhala, {required bool isIncome}) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final yieldCtrl = TextEditingController();

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
              isIncome
                  ? (isSinhala ? 'අස්වනු / ආදායම් සටහනක් එක්කරන්න' : 'Add Harvest / Income Entry')
                  : (isSinhala ? 'වියදම් සටහනක් එක්කරන්න' : 'Add Expense Entry'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green.shade800 : Colors.red.shade800,
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
                  labelText: isSinhala ? 'අස්වනු ප්‍රමාණය (උදා: 250 kg)' : 'Harvest Yield (e.g. 250 kg)',
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIncome ? Colors.green.shade800 : Colors.red.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                  if (descCtrl.text.trim().isEmpty || amt <= 0) return;

                  final record = FinancialRecordModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    cropId: _crop.id,
                    type: isIncome ? 'income' : 'expense',
                    date: DateTime.now(),
                    amount: amt,
                    description: descCtrl.text.trim(),
                    yieldQuantity: isIncome ? yieldCtrl.text.trim() : null,
                  );

                  await CropDatabaseHelper.instance.insertFinancialRecord(record);
                  await _loadAllLogs();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(isSinhala ? 'එක්කරන්න' : 'Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropIcon(String iconName, String cropName, String cropNameSi, String category) {
    final name = ('$iconName $cropName $cropNameSi $category').toLowerCase();

    if (name.contains('mango') || name.contains('අඹ')) return const Text('🥭', style: TextStyle(fontSize: 44));
    if (name.contains('guava') || name.contains('පේර')) return const Text('🍈', style: TextStyle(fontSize: 44));
    if (name.contains('papaya') || name.contains('ගස්ලබු')) return const Text('🍈', style: TextStyle(fontSize: 44));
    if (name.contains('banana') || name.contains('කෙසෙල්')) return const Text('🍌', style: TextStyle(fontSize: 44));
    if (name.contains('pineapple') || name.contains('අන්නාසි')) return const Text('🍍', style: TextStyle(fontSize: 44));
    if (name.contains('avocado') || name.contains('අලිපේර')) return const Text('🥑', style: TextStyle(fontSize: 44));
    if (name.contains('watermelon') || name.contains('කොමඩු')) return const Text('🍉', style: TextStyle(fontSize: 44));
    if (name.contains('tomato') || name.contains('තක්කාලි')) return const Text('🍅', style: TextStyle(fontSize: 44));
    if (name.contains('chili') || name.contains('මිරිස්')) return const Text('🌶️', style: TextStyle(fontSize: 44));
    if (name.contains('brinjal') || name.contains('වම්බටු')) return const Text('🍆', style: TextStyle(fontSize: 44));
    if (name.contains('carrot') || name.contains('කැරට්')) return const Text('🥕', style: TextStyle(fontSize: 44));
    if (name.contains('potato') || name.contains('අල')) return const Text('🥔', style: TextStyle(fontSize: 44));
    if (name.contains('rose') || name.contains('රෝස')) return const Text('🌹', style: TextStyle(fontSize: 44));
    if (name.contains('orchid') || name.contains('ඕකිට්')) return const Text('🌸', style: TextStyle(fontSize: 44));
    if (name.contains('rice') || name.contains('vī') || name.contains('ගොයම්') || name.contains('වී')) return const Text('🌾', style: TextStyle(fontSize: 44));
    if (name.contains('coconut') || name.contains('පොල්')) return const Text('🥥', style: TextStyle(fontSize: 44));

    return const Icon(Icons.eco_rounded, color: AppColors.primary, size: 44);
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
                color: AppColors.background,
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
                      const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 28),
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
              Icon(icon, color: AppColors.primary, size: 22),
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