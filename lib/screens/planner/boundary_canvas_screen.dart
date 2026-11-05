import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/farm.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';

class BoundaryCanvasScreen extends StatefulWidget {
  final double initialArea;
  const BoundaryCanvasScreen({Key? key, this.initialArea = 2.0}) : super(key: key);

  @override
  State<BoundaryCanvasScreen> createState() => _BoundaryCanvasScreenState();
}

class _BoundaryCanvasScreenState extends State<BoundaryCanvasScreen> {
  final StorageService _storage = StorageService();
  final List<Offset> _points = [];
  bool _isClosed = true;
  bool _isSatelliteMode = true; // Satellite vs Cadastral Blueprint
  bool _showZoning = true; // Show sub-plot crop allocation overlay
  String? _selectedInfraType; // 'pump', 'gate', 'shed', 'pond'
  final List<Map<String, dynamic>> _infraMarkers = [];

  // Default corner positions
  @override
  void initState() {
    super.initState();
    _applyRectangularPreset();
    // Default infra markers
    _infraMarkers.addAll([
      {'type': 'pump', 'label': 'Solar Borewell', 'pos': const Offset(80, 80)},
      {'type': 'gate', 'label': 'Tractor Road Gate', 'pos': const Offset(55, 235)},
    ]);
  }

  void _applyRectangularPreset() {
    setState(() {
      _points.clear();
      _points.addAll([
        const Offset(55, 55),
        const Offset(295, 55),
        const Offset(295, 245),
        const Offset(55, 245),
      ]);
      _isClosed = true;
    });
  }

  void _applyContourPreset() {
    setState(() {
      _points.clear();
      _points.addAll([
        const Offset(85, 45),
        const Offset(275, 60),
        const Offset(310, 240),
        const Offset(45, 255),
      ]);
      _isClosed = true;
    });
  }

  void _applySplitPreset() {
    setState(() {
      _points.clear();
      _points.addAll([
        const Offset(50, 50),
        const Offset(300, 50),
        const Offset(300, 250),
        const Offset(175, 250),
        const Offset(175, 50),
        const Offset(50, 250),
      ]);
      _isClosed = true;
    });
  }

  void _applyLShapePreset() {
    setState(() {
      _points.clear();
      _points.addAll([
        const Offset(55, 50),
        const Offset(185, 50),
        const Offset(185, 140),
        const Offset(300, 140),
        const Offset(300, 250),
        const Offset(55, 250),
      ]);
      _isClosed = true;
    });
  }

  void _clearPoints() {
    setState(() {
      _points.clear();
      _isClosed = false;
      _infraMarkers.clear();
    });
  }

  void _addPoint(Offset point) {
    if (_isClosed) return;
    setState(() {
      _points.add(point);
      if (_points.length >= 4) {
        _isClosed = true;
      }
    });
  }

  // Calculate Shoelace Polygon Area
  double _calculateShoelaceArea() {
    if (_points.length < 3) return widget.initialArea;
    double area = 0.0;
    int j = _points.length - 1;
    for (int i = 0; i < _points.length; i++) {
      area += (_points[j].dx + _points[i].dx) * (_points[j].dy - _points[i].dy);
      j = i;
    }
    final rawPxArea = (area.abs() / 2.0);
    // Reference base box (240 x 190 = 45600 px^2 = widget.initialArea)
    const basePxArea = 45600.0;
    final scale = rawPxArea / basePxArea;
    final computed = widget.initialArea * scale;
    return (computed < 0.2) ? 0.2 : (computed > 10.0 ? 10.0 : computed);
  }

  // Calculate perimeter in meters
  double _calculatePerimeterMeters() {
    if (_points.length < 2) return 360.0;
    double pxDist = 0.0;
    for (int i = 0; i < _points.length; i++) {
      final p1 = _points[i];
      final p2 = _points[(i + 1) % _points.length];
      pxDist += (p2 - p1).distance;
    }
    // Scale: ~860 px = 360 meters
    return (pxDist / 860.0 * 360.0).clamp(120.0, 1200.0);
  }

  void _addInfraMarker(String type) {
    setState(() {
      _selectedInfraType = type;
      String label = 'Solar Pump';
      if (type == 'gate') label = 'Field Gate';
      if (type == 'shed') label = 'Kisan Shed';
      if (type == 'pond') label = 'Farm Pond';

      _infraMarkers.add({
        'type': type,
        'label': label,
        'pos': const Offset(175, 150),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Placed $type on field. You can drag it anywhere!'),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveFieldLayout() async {
    final area = _calculateShoelaceArea();
    final primary = _storage.getPrimaryFarm();

    // Create / Update calibrated fields
    final f1 = Field(
      name: 'Plot A (Main Crop)',
      area: (area * 0.55).roundToDouble().clamp(0.1, 10.0),
      crop: 'Mustard (Varuna)',
      sowingDate: DateTime.now().subtract(const Duration(days: 35)),
    );
    final f2 = Field(
      name: 'Plot B (Secondary Crop)',
      area: (area * 0.35).roundToDouble().clamp(0.1, 10.0),
      crop: 'Wheat (HD-2967)',
      sowingDate: DateTime.now().subtract(const Duration(days: 22)),
    );
    final f3 = Field(
      name: 'Plot C (Irrigation & Shed)',
      area: (area * 0.10).roundToDouble().clamp(0.05, 5.0),
      crop: 'Farm Infrastructure',
    );

    primary.fields = [f1, f2, f3];
    await _storage.updatePrimaryFarm(primary);

    if (mounted) {
      _showSuccessKhasraSlip(area);
    }
  }

  void _showSuccessKhasraSlip(double area) {
    final perimeter = _calculatePerimeterMeters();
    final bigha = (area * 3.2).toStringAsFixed(1);
    final katha = (area * 64).toStringAsFixed(0);
    final wireFencingCost = (perimeter * 80).round();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
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
                  const Text(
                    'Khasra Land Layout Slip',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EFDF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'SAVED TO MY FARM ✓',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E4D2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Digital Field Cadastral Calibration · Palamu Farmland',
                style: TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 12.5,
                  color: Color(0xFF55655A),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE6E0D2)),
              const SizedBox(height: 12),

              // Key Agritech Measurements Grid
              Row(
                children: [
                  Expanded(
                    child: _buildSlipStat(
                      'Total Area',
                      '${area.toStringAsFixed(2)} Acres',
                      '$bigha Bigha · $katha Katha',
                      Icons.aspect_ratio_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSlipStat(
                      'Boundary Perimeter',
                      '${perimeter.toStringAsFixed(0)} Meters',
                      '~${(perimeter * 3.28).round()} Feet Fencing',
                      Icons.straighten_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSlipStat(
                      'Fencing Estimate',
                      '₹$wireFencingCost',
                      '4-Strand barbed wire + pole',
                      Icons.fence_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSlipStat(
                      'Infra Markers',
                      '${_infraMarkers.length} Points',
                      'Borewell & Gate mapped',
                      Icons.pin_drop_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, _points);
                  },
                  child: const Text(
                    'Done & Return to Planner',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
  }

  Widget _buildSlipStat(String title, String val, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E0D2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1E4D2B)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF55655A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2A21),
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'Mukta',
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF55655A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final homeIndicatorInset = MediaQuery.of(context).padding.bottom;
    final currentArea = _calculateShoelaceArea();
    final perimeter = _calculatePerimeterMeters();

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFDDD6C4), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            offset: Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 26,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIELD CADASTRE & DESIGN',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: Color(0xFF3A6B4A),
                          ),
                        ),
                        Text(
                          'Design My Land',
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

                  // Mode Toggle Button (Satellite vs Blueprint)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSatelliteMode = !_isSatelliteMode;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _isSatelliteMode ? const Color(0xFF1E4D2B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1E4D2B)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSatelliteMode ? Icons.satellite_alt_rounded : Icons.grid_on_rounded,
                            size: 16,
                            color: _isSatelliteMode ? Colors.white : const Color(0xFF1E4D2B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isSatelliteMode ? 'Satellite' : 'Grid Map',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: _isSatelliteMode ? Colors.white : const Color(0xFF1E4D2B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Presets Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPresetChip('🔲 Rectangular', _applyRectangularPreset),
                    const SizedBox(width: 6),
                    _buildPresetChip('📐 Contour Field', _applyContourPreset),
                    const SizedBox(width: 6),
                    _buildPresetChip('⚚ Split 2-Plots', _applySplitPreset),
                    const SizedBox(width: 6),
                    _buildPresetChip('🇱 L-Shape', _applyLShapePreset),
                    const SizedBox(width: 6),
                    _buildPresetChip('🔄 Reset Pins', _clearPoints),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Main Interactive Land Canvas Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFE9E2D1),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Background Layer
                        if (_isSatelliteMode)
                          Positioned.fill(
                            child: const SafeLocalImage(
                              imagePath: 'assets/images/farmer_field.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (_isSatelliteMode)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF122C1A).withOpacity(0.55),
                            ),
                          ),

                        // Blueprint Grid Overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CadastralGridPainter(isSatellite: _isSatelliteMode),
                          ),
                        ),

                        // North Compass Arrow in Top-Right
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation_rounded, color: Color(0xFFF2B134), size: 16),
                                Text(
                                  'N',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Interactive Polygon & Side Dimension Canvas
                        GestureDetector(
                          onTapDown: (details) {
                            _addPoint(details.localPosition);
                          },
                          onPanUpdate: (details) {
                            final touch = details.localPosition;
                            // Check boundary corner pins
                            for (int i = 0; i < _points.length; i++) {
                              if ((_points[i] - touch).distance < 38) {
                                setState(() {
                                  _points[i] = touch;
                                });
                                return;
                              }
                            }
                            // Check infrastructure markers
                            for (int i = 0; i < _infraMarkers.length; i++) {
                              final pos = _infraMarkers[i]['pos'] as Offset;
                              if ((pos - touch).distance < 30) {
                                setState(() {
                                  _infraMarkers[i]['pos'] = touch;
                                });
                                return;
                              }
                            }
                          },
                          child: CustomPaint(
                            painter: _ProFieldPolygonPainter(
                              points: _points,
                              isClosed: _isClosed,
                              showZoning: _showZoning,
                              isSatellite: _isSatelliteMode,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),

                        // Draggable Infrastructure Markers
                        for (int i = 0; i < _infraMarkers.length; i++)
                          Positioned(
                            left: (_infraMarkers[i]['pos'] as Offset).dx - 18,
                            top: (_infraMarkers[i]['pos'] as Offset).dy - 18,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _getInfraColor(_infraMarkers[i]['type']),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _getInfraIcon(_infraMarkers[i]['type']),
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                        // Instruction Banner Top Left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E4D2B).withOpacity(0.90),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded, color: Color(0xFFF2B134), size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Drag pins to calibrate corners A, B, C, D',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom-Left Floating Infrastructure Buttons
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildInfraAddBtn(Icons.water_drop_rounded, 'pump', 'Borewell', const Color(0xFF18566F)),
                                const SizedBox(width: 4),
                                _buildInfraAddBtn(Icons.sensor_door_outlined, 'gate', 'Gate', const Color(0xFF8A5600)),
                                const SizedBox(width: 4),
                                _buildInfraAddBtn(Icons.roofing_rounded, 'shed', 'Shed', const Color(0xFF55655A)),
                                const SizedBox(width: 4),
                                _buildInfraAddBtn(Icons.pool_rounded, 'pond', 'Doba/Pond', const Color(0xFF1E4D2B)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Dimensions Summary & Farmer Unit Converter Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE9E2D1),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDimStat(
                      'Total Land Area',
                      '${currentArea.toStringAsFixed(2)} Ac',
                      '~${(currentArea * 3.2).toStringAsFixed(1)} Bigha',
                      Icons.aspect_ratio_rounded,
                    ),
                    Container(width: 1, height: 38, color: const Color(0xFFE6E0D2)),
                    _buildDimStat(
                      AppLanguage().isHindi ? 'मेड़ परिधि' : 'Perimeter',
                      '${perimeter.toStringAsFixed(0)} m',
                      '~${(perimeter * 3.28).round()} Feet',
                      Icons.straighten_rounded,
                    ),
                    Container(width: 1, height: 38, color: const Color(0xFFE6E0D2)),
                    _buildDimStat(
                      'Wire Fencing',
                      '₹${(perimeter * 80).round()}',
                      '4-Strand Tarbandi',
                      Icons.fence_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Save Button
              GestureDetector(
                onTap: _saveFieldLayout,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D2B),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF123320),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save Field Boundary to My Farm →',
                          style: TextStyle(
                            fontFamily: 'Mukta',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: homeIndicatorInset > 0 ? homeIndicatorInset : 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDD6C4)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B2A21),
          ),
        ),
      ),
    );
  }

  Widget _buildInfraAddBtn(IconData icon, String type, String tooltip, Color color) {
    return InkWell(
      onTap: () => _addInfraMarker(type),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Color _getInfraColor(String type) {
    if (type == 'pump') return const Color(0xFF18566F);
    if (type == 'gate') return const Color(0xFF8A5600);
    if (type == 'shed') return const Color(0xFF55655A);
    return const Color(0xFF1E4D2B);
  }

  IconData _getInfraIcon(String type) {
    if (type == 'pump') return Icons.water_drop_rounded;
    if (type == 'gate') return Icons.sensor_door_outlined;
    if (type == 'shed') return Icons.roofing_rounded;
    return Icons.pool_rounded;
  }

  Widget _buildDimStat(String title, String val, String sub, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E4D2B), size: 18),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2A21),
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF55655A),
          ),
        ),
      ],
    );
  }
}

// 1. Cadastral Grid Painter with furrow lines
class _CadastralGridPainter extends CustomPainter {
  final bool isSatellite;
  _CadastralGridPainter({required this.isSatellite});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isSatellite ? Colors.white.withOpacity(0.12) : const Color(0xFFDDD6C4).withOpacity(0.55))
      ..strokeWidth = 0.8;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CadastralGridPainter oldDelegate) =>
      oldDelegate.isSatellite != isSatellite;
}

// 2. Pro Field Polygon Painter with Corner Badges (A, B, C, D) & Side Dimensions
class _ProFieldPolygonPainter extends CustomPainter {
  final List<Offset> points;
  final bool isClosed;
  final bool showZoning;
  final bool isSatellite;

  _ProFieldPolygonPainter({
    required this.points,
    required this.isClosed,
    required this.showZoning,
    required this.isSatellite,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Boundary Outer Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFF2B134)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Translucent Field Fill
    final fillPaint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(isSatellite ? 0.35 : 0.22)
      ..style = PaintingStyle.fill;

    // Diagonal dashed line for Right-Angle Check (गुनिया)
    if (points.length >= 4) {
      final diagPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(points[0], points[2], diagPaint);
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (isClosed && points.length > 2) {
      path.close();
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, strokePaint);

    // Draw Side Length Measurements & Letter Badges (A, B, C, D...)
    final labels = AppLanguage().isHindi
        ? ['A (उत्तर)', 'B (पूर्व)', 'C (दक्षिण)', 'D (पश्चिम)', 'E', 'F']
        : ['A (North)', 'B (East)', 'C (South)', 'D (West)', 'E', 'F'];

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];

      // Side Distance label at midpoint
      if (isClosed && points.length > 2) {
        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        final distMeters = ((p2 - p1).distance / 2.4).round();

        final distSpan = TextSpan(
          text: '$distMeters m',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSatellite ? Colors.white : const Color(0xFF1B2A21),
            backgroundColor: Colors.black45,
          ),
        );
        final tp = TextPainter(text: distSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
      }

      // Draw GPS Corner Pin
      final pinPaint = Paint()
        ..color = const Color(0xFF1E4D2B)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = const Color(0xFFF2B134)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(p1, 10, pinPaint);
      canvas.drawCircle(p1, 10, borderPaint);

      // Corner Letter Badge
      final letter = (i < labels.length) ? labels[i][0] : '${i + 1}';
      final letterSpan = TextSpan(
        text: letter,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
      final ltp = TextPainter(text: letterSpan, textDirection: TextDirection.ltr);
      ltp.layout();
      ltp.paint(canvas, Offset(p1.dx - ltp.width / 2, p1.dy - ltp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ProFieldPolygonPainter oldDelegate) => true;
}
