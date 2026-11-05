import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../theme/app_theme.dart';

class AddFieldScreen extends StatefulWidget {
  final Farm farm;
  const AddFieldScreen({Key? key, required this.farm}) : super(key: key);

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _cropCtrl = TextEditingController();
  DateTime? _sowingDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    _cropCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _sowingDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final field = Field(
        name: _nameCtrl.text.trim(),
        area: double.parse(_areaCtrl.text.trim()),
        crop: _cropCtrl.text.trim(),
        sowingDate: _sowingDate,
      );
      Navigator.of(context).pop(field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final homeIndicatorInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: AppStyles.backButtonBox,
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 26,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAND PARTITION',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Add Field Plot',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppStyles.cardBox,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Plot Name (e.g., North Field, Plot B)',
                        icon: Icons.border_all_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _areaCtrl,
                        label: 'Plot Area (Acres)',
                        icon: Icons.aspect_ratio_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter area in acres';
                          final n = double.tryParse(v);
                          if (n == null || n <= 0) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cropCtrl,
                        label: 'Allocated Crop (e.g., Ashwagandha, Wheat)',
                        icon: Icons.eco_rounded,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.creamBg.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDDD6C4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: AppColors.primaryGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _sowingDate == null
                                      ? 'Select sowing date (optional)'
                                      : 'Sowing date: ${_sowingDate!.day}/${_sowingDate!.month}/${_sowingDate!.year}',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _sowingDate == null
                                        ? AppColors.textMuted
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: AppStyles.primaryButtonBox,
                    child: const Center(
                      child: Text(
                        'Save Field Plot →',
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

                SizedBox(height: bottomInset > 0 ? bottomInset + 12 : homeIndicatorInset + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      style: const TextStyle(
        fontFamily: 'Mukta',
        fontSize: 15,
        fontWeight: FontWeight.w500,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}
