import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/crop.dart';
import '../../models/farm.dart';
import '../../services/storage_service.dart';

class SignupProfileScreen extends StatefulWidget {
  final String? phoneNumber;

  const SignupProfileScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

class _SignupProfileScreenState extends State<SignupProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _villageController;

  String _district = 'Palamu';
  String _state = 'Jharkhand';
  String _soilType = 'Loamy / Sandy Loam';
  double _landArea = 2.0;

  final Set<String> _selectedCrops = {'Ashwagandha', 'Tulsi'};

  final List<String> _states = const [
    'Jharkhand',
    'Bihar',
    'Uttar Pradesh',
    'Madhya Pradesh',
    'Punjab',
    'Haryana',
    'Rajasthan',
    'Maharashtra',
    'West Bengal',
    'Odisha',
  ];

  final List<String> _soilTypes = const [
    'Loamy / Sandy Loam',
    'Clay Loam',
    'Black Soil',
    'Red Soil',
    'Alluvial Soil',
  ];

  final List<String> _districts = const [
    'Palamu',
    'Ranchi',
    'Garhwa',
    'Hazaribagh',
    'Dhanbad',
    'Bokaro',
    'Deoghar',
    'East Singhbhum',
  ];

  final List<String> _primaryCropOptions = [
    'Ashwagandha',
    'Tulsi',
    'Wheat',
    'Mustard',
    'Gram',
  ];

  final List<String> _extendedCropOptions = [
    'Paddy / Dhan',
    'Maize / Makka',
    'Tomato',
    'Potato',
    'Ginger',
    'Soybean',
    'Onion',
    'Chilli',
  ];

  @override
  void initState() {
    super.initState();
    final prof = StorageService().getProfile();
    _nameController = TextEditingController(text: prof.name.isNotEmpty && prof.name != 'Kisan User' ? prof.name : '');
    _villageController = TextEditingController(text: prof.village.isNotEmpty && prof.village != 'Chanki' ? prof.village : '');
    if (prof.district.isNotEmpty && _districts.contains(prof.district)) {
      _district = prof.district;
    }
    if (prof.totalArea > 0) {
      _landArea = prof.totalArea;
    }
    if (prof.state.isNotEmpty && _states.contains(prof.state)) {
      _state = prof.state;
    }
    if (prof.soilType.isNotEmpty && _soilTypes.contains(prof.soilType)) {
      _soilType = prof.soilType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _onToggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        if (_selectedCrops.length > 1) {
          _selectedCrops.remove(crop);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select at least one crop',
                style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
              ),
              backgroundColor: Color(0xFF1E4D2B),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        _selectedCrops.add(crop);
      }
    });
  }

  void _onShowMoreCrops() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select More Crops',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2A21),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF1B2A21)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _extendedCropOptions.map((crop) {
                      final isSelected = _selectedCrops.contains(crop);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              _selectedCrops.remove(crop);
                            } else {
                              _selectedCrops.add(crop);
                              if (!_primaryCropOptions.contains(crop)) {
                                _primaryCropOptions.add(crop);
                              }
                            }
                          });
                          setState(() {});
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E4D2B) : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: isSelected
                                ? null
                                : Border.all(color: const Color(0xFFDDD6C4), width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isSelected ? '✓ $crop' : crop,
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF1B2A21),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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

  void _onSelectState() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select State',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 12),
              ..._states.map((s) {
                final isSelected = s == _state;
                return ListTile(
                  title: Text(
                    s,
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFF1B2A21),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1E4D2B))
                      : null,
                  onTap: () {
                    setState(() {
                      _state = s;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _onSelectSoilType() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Soil Type',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 12),
              ..._soilTypes.map((st) {
                final isSelected = st == _soilType;
                return ListTile(
                  title: Text(
                    st,
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFF1B2A21),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1E4D2B))
                      : null,
                  onTap: () {
                    setState(() {
                      _soilType = st;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _onSelectDistrict() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select District',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A21),
                ),
              ),
              const SizedBox(height: 12),
              ..._districts.map((d) {
                final isSelected = d == _district;
                return ListTile(
                  title: Text(
                    d,
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFF1B2A21),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1E4D2B))
                      : null,
                  onTap: () {
                    setState(() {
                      _district = d;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onStartFarming() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your name',
            style: TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF1E4D2B),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final village = _villageController.text.trim().isEmpty ? 'Village' : _villageController.text.trim();
    final phone = widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty
        ? '+91 ${widget.phoneNumber}'
        : StorageService().getProfile().phone;

    final stCode = _state.length >= 2 ? _state.substring(0, 2).toUpperCase() : 'JH';
    final dtCode = _district.length >= 3 ? _district.substring(0, 3).toUpperCase() : 'PLM';
    final randCode = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
    final kisanId = 'KCC-$stCode-$dtCode-$randCode';

    // 1. Update Farmer Profile
    final updatedProfile = StorageService().getProfile().copyWith(
      name: name,
      phone: phone,
      village: village,
      district: _district,
      state: _state,
      soilType: _soilType,
      totalArea: _landArea,
      kisanId: kisanId,
      aadhaarLinked: true,
      weatherAlerts: true,
      pestAlerts: true,
      mandiAlerts: true,
      irrigationAlerts: true,
    );
    await StorageService().updateProfile(updatedProfile);

    // 2. Setup Fields & Crops based on user selection
    final cropList = _selectedCrops.toList();
    final areaPerCrop = (_landArea / cropList.length).clamp(0.5, 50.0);

    final fields = <Field>[];
    final crops = <Crop>[];

    for (int i = 0; i < cropList.length; i++) {
      final cName = cropList[i];
      final plotLabel = i == 0 ? 'North Plot' : (i == 1 ? 'South Plot' : 'East Plot #${i + 1}');
      fields.add(Field(
        name: plotLabel,
        area: areaPerCrop,
        crop: cName,
        sowingDate: DateTime.now().subtract(const Duration(days: 30)),
      ));
      crops.add(Crop(
        name: cName,
        variety: cName == 'Ashwagandha'
            ? 'Nagori / JA-20'
            : (cName == 'Tulsi'
                ? 'Krishna Tulsi'
                : (cName == 'Mustard'
                    ? 'Varuna (T-59)'
                    : (cName == 'Wheat' ? 'Sharbati HD-2967' : 'Certified Hybrid'))),
        growthStage: 'Active vegetative',
        sowingDate: DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 90)),
        notes: 'Cultivated under organic practices with precision drip irrigation.',
      ));
    }

    final farm = Farm(
      farmerName: name,
      village: village,
      district: _district,
      state: _state,
      totalArea: _landArea,
      fields: fields,
      crops: crops,
    );
    await StorageService().updatePrimaryFarm(farm);

    // 3. Trigger cloud sync to Turso Edge database in background
    await StorageService().syncAllToTurso();

    // 4. Navigate to MainNavigation
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final landText = _landArea == _landArea.roundToDouble()
        ? _landArea.toInt().toString()
        : _landArea.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 390,
              height: 844,
              child: Container(
                color: const Color(0xFFF6F2E9),
                child: Column(
                  children: [
                    // Top Bar: Back Button + STEP 2 OF 2 Progress Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          // Circular Back Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF1B2A21),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Step 2 of 2 Progress Bar
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'STEP 2 OF 2',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF3A6B4A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2DCCB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: double.infinity,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E4D2B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content Section
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Headline & Subtitle
                            const Text(
                              'Tell us about you',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: Color(0xFF1B2A21),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'This helps us give advice for your farm.',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF55655A),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 2. Your Name Field
                            const Text(
                              'Your name',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3F5547),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF1E4D2B), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _nameController,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B2A21),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 16,
                                    color: Color(0xFF9EAFA4),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 3. Village & District Row (Side by Side)
                            Row(
                              children: [
                                // Village
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Village',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF3F5547),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: TextField(
                                          controller: _villageController,
                                          style: const TextStyle(
                                            fontFamily: 'Mukta',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1B2A21),
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter village',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Mukta',
                                              fontSize: 16,
                                              color: Color(0xFF9EAFA4),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // District
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'District',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF3F5547),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: _onSelectDistrict,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _district,
                                                style: const TextStyle(
                                                  fontFamily: 'Mukta',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1B2A21),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: Color(0xFF1B2A21),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // State & Soil Type
                            Row(
                              children: [
                                // State
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'State',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF3F5547),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: _onSelectState,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _state,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Mukta',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1B2A21),
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: Color(0xFF1B2A21),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Soil Type
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Soil Type',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF3F5547),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: _onSelectSoilType,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: const Color(0xFFDDD6C4), width: 1.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _soilType,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Mukta',
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1B2A21),
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: Color(0xFF1B2A21),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 4. Land you farm Counter
                            const Text(
                              'Land you farm',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3F5547),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFE6E0D2), width: 1),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFE9E2D1),
                                    offset: Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Minus Button
                                  GestureDetector(
                                    onTap: () {
                                      if (_landArea > 0.5) {
                                        setState(() {
                                          _landArea = (_landArea - 1.0).clamp(0.5, 100.0);
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2EFDF),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.remove_rounded,
                                        color: Color(0xFF1E4D2B),
                                        size: 24,
                                      ),
                                    ),
                                  ),

                                  // Value: "2 acres"
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1B2A21),
                                      ),
                                      children: [
                                        TextSpan(text: '$landText '),
                                        const TextSpan(
                                          text: 'acres',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF55655A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Plus Button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _landArea = (_landArea + 1.0).clamp(0.5, 100.0);
                                      });
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2EFDF),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: Color(0xFF1E4D2B),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 5. What do you grow? Chips
                            const Text(
                              'What do you grow?',
                              style: TextStyle(
                                fontFamily: 'Mukta',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3F5547),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._primaryCropOptions.map((crop) {
                                  final isSelected = _selectedCrops.contains(crop);
                                  return GestureDetector(
                                    onTap: () => _onToggleCrop(crop),
                                    child: Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF1E4D2B) : Colors.white,
                                        borderRadius: BorderRadius.circular(22),
                                        border: isSelected
                                            ? null
                                            : Border.all(color: const Color(0xFFDDD6C4), width: 1),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isSelected ? '✓ $crop' : crop,
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.white : const Color(0xFF1B2A21),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                // "+ More" button chip
                                GestureDetector(
                                  onTap: _onShowMoreCrops,
                                  child: Container(
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '+ More',
                                      style: TextStyle(
                                        fontFamily: 'Mukta',
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1B2A21),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // 6. Start Farming Button
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: GestureDetector(
                                onTap: _onStartFarming,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E4D2B),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF123320),
                                        offset: Offset(0, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Start farming',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}

