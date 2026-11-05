import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../theme/app_theme.dart';

class EditFarmScreen extends StatefulWidget {
  final Farm farm;
  const EditFarmScreen({Key? key, required this.farm}) : super(key: key);

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _farmerNameCtrl;
  late TextEditingController _villageCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _areaCtrl;

  @override
  void initState() {
    super.initState();
    _farmerNameCtrl = TextEditingController(text: widget.farm.farmerName);
    _villageCtrl = TextEditingController(text: widget.farm.village);
    _districtCtrl = TextEditingController(text: widget.farm.district);
    _stateCtrl = TextEditingController(text: widget.farm.state);
    _areaCtrl = TextEditingController(text: widget.farm.totalArea.toString());
  }

  @override
  void dispose() {
    _farmerNameCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.farm.farmerName = _farmerNameCtrl.text.trim();
      widget.farm.village = _villageCtrl.text.trim();
      widget.farm.district = _districtCtrl.text.trim();
      widget.farm.state = _stateCtrl.text.trim();
      widget.farm.totalArea = double.parse(_areaCtrl.text.trim());
      Navigator.of(context).pop(widget.farm);
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
                            'LAND SETTINGS',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Edit Farm Details',
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
                    children: [
                      _buildTextField(
                        controller: _farmerNameCtrl,
                        label: 'Farmer / Owner Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _areaCtrl,
                        label: 'Total Farm Area (Acres)',
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
                        controller: _villageCtrl,
                        label: 'Village / Town',
                        icon: Icons.holiday_village_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _districtCtrl,
                        label: 'District',
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _stateCtrl,
                        label: 'State',
                        icon: Icons.map_outlined,
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
                        'Save Farm Changes →',
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
