import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/rental_equipment.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_local_image.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final RentalEquipment equipment;

  const EquipmentDetailScreen({Key? key, required this.equipment}) : super(key: key);

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  bool _isDailySelected = false;

  void _showBookingSheet(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    int duration = _isDailySelected ? 1 : 4;
    final dateCtrl = TextEditingController(text: isHindi ? 'आज ही' : 'Today');
    final locationCtrl = TextEditingController(text: widget.equipment.village);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final totalEst = _isDailySelected
              ? widget.equipment.ratePerDay * duration
              : widget.equipment.ratePerHour * duration;

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Book Rental Equipment',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
                            ),
                          ),
                          Text(
                            widget.equipment.name,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF55655A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EFDF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _isDailySelected ? 'Per Day' : 'Per Hour',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Duration selector
                Row(
                  children: [
                    Text(
                      _isDailySelected ? 'Number of Days:' : 'Number of Hours:',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1E4D2B)),
                      onPressed: () {
                        if (duration > 1) {
                          setModalState(() => duration--);
                        }
                      },
                    ),
                    Text(
                      '$duration ${_isDailySelected ? "Day(s)" : "Hour(s)"}',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2A21),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E4D2B)),
                      onPressed: () {
                        setModalState(() => duration++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Delivery / Farm location
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                    labelText: isHindi ? 'खेत का पता (Delivery Location)' : 'Field / Delivery Location',
                    labelStyle: const TextStyle(fontFamily: 'Mukta', color: Color(0xFF55655A), fontSize: 13),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF1E4D2B), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),

                // Estimated bill card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE6E0D2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Rental Cost',
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF55655A),
                            ),
                          ),
                          Text(
                            '₹$totalEst',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E4D2B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.equipment.withDriver ? '✓ Driver Included' : 'Self Operated',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Confirm button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✓ Booking request for ${widget.equipment.name} sent to ${widget.equipment.ownerName}!',
                          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: const Color(0xFF1E4D2B),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Confirm Booking Request →',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  void _callOwner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dialing ${widget.equipment.ownerName} (${widget.equipment.ownerPhone})...',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _whatsappOwner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening WhatsApp chat with ${widget.equipment.ownerName}...',
          style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eq = widget.equipment;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: CustomScrollView(
        slivers: [
          // E-Commerce Product Image Sliver AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E4D2B),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B2A21), size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Color(0xFF1B2A21), size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing equipment link on WhatsApp...')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SafeLocalImage(
                    imagePath: eq.imagePath,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        eq.category,
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF2B134), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${eq.rating} (${eq.totalBookings} jobs)',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A21),
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

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment Title
                  Text(
                    eq.name,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location & Distance
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF1E4D2B)),
                      const SizedBox(width: 4),
                      Text(
                        '${eq.village}, ${eq.district} · ${eq.distanceKm} km away',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF55655A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pricing Switcher Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E0D2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFE9E2D1),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Hourly Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isDailySelected = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: !_isDailySelected ? const Color(0xFFE2EFDF) : const Color(0xFFF6F2E9),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: !_isDailySelected ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                                      width: !_isDailySelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Hourly Rate',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF55655A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${eq.ratePerHour} / hr',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: !_isDailySelected ? const Color(0xFF1E4D2B) : const Color(0xFF1B2A21),
                                        ),
                                      ),
                                      Text(
                                        'Short farm jobs',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Daily Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isDailySelected = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: _isDailySelected ? const Color(0xFFE2EFDF) : const Color(0xFFF6F2E9),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _isDailySelected ? const Color(0xFF1E4D2B) : const Color(0xFFDDD6C4),
                                      width: _isDailySelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Daily Rate',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF55655A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${eq.ratePerDay} / day',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _isDailySelected ? const Color(0xFF1E4D2B) : const Color(0xFF1B2A21),
                                        ),
                                      ),
                                      Text(
                                        'Full day (8 hrs)',
                                        style: TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFEEE8DA)),
                        const SizedBox(height: 8),

                        // Badges for driver and fuel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  eq.withDriver ? Icons.person_rounded : Icons.person_outline,
                                  size: 16,
                                  color: const Color(0xFF1E4D2B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  eq.withDriver ? 'Driver Included ✓' : 'Self Operated',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_gas_station_rounded, size: 16, color: Color(0xFF8A5600)),
                                const SizedBox(width: 6),
                                Text(
                                  eq.dieselPolicy.contains('Included') ? 'Diesel Included' : 'Diesel by Renter',
                                  style: const TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8A5600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Owner Information Card (Trust & Contact)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E0D2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE2EFDF),
                              child: Text(
                                eq.ownerName.isNotEmpty ? eq.ownerName[0] : 'K',
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E4D2B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        eq.ownerName,
                                        style: const TextStyle(
                                          fontFamily: 'Mukta',
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1B2A21),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF1E4D2B), size: 16),
                                    ],
                                  ),
                                  Text(
                                    '${eq.village} · Verified Machine Owner',
                                    style: const TextStyle(
                                      fontFamily: 'Mukta',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF55655A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Contact Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _callOwner(context),
                                icon: const Icon(Icons.call_rounded, size: 16, color: Color(0xFF1E4D2B)),
                                label: const Text(
                                  'Call Owner',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1E4D2B)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _whatsappOwner(context),
                                icon: const Icon(Icons.chat_outlined, size: 16, color: Colors.white),
                                label: const Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    fontFamily: 'Mukta',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Machine Specifications
                  const Text(
                    'Machine Specifications',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6E0D2)),
                    ),
                    child: Column(
                      children: eq.specs.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF55655A),
                                ),
                              ),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontFamily: 'Mukta',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B2A21),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Description
                  const Text(
                    'About This Equipment',
                    style: TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2A21),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    eq.description,
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 90), // Bottom padding for sticky button
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isDailySelected ? '₹${eq.ratePerDay}' : '₹${eq.ratePerHour}',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E4D2B),
                    ),
                  ),
                  Text(
                    _isDailySelected ? 'Per Day (8 hrs)' : 'Per Hour Rate',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF55655A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showBookingSheet(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF123320),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Book Machine Now →',
                      style: TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

