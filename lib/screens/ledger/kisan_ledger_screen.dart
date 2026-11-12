import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_strings.dart';
import '../../models/ledger_entry.dart';
import '../../services/agro_intel_service.dart';
import '../../services/gemini_service.dart';
import '../../services/mandi_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

/// Kisan Bahi-Khata: Offline-first agricultural income & expense ledger
/// Built specifically for Indian farmers to track cost-of-cultivation,
/// input costs (DAP, Seeds, Diesel, Labor), and mandi sale revenues.
class KisanLedgerScreen extends StatefulWidget {
  const KisanLedgerScreen({super.key});

  @override
  State<KisanLedgerScreen> createState() => _KisanLedgerScreenState();
}

class _KisanLedgerScreenState extends State<KisanLedgerScreen> {
  final StorageService _storage = StorageService();
  String _selectedCrop = 'All';
  bool get isHindi => AppLanguage().isHindi;

  GeminiLedgerInsight? _ledgerInsight;
  bool _isAnalyzingLedger = false;

  final List<String> _crops = ['All', 'Mustard', 'Wheat', 'Ashwagandha', 'General'];

  @override
  void initState() {
    super.initState();
    _storage.addListener(_onStorageChanged);
    _analyzeLedgerWithGemini();
  }

  Future<void> _analyzeLedgerWithGemini() async {
    if (_isAnalyzingLedger) return;
    if (mounted) setState(() => _isAnalyzingLedger = true);
    try {
      final snap = await AgroIntelService().buildFarmIntelSnapshot();
      final targetCrop = _selectedCrop == 'All'
          ? (snap.activeCrops.isNotEmpty ? snap.activeCrops.first : 'Mustard')
          : _selectedCrop;
      final mandiRate = MandiService().getBenchmarkPrice(targetCrop);
      final expense = _storage.getTotalExpense(cropName: _selectedCrop);
      final income = _storage.getTotalIncome(cropName: _selectedCrop);

      final insight = await GeminiService().analyzeLedgerInsights(
        promptContext: snap.promptContext,
        totalExpense: expense,
        totalIncome: income,
        topCategory: snap.topExpenseCategory,
        topCrop: targetCrop,
        mandiRate: mandiRate,
      );
      if (mounted) {
        setState(() {
          _ledgerInsight = insight;
          _isAnalyzingLedger = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAnalyzingLedger = false);
    }
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  List<LedgerEntry> get _filteredEntries {
    final all = _storage.getLedgerEntries();
    if (_selectedCrop == 'All') return all;
    return all.where((e) => e.cropName.toLowerCase() == _selectedCrop.toLowerCase()).toList();
  }

  void _showAddTransactionModal({bool defaultIncome = false}) {
    final isHindi = AppLanguage().isHindi;
    bool isIncome = defaultIncome;
    String selectedCategory = isIncome ? 'Sale' : 'Fertilizer';
    String selectedCrop = _selectedCrop == 'All' ? 'Mustard' : _selectedCrop;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final expenseCategories = [
      {'name': 'Fertilizer', 'hi': 'खाद / DAP / यूरिया', 'icon': Icons.science_outlined},
      {'name': 'Diesel/Tractor', 'hi': 'डीजल / ट्रैक्टर जोताई', 'icon': Icons.local_gas_station_outlined},
      {'name': 'Seed', 'hi': 'बीज खरीदारी', 'icon': Icons.spa_outlined},
      {'name': 'Labor', 'hi': 'मजदूरी / बुवाई', 'icon': Icons.people_outline_rounded},
      {'name': 'Irrigation', 'hi': 'सिंचाई / पंपिंग', 'icon': Icons.water_drop_outlined},
      {'name': 'Pesticide', 'hi': 'कीटनाशक / स्प्रे', 'icon': Icons.pest_control_outlined},
      {'name': 'Other', 'hi': 'अन्य खर्च', 'icon': Icons.more_horiz_rounded},
    ];

    final incomeCategories = [
      {'name': 'Sale', 'hi': 'मंडी / फसल बिक्री', 'icon': Icons.currency_rupee_rounded},
      {'name': 'Govt Subsidy', 'hi': 'पीएम-किसान / सब्सिडी', 'icon': Icons.account_balance_outlined},
      {'name': 'Other', 'hi': 'अन्य आय', 'icon': Icons.savings_outlined},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeCats = isIncome ? incomeCategories : expenseCategories;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDD6C4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Income / Expense Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.creamBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  isIncome = false;
                                  selectedCategory = 'Fertilizer';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isIncome ? const Color(0xFFB03A2E) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    isHindi ? '- खर्च' : '- Expense',
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: !isIncome ? Colors.white : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  isIncome = true;
                                  selectedCategory = 'Sale';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isIncome ? AppColors.primaryGreen : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    isHindi ? '+ आमदनी' : '+ Income',
                                    style: TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isIncome ? Colors.white : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Amount input
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        labelText: isHindi ? 'राशि (Amount in ₹)' : 'Amount (₹)',
                        labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 14, color: AppColors.textMuted),
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 22, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: AppColors.creamBg.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title / Description
                    TextFormField(
                      controller: titleCtrl,
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        labelText: isHindi ? 'विवरण (उदा. DAP 2 बोरी / 10 क्विंटल बिक्री)' : 'Description (e.g. 2 Bags DAP / 10 Qtl Sale)',
                        labelStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryGreen, size: 20),
                        filled: true,
                        fillColor: AppColors.creamBg.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Category Selector Chips
                    Text(
                      isHindi ? 'श्रेणी (Category):' : 'Category:',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeCats.map((cat) {
                        final isSel = selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedCategory = cat['name'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.mintTint : AppColors.creamBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primaryGreen : const Color(0xFFDDD6C4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat['icon'] as IconData, size: 16, color: isSel ? AppColors.primaryGreen : AppColors.textDark),
                                const SizedBox(width: 6),
                                Text(
                                  (isHindi ? cat['hi'] : cat['name']) as String,
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
                                    color: isSel ? AppColors.primaryGreen : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Crop Association
                    Text(
                      isHindi ? 'संबद्ध फ़सल (Crop):' : 'Associated Crop:',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Mustard', 'Wheat', 'Ashwagandha', 'General'].map((c) {
                        final isSel = selectedCrop == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c, style: TextStyle(fontFamily: 'Mukta', fontSize: 12, fontWeight: isSel ? FontWeight.w500 : FontWeight.w400)),
                            selected: isSel,
                            selectedColor: AppColors.mintTint,
                            onSelected: (val) => setModalState(() => selectedCrop = c),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Submit Button
                    GestureDetector(
                      onTap: () async {
                        final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isHindi ? 'कृपया मान्य राशि दर्ज करें' : 'Please enter a valid amount')),
                          );
                          return;
                        }

                        final entryTitle = titleCtrl.text.trim().isNotEmpty
                            ? titleCtrl.text.trim()
                            : (isIncome ? (isHindi ? 'फसल बिक्री आमदनी' : 'Crop Sale Income') : (isHindi ? '$selectedCategory खर्च' : '$selectedCategory Expense'));

                        final newEntry = LedgerEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: entryTitle,
                          cropName: selectedCrop,
                          category: selectedCategory,
                          amount: amt,
                          isIncome: isIncome,
                          date: DateTime.now(),
                          notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                        );

                        await _storage.addLedgerEntry(newEntry);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isIncome ? (isHindi ? '✓ आमदनी (+₹$amt) बही-खाते में दर्ज की गई!' : '✓ Income (+₹$amt) recorded in ledger!') : (isHindi ? '✓ खर्च (-₹$amt) बही-खाते में दर्ज किया गया!' : '✓ Expense (-₹$amt) recorded in ledger!'),
                              style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: AppStyles.primaryButtonBox,
                        child: Center(
                          child: Text(
                            isIncome ? (isHindi ? 'आमदनी सहेजें (+₹)' : 'Save Income (+₹)') : (isHindi ? 'खर्च सहेजें (-₹)' : 'Save Expense (-₹)'),
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
      },
    );
  }

  void _shareLedgerSummary() {
    final isHindi = AppLanguage().isHindi;
    final income = _storage.getTotalIncome(cropName: _selectedCrop);
    final expense = _storage.getTotalExpense(cropName: _selectedCrop);
    final profit = _storage.getNetProfit(cropName: _selectedCrop);
    final profile = _storage.getProfile();

    final summary = StringBuffer();
    summary.writeln('===================================');
    summary.writeln(isHindi ? '🌾 भूमि किसान बही-खाता' : '🌾 BHOOMI DIGITAL FARM LEDGER');
    summary.writeln('किसान: ${profile.name} (Kisan ID: ${profile.kisanId})');
    summary.writeln('ग्राम: ${profile.village}, ${profile.district}, ${profile.state}');
    summary.writeln('फ़सल फ़िल्टर: $_selectedCrop');
    summary.writeln('तारीख: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    summary.writeln('===================================');
    summary.writeln('कुल बिक्री / आमदनी: ₹${income.toStringAsFixed(0)}');
    summary.writeln('कुल कृषि खर्च:     ₹${expense.toStringAsFixed(0)}');
    summary.writeln('-----------------------------------');
    summary.writeln('शुद्ध बचत / मुनाफा:  ₹${profit.toStringAsFixed(0)}');
    summary.writeln('===================================');
    summary.writeln('प्रमुख प्रविष्टियां:');
    for (final e in _filteredEntries.take(5)) {
      final sign = e.isIncome ? '+' : '-';
      summary.writeln('• ${e.title} ($sign₹${e.amount.toStringAsFixed(0)}) [${e.cropName}]');
    }
    summary.writeln('===================================');
    summary.writeln('प्रमाणित प्रतिलिपि - KCC बैंक ऋण / सब्सिडी हेतु मान्य');

    Clipboard.setData(ClipboardData(text: summary.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi ? '✓ किसान बही-खाता पर्चा क्लिपबोर्ड में कॉपी हो गया! बैंक या व्हाट्सएप पर साझा करें।' : '✓ Farm ledger statement copied to clipboard! Share via WhatsApp or bank.',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    final totalIncome = _storage.getTotalIncome(cropName: _selectedCrop);
    final totalExpense = _storage.getTotalExpense(cropName: _selectedCrop);
    final netProfit = _storage.getNetProfit(cropName: _selectedCrop);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppStyles.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Back button + Screen Topic Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppStyles.backButtonBox,
                      child: const Center(
                        child: Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DIGITAL FARM LEDGER',
                        style: AppStyles.kicker,
                      ),
                      Text(
                        isHindi ? 'कृषि बही-खाता (P&L)' : 'Digital Farm Ledger (P&L)',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Financial Overview Hero Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: AppColors.tactileGreenShadow, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'शुद्ध बचत / मुनाफा' : 'NET PROFIT IN HAND',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                            color: AppColors.cardGold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _selectedCrop,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${netProfit >= 0 ? netProfit.toStringAsFixed(0) : '-₹${(-netProfit).toStringAsFixed(0)}'}',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.cardGold),
                                    const SizedBox(width: 4),
                                    Text(isHindi ? 'कुल आमदनी' : 'Total Revenue', style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${totalIncome.toStringAsFixed(0)}',
                                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFFF5B7B1)),
                                    const SizedBox(width: 4),
                                    Text(isHindi ? 'कुल खर्च' : 'Total Costs', style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${totalExpense.toStringAsFixed(0)}',
                                  style: const TextStyle(fontFamily: 'Mukta', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Quick Action Buttons: Add Expense, Add Income, Download Slip
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAddTransactionModal(defaultIncome: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF5B7B1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFB03A2E), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              isHindi ? '- खर्च दर्ज करें' : '- Record Expense',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB03A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAddTransactionModal(defaultIncome: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.mintTint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC3DFC0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              isHindi ? '+ आमदनी दर्ज करें' : '+ Record Income',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Download / Share Statement Button
              GestureDetector(
                onTap: _shareLedgerSummary,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share_outlined, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'KCC बैंक ऋण हेतु हिसाब पर्चा साझा करें' : 'Share Statement for Bank & KCC Loan',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3.5 AI Break-Even & Crop Rotation Insights Card
              _buildGeminiLedgerInsightCard(isHindi, totalExpense, totalIncome),

              const SizedBox(height: 16),

              // 4. Crop Filter Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _crops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final crop = _crops[idx];
                    final isSel = _selectedCrop == crop;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCrop = crop);
                        _analyzeLedgerWithGemini();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isSel ? AppColors.primaryGreen : AppColors.borderLight),
                        ),
                        child: Text(
                          crop == 'All' ? (isHindi ? 'सभी फ़सलें' : 'All Crops') : crop,
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 12.5,
                            fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
                            color: isSel ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 5. Transaction History List
              Text(
                isHindi ? 'हालिया लेनदेन व खर्च सूची' : 'Recent Farm Transactions',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              if (_filteredEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: AppStyles.cardBox,
                  child: Center(
                    child: Text(
                      isHindi ? 'इस फ़सल के लिए कोई प्रविष्टि नहीं है।' : 'No entries recorded for this crop yet.',
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 13.5, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final item = _filteredEntries[idx];
                    return _buildTransactionCard(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(LedgerEntry item) {
    IconData icon;
    Color iconBg;
    Color iconColor;

    if (item.isIncome) {
      icon = item.category == 'Govt Subsidy' ? Icons.account_balance_rounded : Icons.currency_rupee_rounded;
      iconBg = AppColors.mintTint;
      iconColor = AppColors.primaryGreen;
    } else {
      switch (item.category) {
        case 'Fertilizer':
          icon = Icons.science_outlined;
          iconBg = const Color(0xFFFCEFD0);
          iconColor = const Color(0xFF8A5600);
          break;
        case 'Diesel/Tractor':
          icon = Icons.local_gas_station_outlined;
          iconBg = const Color(0xFFE5E7EB);
          iconColor = const Color(0xFF374151);
          break;
        case 'Seed':
          icon = Icons.spa_outlined;
          iconBg = const Color(0xFFDDEFD9);
          iconColor = const Color(0xFF2E6930);
          break;
        case 'Labor':
          icon = Icons.people_outline_rounded;
          iconBg = const Color(0xFFF3D3C4);
          iconColor = const Color(0xFF8E3F20);
          break;
        case 'Irrigation':
          icon = Icons.water_drop_outlined;
          iconBg = const Color(0xFFDDEBF3);
          iconColor = const Color(0xFF18566F);
          break;
        default:
          icon = Icons.receipt_long_outlined;
          iconBg = const Color(0xFFF3EFE4);
          iconColor = AppColors.textMuted;
      }
    }

    final dateStr = '${item.date.day}/${item.date.month}/${item.date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppStyles.cardBox,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontFamily: 'Mukta', fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 6),
                    Text('·', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.creamBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.cropName,
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 10.5, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isIncome ? '+' : '-'}₹${item.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: item.isIncome ? AppColors.primaryGreen : const Color(0xFFB03A2E),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _storage.deleteLedgerEntry(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isHindi ? '✓ प्रविष्टि हटाई गई' : '✓ Entry removed'), duration: const Duration(seconds: 1)),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFB03A2E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiLedgerInsightCard(bool isHindi, double totalExpense, double totalIncome) {
    final targetCrop = _selectedCrop == 'All' ? 'Mustard' : _selectedCrop;
    final rate = MandiService().getBenchmarkPrice(targetCrop);
    final insight = _ledgerInsight ??
        GeminiLedgerInsight.computed(
          totalExpense: totalExpense,
          totalIncome: totalIncome,
          topCategory: 'Fertilizer',
          topCrop: targetCrop,
          mandiRate: rate,
        );

    final reqQty = rate > 0 ? (totalExpense / rate) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.cardBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.mintTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGreen, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHindi ? 'AI लागत व मुनाफा रडार' : 'AI Profit & Break-Even Radar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showLedgerInsightSheet(isHindi, insight, rate, targetCrop),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isHindi ? 'विस्तार' : 'AI Plan',
                        style: const TextStyle(fontFamily: 'Mukta', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _analyzeLedgerWithGemini,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _isAnalyzingLedger
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Icon(Icons.refresh_rounded, size: 17, color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Crisp 2-Metric KPI Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showLedgerInsightSheet(isHindi, insight, rate, targetCrop),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF7FD),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calculate_outlined, size: 14, color: Color(0xFF0369A1)),
                            const SizedBox(width: 4),
                            Text(
                              isHindi ? 'लागत वसूली लक्ष्य' : 'Break-Even Qty',
                              style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0369A1)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${reqQty.toStringAsFixed(1)} ${isHindi ? "क्विंटल" : "Qtl"}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.1),
                        ),
                        Text(
                          '@ ₹$rate/${isHindi ? "क्विं." : "Qtl"}',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _showLedgerInsightSheet(isHindi, insight, rate, targetCrop),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6ED),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.autorenew_rounded, size: 14, color: AppColors.primaryGreen),
                            const SizedBox(width: 4),
                            Text(
                              isHindi ? 'अगली बोनस फसल' : 'Next Rotation',
                              style: const TextStyle(fontFamily: 'Mukta', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isHindi ? 'मूंग / उड़द' : 'Moong / Urad',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.1),
                        ),
                        Text(
                          isHindi ? '~40% यूरिया बचत' : '~40% Urea Savings',
                          style: const TextStyle(fontFamily: 'Mukta', fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLedgerInsightSheet(
    bool isHindi,
    GeminiLedgerInsight insight,
    int rate,
    String targetCrop,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Text(
                isHindi ? 'AI बही-खाता व फसल चक्र योजना' : 'AI Farm Profit & Rotation Plan',
                style: const TextStyle(fontFamily: 'Mukta', fontSize: 18.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              _buildLedgerDetailBox(
                icon: Icons.calculate_outlined,
                title: isHindi ? 'लागत वसूली गणित ($targetCrop)' : 'Break-Even Target ($targetCrop)',
                body: insight.getBreakEven(isHindi),
                bg: const Color(0xFFEBF7FD),
                accent: const Color(0xFF0369A1),
              ),
              const SizedBox(height: 10),
              _buildLedgerDetailBox(
                icon: Icons.savings_outlined,
                title: isHindi ? 'खर्च कटौती सलाह' : 'Cost Reduction Tip',
                body: insight.getCostTip(isHindi),
                bg: const Color(0xFFFEF7E6),
                accent: const Color(0xFFB45309),
              ),
              const SizedBox(height: 10),
              _buildLedgerDetailBox(
                icon: Icons.autorenew_rounded,
                title: isHindi ? 'अगली फसल चक्र योजना' : 'Nitrogen Crop Rotation',
                body: insight.getRotation(isHindi),
                bg: const Color(0xFFEAF6ED),
                accent: AppColors.primaryGreen,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(isHindi ? 'ठीक है' : 'Got It', style: const TextStyle(fontFamily: 'Mukta', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerDetailBox({
    required IconData icon,
    required String title,
    required String body,
    required Color bg,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'Mukta', fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontFamily: 'Mukta', fontSize: 12.5, color: AppColors.textDark, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

