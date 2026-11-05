import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../models/farmer_profile.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'diary/farm_diary_screen.dart';
import 'my_farm_screen.dart';
import 'voice/voice_assistant_modal.dart';
import 'ledger/kisan_ledger_screen.dart';
import 'chopal/kisan_chopal_screen.dart';
import 'claim/crop_loss_claim_screen.dart';
import 'tools/fertilizer_calculator_screen.dart';
import 'tools/kisan_yojana_screen.dart';
import 'equipment/equipment_rental_screen.dart';
import 'land/land_marketplace_screen.dart';
import '../widgets/safe_local_image.dart';
import '../widgets/turso_database_modal.dart';
import '../services/turso/turso_service.dart';
import 'auth/language_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const ProfileScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  late FarmerProfile _profile;
  bool get isHindi => AppLanguage().isHindi;

  @override
  void initState() {
    super.initState();
    _profile = _storage.getProfile();
    _storage.addListener(_onStorageChanged);
    TursoService().addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    TursoService().removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) {
      setState(() => _profile = _storage.getProfile());
    }
  }

  // 1. Language Modal
  void _chooseLanguage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    ).then((_) {
      if (mounted) setState(() => _profile = _storage.getProfile());
    });
  }

  Widget _buildLanguageOption({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2EFDF).withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE6E0D2),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 12,
                      fontWeight: FontWeight.w400, color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 24)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 2. Comprehensive Edit Profile Modal
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile.name);
    final phoneCtrl = TextEditingController(text: _profile.phone);
    final villageCtrl = TextEditingController(text: _profile.village);
    final districtCtrl = TextEditingController(text: _profile.district);
    final stateCtrl = TextEditingController(text: _profile.state);
    final areaCtrl = TextEditingController(text: _profile.totalArea.toString());
    final soilCtrl = TextEditingController(text: _profile.soilType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'प्रोफ़ाइल संपादन' : 'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFE4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Update your farmer name, location, and farm landholding details.',
                  style: TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13,
                    color: AppColors.textMuted, fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  controller: nameCtrl,
                  label: isHindi ? 'किसान का नाम' : 'Farmer Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: phoneCtrl,
                  label: isHindi ? 'फ़ोन नंबर' : 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: villageCtrl,
                        label: isHindi ? 'गाँव' : 'Village',
                        icon: Icons.holiday_village_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField(
                        controller: districtCtrl,
                        label: isHindi ? 'जिला' : 'District',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: stateCtrl,
                        label: isHindi ? 'राज्य' : 'State',
                        icon: Icons.map_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField(
                        controller: areaCtrl,
                        label: 'Total Land (Acres)',
                        icon: Icons.aspect_ratio_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: soilCtrl,
                  label: isHindi ? 'मिट्टी का प्रकार' : 'Soil Type',
                  icon: Icons.layers_outlined,
                ),
                const SizedBox(height: 20),

                // Save button
                GestureDetector(
                  onTap: () async {
                    final newArea = double.tryParse(areaCtrl.text.trim()) ?? _profile.totalArea;
                    final updated = _profile.copyWith(
                      name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _profile.name,
                      phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : _profile.phone,
                      village: villageCtrl.text.trim().isNotEmpty ? villageCtrl.text.trim() : _profile.village,
                      district: districtCtrl.text.trim().isNotEmpty ? districtCtrl.text.trim() : _profile.district,
                      state: stateCtrl.text.trim().isNotEmpty ? stateCtrl.text.trim() : _profile.state,
                      soilType: soilCtrl.text.trim().isNotEmpty ? soilCtrl.text.trim() : _profile.soilType,
                      totalArea: newArea,
                    );
                    await _storage.saveProfile(updated);
                    if (mounted) {
                      setState(() => _profile = updated);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isHindi ? '✓ प्रोफ़ाइल सहेजा गया' : '✓ Profile updated!',
                            style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: AppColors.primaryGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: AppStyles.primaryButtonBox,
                    child: const Center(
                      child: Text(
                        'Save Profile Changes →',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16,
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
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Mukta',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Mukta',
          fontSize: 13,
          fontWeight: FontWeight.w400, color: AppColors.textMuted,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.creamBg.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }

  // 3. Dedicated Personal Details & KYC Sheet
  void _showPersonalDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'किसान पहचान' : 'Personal Details',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mintTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'KYC Verified',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kisan ID Card Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.tactileGreenShadow,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'KISAN DIGITAL IDENTITY',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cardGold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            _profile.kisanId,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile.name,
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${_profile.village}, ${_profile.district}, ${_profile.state}',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardGold, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: const SafeLocalImage(
                                imagePath: 'assets/images/farmer_hero.jpg',
                                fit: BoxFit.cover,
                                alignment: Alignment(0.2, -0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Details List
                _buildDetailRow('Full Name', _profile.name.isNotEmpty ? _profile.name : 'Not set', Icons.person_outline_rounded),
                _buildDetailRow('Mobile Number', _profile.phone.isNotEmpty ? _profile.phone : 'Not set', Icons.phone_outlined, badge: _profile.phone.isNotEmpty ? 'Active · OTP Verified' : null),
                _buildDetailRow('Kisan ID (KCC)', _profile.kisanId.isNotEmpty ? _profile.kisanId : 'Not assigned', Icons.badge_outlined),
                _buildDetailRow('Village', _profile.village.isNotEmpty ? _profile.village : 'Not set', Icons.holiday_village_outlined),
                _buildDetailRow('District & State', [_profile.district, _profile.state].where((s) => s.isNotEmpty).join(', ').isNotEmpty ? [_profile.district, _profile.state].where((s) => s.isNotEmpty).join(', ') : 'Not set', Icons.location_on_outlined),
                _buildDetailRow('Landholding', _profile.totalArea > 0 ? '${_profile.totalArea} Acres' : 'Not registered', Icons.aspect_ratio_rounded),
                _buildDetailRow('Soil Type', _profile.soilType.isNotEmpty ? _profile.soilType : 'Loamy / Sandy Loam', Icons.layers_outlined),
                _buildDetailRow('Aadhaar DBT', 'Linked & Verified', Icons.account_balance_outlined, badge: 'Active ✓'),
                _buildDetailRow('PM-KISAN Scheme', 'Active (18th Installment)', Icons.volunteer_activism_outlined),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _showEditProfileDialog();
                        },
                        child: Container(
                          height: 48,
                          decoration: AppStyles.primaryButtonBox,
                          child: Center(
                            child: Text(
                              isHindi ? 'सुधारें' : 'Edit Details',
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
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text: 'Bhoomi Kisan Card: ${_profile.name}, ID: ${_profile.kisanId}, Village: ${_profile.village}, ${_profile.district}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✓ Kisan Card copied to clipboard!',
                              style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: AppColors.primaryGreen,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFE4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFDDD6C4)),
                        ),
                        child: const Center(
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 18, color: AppColors.textDark),
                              SizedBox(width: 6),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDark,
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {String? badge}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12,
                    fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4. Help & Support Modal
  void _showHelpSupport() {
    final isHindi = AppLanguage().isHindi;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
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
                Text(
                  isHindi ? 'किसान सहायता केंद्र' : 'Kisan Helpline & Support',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Direct government helplines, agricultural scientists & crop advisory.',
                  style: TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13.5,
                    color: AppColors.textMuted, fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),

                // Helpline cards
                _buildSupportTile(
                  title: 'Kisan Call Center (Toll Free)',
                  phone: '1800-180-1551',
                  timing: 'Available 6:00 AM – 10:00 PM (Every day)',
                  icon: Icons.phone_in_talk_rounded,
                  iconBg: AppColors.mintTint,
                  iconColor: AppColors.primaryGreen,
                  onCall: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Calling Kisan Call Center: 1800-180-1551...',
                          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildSupportTile(
                  title: 'Krishi Vigyan Kendra (KVK Palamu)',
                  phone: '06562-224190',
                  timing: 'Scientist desk: Soil & Disease Consultation',
                  icon: Icons.science_outlined,
                  iconBg: const Color(0xFFFCEFD0),
                  iconColor: const Color(0xFF8A5600),
                  onCall: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Connecting to KVK Palamu Scientist Desk: 06562-224190...',
                          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildSupportTile(
                  title: 'Kisan Call Center / Expert Helpline',
                  phone: '1800-180-1551',
                  timing: 'Send photo of affected crop for quick advice',
                  icon: Icons.chat_rounded,
                  iconBg: const Color(0xFFDDEBF3),
                  iconColor: const Color(0xFF18566F),
                  onCall: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Opening WhatsApp Crop Doctor chat...',
                          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // AI Voice Assistant Shortcut
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    VoiceAssistantModal.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2B134).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardGold, width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.mic_rounded, color: Color(0xFF8A5600), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Speak to AI Krishi Mitra',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8A5600),
                                ),
                              ),
                              Text(
                                'Ask questions by voice in Hindi or English',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8A5600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Color(0xFF8A5600)),
                      ],
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

  Widget _buildSupportTile({
    required String title,
    required String phone,
    required String timing,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onCall,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E0D2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  timing,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Call',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Dynamic Notification Preferences Modal
  void _showNotificationPreferences() {
    final isHindi = AppLanguage().isHindi;
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
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
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
                  Text(
                    isHindi ? 'सूचना प्राथमिकताएं' : 'Notification Preferences',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Customize timely SMS and audio alerts for your field.',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 13,
                      color: AppColors.textMuted, fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchRow(
                    title: 'Weather & Rain Alerts',
                    subtitle: 'Rain chances, storm forecasts, and frost alerts',
                    value: _profile.weatherAlerts,
                    onChanged: (val) async {
                      final updated = _profile.copyWith(weatherAlerts: val);
                      await _storage.saveProfile(updated);
                      setModalState(() => _profile = updated);
                      setState(() => _profile = updated);
                    },
                  ),

                  _buildSwitchRow(
                    title: 'Mandi Price Surge Alerts',
                    subtitle: 'Daily morning prices for Ashwagandha, Mustard, Wheat',
                    value: _profile.mandiAlerts,
                    onChanged: (val) async {
                      final updated = _profile.copyWith(mandiAlerts: val);
                      await _storage.saveProfile(updated);
                      setModalState(() => _profile = updated);
                      setState(() => _profile = updated);
                    },
                  ),

                  _buildSwitchRow(
                    title: 'Pest & Blight Early Warnings',
                    subtitle: 'Alerts when yellow leaf spot or stem rot reported nearby',
                    value: _profile.pestAlerts,
                    onChanged: (val) async {
                      final updated = _profile.copyWith(pestAlerts: val);
                      await _storage.saveProfile(updated);
                      setModalState(() => _profile = updated);
                      setState(() => _profile = updated);
                    },
                  ),

                  _buildSwitchRow(
                    title: 'Irrigation & Sowing Reminders',
                    subtitle: 'Watering reminders based on actual soil evaporation',
                    value: _profile.irrigationAlerts,
                    onChanged: (val) async {
                      final updated = _profile.copyWith(irrigationAlerts: val);
                      await _storage.saveProfile(updated);
                      setModalState(() => _profile = updated);
                      setState(() => _profile = updated);
                    },
                  ),

                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✓ Notification preferences saved!',
                            style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: AppColors.primaryGreen,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: AppStyles.primaryButtonBox,
                      child: Center(
                        child: Text(
                          isHindi ? 'हो गया' : 'Done',
                          style: const TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12,
                    fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.mintTint,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // 6. Dynamic Privacy & Data Controls Modal
  void _showPrivacyInfo() {
    final isHindi = AppLanguage().isHindi;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
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
                Text(
                  isHindi ? 'डेटा सुरक्षा व गोपनीयता' : 'Privacy & Data Protection',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bhoomi operates on an Offline-First, Farmer-First security model. Your farm layout, diary notes, and crop photos are stored directly on your device. We do not sell or monetize farmer agricultural records.',
                  style: TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // Action 1: Export My Data
                GestureDetector(
                  onTap: () {
                    final jsonSummary = _storage.exportDataAsJson();
                    Clipboard.setData(ClipboardData(text: jsonSummary));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✓ Farm database exported to clipboard as JSON!',
                          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFE4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD6C4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.download_rounded, color: AppColors.primaryGreen, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Farm Data (JSON)',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Copy backup of your crops, diary and profile',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Action 2: Reset Demo Data
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (alertCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text(
                          'Reset All Demo Data?',
                          style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
                        ),
                        content: const Text(
                          'This will restore default crops, sample diary entries, and reset profile to factory state.',
                          style: TextStyle(fontFamily: 'Mukta'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertCtx),
                            child: const Text('Cancel', style: TextStyle(fontFamily: 'Mukta', color: AppColors.textMuted)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB03A2E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await _storage.resetAllData();
                              if (mounted) {
                                setState(() => _profile = _storage.getProfile());
                                Navigator.pop(alertCtx);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✓ Database reset to default state!',
                                      style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                                    ),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              }
                            },
                            child: const Text('Reset', style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF5B7B1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.restart_alt_rounded, color: Color(0xFFB03A2E), size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset App Data',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFB03A2E),
                                ),
                              ),
                              Text(
                                'Revert all fields, crops and logs to initial state',
                                style: TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 12,
                                  color: Color(0xFFB03A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // 7. Additional Option: Feedback Dialog
  void _showFeedbackDialog() {
    final isHindi = AppLanguage().isHindi;
    final feedbackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          isHindi ? 'सुझाव साझा करें' : 'Send Feedback',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can Bhoomi serve your farming needs better?',
              style: TextStyle(fontFamily: 'Mukta', fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your suggestion or crop question here...',
                hintStyle: const TextStyle(fontFamily: 'Mukta', fontSize: 13),
                filled: true,
                fillColor: AppColors.creamBg.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDDD6C4)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Mukta', color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Thank you for your feedback, Kisan Ji!',
                    style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: const Text('Submit →', style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage();
    final isHindi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.creamBg, // #F6F2E9
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: "YOUR SPACE" / "Profile"
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'आपका खाता' : 'YOUR SPACE',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFF3A6B4A),
                      ),
                    ),
                    Text(
                      isHindi ? 'प्रोफ़ाइल' : 'Profile',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Farmer Profile Card (.c, padding: 14px)
              GestureDetector(
                onTap: _showPersonalDetailsModal,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Farmer Avatar Photo with fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SafeLocalImage(
                              imagePath: 'assets/images/farmer_hero.jpg',
                              fit: BoxFit.cover,
                              alignment: const Alignment(0.2, -0.3),
                              fallback: CustomPaint(
                                painter: _ProfileAvatarPainter(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile.name.isNotEmpty
                                  ? _profile.name
                                  : (isHindi ? 'किसान साथी' : 'Kisan Member'),
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isHindi
                                  ? 'किसान · ${_profile.village}, ${_profile.district}'
                                  : 'Farmer · ${_profile.village}, ${_profile.district}',
                              style: const TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 14,
                                fontWeight: FontWeight.w400, color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_profile.totalArea} Acres · ${_profile.soilType}',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Profile Button (44x44, circular, #F3EFE4, pencil icon)
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EFE4),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Card Group 1 (.c, padding: 2px 14px)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Personal details
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBg: AppColors.mintTint, // #E2EFDF
                      iconColor: AppColors.primaryGreen, // #1E4D2B
                      title: isHindi ? 'व्यक्तिगत विवरण' : 'Personal details',
                      onTap: _showPersonalDetailsModal,
                      showDivider: true,
                    ),
                    // My Farm
                    _buildMenuItem(
                      icon: Icons.grass_rounded,
                      iconBg: AppColors.mintTint, // #E2EFDF
                      iconColor: AppColors.primaryGreen, // #1E4D2B
                      title: isHindi ? 'मेरा खेत' : 'My Farm',
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyFarmScreen()),
                          );
                        }
                      },
                      showDivider: true,
                    ),
                    // Farm Diary
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      iconBg: const Color(0xFFF3D3C4),
                      iconColor: const Color(0xFF8E3F20),
                      title: isHindi ? 'कृषि डायरी' : 'Farm Diary',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FarmDiaryScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Kisan Bahi-Khata
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBg: const Color(0xFFE2EFDF),
                      iconColor: const Color(0xFF1E4D2B),
                      title: isHindi ? 'कृषि बही-खाता (Farm Ledger)' : 'Kisan Ledger (P&L)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KisanLedgerScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Kisan Chopal
                    _buildMenuItem(
                      icon: Icons.groups_outlined,
                      iconBg: const Color(0xFFDDEBF3),
                      iconColor: const Color(0xFF18566F),
                      title: isHindi ? 'किसान चौपाल व यंत्र (Chopal)' : 'Village Hub & Machinery',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KisanChopalScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // PMFBY Crop Loss Claim
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      iconBg: const Color(0xFFFDE8E8),
                      iconColor: const Color(0xFFB03A2E),
                      title: isHindi ? 'फसल क्षति व बीमा दावा (PMFBY)' : 'Crop Loss Claim (PMFBY)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CropLossClaimScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Equipment Rental Hub
                    _buildMenuItem(
                      icon: Icons.agriculture_rounded,
                      iconBg: const Color(0xFFE2EFDF),
                      iconColor: const Color(0xFF1E4D2B),
                      title: isHindi ? 'कृषि यंत्र किराया (ट्रैक्टर, हार्वेस्टर व ड्रोन)' : 'Farm Equipment Rental Hub',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EquipmentRentalScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Farmland Marketplace
                    _buildMenuItem(
                      icon: Icons.terrain_rounded,
                      iconBg: const Color(0xFFFCEFD0),
                      iconColor: const Color(0xFF8A5600),
                      title: isHindi ? 'किसान भूमि बाज़ार (जमीन खरीदें व बेचें)' : 'Kisan Land Marketplace (Buy & Sell)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LandMarketplaceScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Sarkari Yojana Navigator
                    _buildMenuItem(
                      icon: Icons.account_balance_outlined,
                      iconBg: const Color(0xFFFFF7E6),
                      iconColor: const Color(0xFFC98F1C),
                      title: isHindi ? 'किसान सरकारी योजनाएं व सब्सिडी' : 'Kisan Schemes & Subsidies',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KisanYojanaScreen()),
                        );
                      },
                      showDivider: true,
                    ),
                    // Turso Cloud Database (Edge SQLite)
                    _buildMenuItem(
                      icon: Icons.dns_rounded,
                      iconBg: const Color(0xFFE2EFDF),
                      iconColor: const Color(0xFF1E4D2B),
                      title: isHindi ? 'टर्सो क्लाउड डेटाबेस (24/7 Edge SQLite)' : 'Turso Cloud Database (24/7 Edge SQLite)',
                      trailingPillText: TursoService().isConnected ? '🟢 Online' : '⚙️ Manage',
                      onTap: () => TursoDatabaseModal.show(context),
                      showDivider: true,
                    ),
                    // Language
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFDDEBF3),
                      iconColor: const Color(0xFF18566F),
                      title: isHindi ? 'भाषा' : 'Language',
                      trailingPillText: isHindi ? 'हिन्दी' : 'English',
                      onTap: _chooseLanguage,
                      showDivider: true,
                    ),
                    // Help & support
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBg: AppColors.accentGoldLight, // #FCEFD0
                      iconColor: const Color(0xFF7A4D00),
                      title: isHindi ? 'सहायता और संपर्क' : 'Help & support',
                      onTap: _showHelpSupport,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Card Group 2 (.c, padding: 2px 14px)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Notification Preferences
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      iconBg: AppColors.accentGoldLight, // #FCEFD0
                      iconColor: const Color(0xFF7A4D00),
                      title: isHindi ? 'अधिसूचना प्राथमिकताएँ' : 'Notification Preferences',
                      onTap: _showNotificationPreferences,
                      showDivider: true,
                    ),
                    // Privacy & Data Protection
                    _buildMenuItem(
                      icon: Icons.verified_user_outlined,
                      iconBg: AppColors.mintTint, // #E2EFDF
                      iconColor: AppColors.primaryGreen, // #1E4D2B
                      title: isHindi ? 'गोपनीयता और डेटा सुरक्षा' : 'Privacy & Data Protection',
                      onTap: _showPrivacyInfo,
                      showDivider: true,
                    ),
                    // Additional Option: Feedback & Suggestions
                    _buildMenuItem(
                      icon: Icons.rate_review_outlined,
                      iconBg: const Color(0xFFF3EFE4),
                      iconColor: AppColors.textDark,
                      title: isHindi ? 'सुझाव व प्रतिक्रिया' : 'Send Feedback',
                      onTap: _showFeedbackDialog,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 5. App Version Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      isHindi ? 'भूमि (Bhoomi) v1.0.0' : 'Bhoomi v1.0.0',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHindi ? 'भूमि से मंडी तक' : 'Bhoomi Se Mandi Tak',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400, color: Color(0xFF7A877E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    String? trailingPillText,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFEEE8DA), width: 1))
              : null,
        ),
        child: Row(
          children: [
            // Icon Squircle (.k, 40x40, rx 13)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (trailingPillText != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  trailingPillText,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF7A877E),
            ),
          ],
        ),
      ),
    );
  }
}

/// Farmer Avatar with White Turban and Green Kurta
class _ProfileAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 72.0;
    canvas.scale(scale, scale);

    // 1. Yellow circle base
    final circleFill = Paint()
      ..color = const Color(0xFFFCEFD0)
      ..style = PaintingStyle.fill;
    final circleStroke = Paint()
      ..color = const Color(0xFFF2B134)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(36, 36), 35, circleFill);
    canvas.drawCircle(const Offset(36, 36), 35, circleStroke);

    // Clip to circle boundary for body
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: const Offset(36, 36), radius: 34.5));
    canvas.clipPath(clipPath);

    // 2. Green Kurta: M12 62c2-12 12-16 24-16s22 4 24 16a35 35 0 0 1-48 0z
    final bodyPaint = Paint()
      ..color = const Color(0xFF3A8350)
      ..style = PaintingStyle.fill;
    final bodyPath = Path()
      ..moveTo(12, 62)
      ..cubicTo(14, 50, 24, 46, 36, 46)
      ..cubicTo(48, 46, 58, 50, 60, 62)
      ..arcToPoint(const Offset(12, 62), radius: const Radius.circular(35))
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // 3. Face: cx 36, cy 33, r 13
    final facePaint = Paint()
      ..color = const Color(0xFFE3A77C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(36, 33), 13, facePaint);

    // 4. White Turban: M20 28 c0-12 7-17 16-17 s16 5 16 17 c-6-5-26-5-32 0 z
    final turbanFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final turbanStroke = Paint()
      ..color = const Color(0xFFC9C2AE)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final turbanPath = Path()
      ..moveTo(20, 28)
      ..cubicTo(20, 16, 27, 11, 36, 11)
      ..cubicTo(45, 11, 52, 16, 52, 28)
      ..cubicTo(46, 23, 26, 23, 20, 28)
      ..close();
    canvas.drawPath(turbanPath, turbanFill);
    canvas.drawPath(turbanPath, turbanStroke);

    // 5. Mustache / Smile: M29 40 c4 3 10 3 14 0
    final smilePaint = Paint()
      ..color = const Color(0xFF6B3E22)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final smilePath = Path()
      ..moveTo(29, 40)
      ..cubicTo(33, 43, 39, 43, 43, 40);
    canvas.drawPath(smilePath, smilePaint);

    // 6. Eyes: cx 31 cy 33 r 1.6; cx 41 cy 33 r 1.6
    final eyePaint = Paint()
      ..color = const Color(0xFF3A2515)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(31, 33), 1.6, eyePaint);
    canvas.drawCircle(const Offset(41, 33), 1.6, eyePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
