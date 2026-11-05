import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_driver.dart';
import 'turso/turso_service.dart';
import '../models/crop.dart';
import '../models/diary_entry.dart';
import '../models/farm.dart';
import '../models/farmer_profile.dart';
import '../models/farmland_listing.dart';
import '../models/ledger_entry.dart';
import '../models/rental_equipment.dart';

/// Central reactive data repository for Bhoomi.
/// Manages persistence, offline state, and notifies listening UI components
/// whenever farm, crops, diary entries, or profile information changes.
class StorageService extends ChangeNotifier {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal() {
    _loadDefaults();
  }

  bool _isInitialized = false;

  late FarmerProfile _profile;
  late List<Farm> _farms;
  late List<DiaryEntry> _diaryEntries;
  late List<LedgerEntry> _ledgerEntries;
  late List<RentalEquipment> _rentalEquipment;
  late List<FarmlandListing> _farmlandListings;
  List<Map<String, dynamic>> _marketListings = [];
  String? _appliedPlanTitle;
  bool _languageChosenByUser = false;

  static const String _storageFileName = 'bhoomi_offline_db.json';

  Future<void> init() async {
    if (_isInitialized) return;

    _loadDefaults();

    try {
      final content = await readData(_storageFileName);
      if (content != null && content.trim().isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(content);

        if (data['languageChosenByUser'] == true) {
          _languageChosenByUser = true;
        }

        if (data['profile'] != null) {
          _profile = FarmerProfile.fromJson(data['profile']);
          if (!_languageChosenByUser) {
            _profile.language = 'English';
          }
        }

        if (data['farms'] != null) {
          _farms = (data['farms'] as List<dynamic>)
              .map((f) => Farm.fromJson(f as Map<String, dynamic>))
              .toList();
        }

        if (data['diary'] != null) {
          _diaryEntries = (data['diary'] as List<dynamic>)
              .map((d) => DiaryEntry.fromJson(d as Map<String, dynamic>))
              .toList();
        }

        if (data['ledger'] != null) {
          _ledgerEntries = (data['ledger'] as List<dynamic>)
              .map((l) => LedgerEntry.fromJson(l as Map<String, dynamic>))
              .toList();
        }

        if (data['equipment'] != null) {
          _rentalEquipment = (data['equipment'] as List<dynamic>)
              .map((e) => RentalEquipment.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (data['farmland'] != null) {
          _farmlandListings = (data['farmland'] as List<dynamic>)
              .map((l) => FarmlandListing.fromJson(l as Map<String, dynamic>))
              .toList();
        }

        if (data['marketListings'] != null) {
          _marketListings = (data['marketListings'] as List<dynamic>)
              .map((m) => Map<String, dynamic>.from(m as Map))
              .toList();
        }

        _appliedPlanTitle = data['appliedPlan'] as String?;
      }
    } catch (_) {
      // Fallback to solid in-memory defaults
    }

    _isInitialized = true;

    // Connect and synchronize with Turso 24/7 Edge SQLite Cloud
    try {
      await TursoService().init();
      if (TursoService().isConnected) {
        await _syncFromTursoCloud();
      }
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _syncFromTursoCloud() async {
    if (!TursoService().isConnected) return;
    try {
      // 1. Profile Cloud Sync
      final cloudProfile = await TursoService().fetchProfileCloud();
      if (cloudProfile != null) {
        _profile = cloudProfile;
      } else {
        await TursoService().upsertProfileCloud(_profile);
      }

      // 2. Farms & Fields Cloud Sync
      final cloudFarms = await TursoService().fetchFarmsCloud();
      if (cloudFarms.isNotEmpty) {
        _farms = cloudFarms;
      } else {
        for (int i = 0; i < _farms.length; i++) {
          await TursoService().upsertFarmCloud(_farms[i], 'farm_${i + 1}');
        }
      }

      // 3. Equipment Cloud Sync
      final cloudEq = await TursoService().fetchEquipmentCloud();
      if (cloudEq.isNotEmpty) {
        _rentalEquipment = cloudEq;
      } else {
        for (final eq in _rentalEquipment) {
          await TursoService().upsertEquipmentCloud(eq);
        }
      }

      // 4. Farmland Cloud Sync
      final cloudLand = await TursoService().fetchFarmlandCloud();
      if (cloudLand.isNotEmpty) {
        _farmlandListings = cloudLand;
      } else {
        for (final land in _farmlandListings) {
          await TursoService().upsertFarmlandCloud(land);
        }
      }

      // 5. Ledger Cloud Sync
      final cloudLedger = await TursoService().fetchLedgerCloud();
      if (cloudLedger.isNotEmpty) {
        _ledgerEntries = cloudLedger;
      } else {
        for (final entry in _ledgerEntries) {
          await TursoService().upsertLedgerCloud(entry);
        }
      }

      // 6. Diary Cloud Sync
      final cloudDiary = await TursoService().fetchDiaryCloud();
      if (cloudDiary.isNotEmpty) {
        _diaryEntries = cloudDiary;
      } else {
        for (final diary in _diaryEntries) {
          await TursoService().upsertDiaryCloud(diary);
        }
      }

      // 7. Market Listings Cloud Sync
      final cloudListings = await TursoService().fetchMarketListingsCloud();
      if (cloudListings.isNotEmpty) {
        _marketListings = cloudListings;
      } else {
        for (final item in _marketListings) {
          await TursoService().upsertMarketListingCloud(item);
        }
      }

      await _persistToDisk();
      notifyListeners();
    } catch (_) {}
  }

  /// Manually trigger a full push of all local data to Turso Cloud
  Future<void> syncAllToTurso() async {
    if (!TursoService().isConnected) return;
    try {
      await TursoService().upsertProfileCloud(_profile);
      for (int i = 0; i < _farms.length; i++) {
        await TursoService().upsertFarmCloud(_farms[i], 'farm_${i + 1}');
      }
      for (final eq in _rentalEquipment) {
        await TursoService().upsertEquipmentCloud(eq);
      }
      for (final land in _farmlandListings) {
        await TursoService().upsertFarmlandCloud(land);
      }
      for (final entry in _ledgerEntries) {
        await TursoService().upsertLedgerCloud(entry);
      }
      for (final diary in _diaryEntries) {
        await TursoService().upsertDiaryCloud(diary);
      }
      for (final item in _marketListings) {
        await TursoService().upsertMarketListingCloud(item);
      }
      notifyListeners();
    } catch (_) {}
  }

  void _loadDefaults() {
    _profile = FarmerProfile(
      name: '',
      phone: '',
      village: '',
      district: '',
      state: '',
      language: 'English',
      totalArea: 0.0,
      kisanId: '',
      aadhaarLinked: false,
      soilType: '',
    );

    final defaultFarm = Farm(
      farmerName: '',
      village: '',
      district: '',
      state: '',
      totalArea: 0.0,
      fields: [],
      crops: [],
    );

    _farms = [defaultFarm];

    _diaryEntries = [];

    _ledgerEntries = [];

    _rentalEquipment = [
      const RentalEquipment(
        id: 'eq_1',
        name: 'Mahindra 575 DI XP Plus (47 HP)',
        category: 'Tractor',
        ratePerHour: 550,
        ratePerDay: 4200,
        ownerName: 'Rameshwar Yadav',
        ownerPhone: '+91 98351 44210',
        village: 'Rampur Village',
        district: 'Palamu',
        distanceKm: 2.1,
        imagePath: 'assets/images/tractor_rental.jpg',
        rating: 4.9,
        totalBookings: 38,
        withDriver: true,
        dieselPolicy: 'Diesel provided by farmer',
        description: 'Heavy duty 47 HP tractor equipped with rotavator & cultivator. Expert local driver included. Best for deep tillage and field leveling.',
        specs: {
          'Power': '47 HP Engine',
          'Drive': '2WD Heavy Rear Axle',
          'Driver': 'Experienced Driver Included',
          'Attachments': 'Rotavator (6ft) + 9-Tyne Cultivator',
          'Fuel Policy': 'Farmer provides diesel',
        },
      ),
      const RentalEquipment(
        id: 'eq_2',
        name: 'John Deere 5050D (50 HP 4WD)',
        category: 'Tractor',
        ratePerHour: 650,
        ratePerDay: 4800,
        ownerName: 'Sardar Gurpreet Singh',
        ownerPhone: '+91 94312 88410',
        village: 'Kalyanpur',
        district: 'Palamu',
        distanceKm: 3.4,
        imagePath: 'assets/images/tractor_rental.jpg',
        rating: 4.8,
        totalBookings: 52,
        withDriver: true,
        dieselPolicy: 'Diesel by farmer or ₹120/hr diesel surcharge',
        description: 'Powerful 4-Wheel Drive John Deere tractor. Exceptional grip on wet black soil and puddle fields. Comes with laser land leveler.',
        specs: {
          'Power': '50 HP Turbo',
          'Drive': '4WD All-Terrain',
          'Driver': 'Skilled Operator Included',
          'Attachments': 'Laser Leveler & Heavy Disc Harrow',
          'Fuel Policy': 'Farmer provides diesel',
        },
      ),
      const RentalEquipment(
        id: 'eq_3',
        name: 'Preet 987 Self-Propelled Combine Harvester',
        category: 'Harvester',
        ratePerHour: 2200,
        ratePerDay: 18000,
        ownerName: 'Birendra Mahto',
        ownerPhone: '+91 97711 33201',
        village: 'Sonpur',
        district: 'Palamu',
        distanceKm: 4.8,
        imagePath: 'assets/images/farmer_field.jpg',
        rating: 4.9,
        totalBookings: 29,
        withDriver: true,
        dieselPolicy: 'Includes diesel & machine operator',
        description: 'High capacity multi-crop combine harvester for Wheat, Paddy, Mustard and Gram. Cleans and sacks grain directly in field.',
        specs: {
          'Capacity': '1.5 Acres per Hour',
          'Cutter Bar': '14 Feet Width',
          'Driver': '2 Operators Included',
          'Loss Rate': '< 1.2% Low Loss Header',
          'Fuel Policy': 'Diesel Included in Rate',
        },
      ),
      const RentalEquipment(
        id: 'eq_4',
        name: 'DJI Agras T40 Smart Spraying Drone',
        category: 'Drone',
        ratePerHour: 700,
        ratePerDay: 5500,
        ownerName: 'Vikash Kumar (Certified Pilot)',
        ownerPhone: '+91 91234 56789',
        village: 'Chanki',
        district: 'Palamu',
        distanceKm: 1.5,
        imagePath: 'assets/images/optimized_farmland.jpg',
        rating: 5.0,
        totalBookings: 46,
        withDriver: true,
        dieselPolicy: 'Electric Battery (Batteries & Generator Included)',
        description: 'DGCA certified agricultural drone for ultra-fine pesticide and liquid nano-urea foliar spraying. Covers 1 acre in just 7 minutes with zero wastage.',
        specs: {
          'Payload': '40 kg / 40 Liter Tank',
          'Speed': '1 Acre in 7 Minutes',
          'Pilot': 'Certified Drone Pilot Included',
          'Accuracy': 'Centimeter RTK Precision',
          'Coverage': 'Even atomized droplet spray',
        },
      ),
      const RentalEquipment(
        id: 'eq_5',
        name: 'Shaktiman Semi-Champion Rotavator (6 Feet)',
        category: 'Tillage',
        ratePerHour: 350,
        ratePerDay: 2600,
        ownerName: 'Manohar Tiwari',
        ownerPhone: '+91 93041 22987',
        village: 'Rampur Village',
        district: 'Palamu',
        distanceKm: 2.7,
        imagePath: 'assets/images/tractor_rental.jpg',
        rating: 4.7,
        totalBookings: 64,
        withDriver: false,
        dieselPolicy: 'Attachment only (Fits any 40+ HP tractor)',
        description: 'Heavy duty Boron steel L-type 42 blades rotavator. Pulverizes soil in single pass. Compatible with 540 RPM PTO shaft.',
        specs: {
          'Working Width': '6 Feet (1.8 Meter)',
          'Blades': '42 Boron Steel L-Blades',
          'Gearbox': 'Multi-speed Oil Bath',
          'Requirement': '40 HP+ Tractor PTO',
          'Mount': 'Standard 3-Point Linkage',
        },
      ),
    ];

    _farmlandListings = [
      const FarmlandListing(
        id: 'land_1',
        title: '3.5 Acres Fertile Irrigated Farmland',
        totalAcres: 3.5,
        pricePerAcreLakhs: 8.5,
        totalPriceLakhs: 29.75,
        village: 'Sonpur Village',
        district: 'Palamu',
        state: 'Jharkhand',
        distanceKm: 2.8,
        sellerName: 'Birendra Pratap Singh',
        sellerPhone: '+91 97712 88390',
        waterSource: 'Active Borewell (5 HP Submersible) + Canal Water',
        soilType: 'Rich Black Loam',
        roadAccess: '18-ft Metaled Paved Road Access',
        titleStatus: 'Clear Title · 100% Khata/Khasra Registry Ready',
        imagePath: 'assets/images/farmland_sale.jpg',
        description: 'Highly fertile rectangular leveled plot. Sown with mustard and wheat every year. 3-phase agricultural power connection already installed on boundary. Zero dispute.',
        suitableCrops: ['Mustard', 'Wheat', 'Potato', 'Vegetables'],
      ),
      const FarmlandListing(
        id: 'land_2',
        title: '5.0 Acres Flat Agricultural Plot with Tubewell',
        totalAcres: 5.0,
        pricePerAcreLakhs: 7.2,
        totalPriceLakhs: 36.0,
        village: 'Chanki',
        district: 'Palamu',
        state: 'Jharkhand',
        distanceKm: 1.6,
        sellerName: 'Kameshwar Mahto',
        sellerPhone: '+91 94311 77209',
        waterSource: 'Deep Borewell (180 ft) with concrete water tank',
        soilType: 'Clay Loam',
        roadAccess: 'Direct Tractor Chak Road (14 ft)',
        titleStatus: 'Inherited Ancestral Land · Dakhil-Kharij Up to Date',
        imagePath: 'assets/images/optimized_farmland.jpg',
        description: 'Well-maintained single-block 5-acre agricultural land. Concrete water distribution channels to all 4 corners. Surrounding farms have active solar fencing.',
        suitableCrops: ['Paddy', 'Wheat', 'Maize', 'Sugarcane'],
      ),
      const FarmlandListing(
        id: 'land_3',
        title: '2.0 Acres Highway Facing Commercial/Agri Land',
        totalAcres: 2.0,
        pricePerAcreLakhs: 12.5,
        totalPriceLakhs: 25.0,
        village: 'Kalyanpur',
        district: 'Palamu',
        state: 'Jharkhand',
        distanceKm: 4.2,
        sellerName: 'Devendra Sharma',
        sellerPhone: '+91 98350 11982',
        waterSource: 'Perennial Open Well + Borewell Provision',
        soilType: 'Alluvial Soil',
        roadAccess: 'National Highway Connected (Double Lane)',
        titleStatus: 'Freehold Clear Title · Mutation Receipt Available',
        imagePath: 'assets/images/farmer_field.jpg',
        description: 'Prime 2-acre plot directly abutting main connecting road. Ideal for high-value organic polyhouse farming, dairy farm, warehouse, or agro-processing unit.',
        suitableCrops: ['Medicinal Plants', 'Vegetables', 'Greenhouse Flowers', 'Dairy Farm'],
      ),
    ];

    _marketListings = [];
  }

  Future<void> _persistToDisk() async {
    try {
      final Map<String, dynamic> data = {
        'profile': _profile.toJson(),
        'farms': _farms.map((f) => f.toJson()).toList(),
        'diary': _diaryEntries.map((d) => d.toJson()).toList(),
        'ledger': _ledgerEntries.map((l) => l.toJson()).toList(),
        'equipment': _rentalEquipment.map((e) => e.toJson()).toList(),
        'farmland': _farmlandListings.map((l) => l.toJson()).toList(),
        'marketListings': _marketListings,
        'appliedPlan': _appliedPlanTitle,
        'languageChosenByUser': _languageChosenByUser,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await writeData(_storageFileName, jsonEncode(data));
    } catch (_) {
      // Graceful fallback
    }
  }

  // Farm operations
  Farm getPrimaryFarm() {
    if (_farms.isEmpty) {
      _farms.add(Farm(
        farmerName: _profile.name,
        village: _profile.village,
        district: _profile.district,
        state: _profile.state,
        totalArea: _profile.totalArea,
        fields: [],
        crops: [],
      ));
    }
    return _farms.first;
  }

  List<Farm> getAllFarms() => List.unmodifiable(_farms);

  Future<void> addFarm(Farm farm) async {
    _farms.add(farm);
    await _persistToDisk();
    notifyListeners();
  }

  Future<void> updatePrimaryFarm(Farm updated) async {
    if (_farms.isNotEmpty) {
      _farms[0] = updated;
    } else {
      _farms.add(updated);
    }
    await _persistToDisk();
    TursoService().upsertFarmCloud(updated, 'farm_1');
    notifyListeners();
  }

  Future<void> addCropToPrimaryFarm(Crop crop) async {
    final farm = getPrimaryFarm();
    // Check if crop already exists; if so, update it, otherwise append
    final idx = farm.crops.indexWhere((c) => c.name.toLowerCase() == crop.name.toLowerCase());
    if (idx >= 0) {
      farm.crops[idx] = crop;
    } else {
      farm.crops.add(crop);
    }
    await _persistToDisk();
    TursoService().upsertFarmCloud(farm, 'farm_1');
    notifyListeners();
  }

  Future<void> removeCropFromPrimaryFarm(String cropName) async {
    final farm = getPrimaryFarm();
    farm.crops.removeWhere((c) => c.name.toLowerCase() == cropName.toLowerCase());
    await _persistToDisk();
    TursoService().upsertFarmCloud(farm, 'farm_1');
    notifyListeners();
  }

  Future<void> addFieldToPrimaryFarm(Field field) async {
    final farm = getPrimaryFarm();
    farm.fields.add(field);
    await _persistToDisk();
    TursoService().upsertFarmCloud(farm, 'farm_1');
    notifyListeners();
  }

  // Diary operations
  List<DiaryEntry> getDiaryEntries() => List.unmodifiable(_diaryEntries);

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    _diaryEntries.insert(0, entry);
    await _persistToDisk();
    TursoService().upsertDiaryCloud(entry);
    notifyListeners();
  }

  Future<void> deleteDiaryEntry(String id) async {
    _diaryEntries.removeWhere((d) => d.id == id);
    await _persistToDisk();
    TursoService().deleteDiaryCloud(id);
    notifyListeners();
  }

  // Profile operations
  FarmerProfile getProfile() => _profile;

  Future<void> updateProfile(FarmerProfile updated) async {
    _profile = updated;
    await _persistToDisk();
    TursoService().upsertProfileCloud(updated);
    notifyListeners();
  }

  Future<void> saveProfile(FarmerProfile updated) async {
    await updateProfile(updated);
  }

  Future<void> setLanguage(String lang) async {
    _profile.language = lang;
    _languageChosenByUser = true;
    await _persistToDisk();
    TursoService().upsertProfileCloud(_profile);
    notifyListeners();
  }

  // Plan operations
  String? getAppliedPlan() => _appliedPlanTitle;

  Future<void> saveAppliedPlan(String title) async {
    _appliedPlanTitle = title;
    await _persistToDisk();
    notifyListeners();
  }

  // Ledger (Kisan Bahi-Khata) operations
  List<LedgerEntry> getLedgerEntries() => List.unmodifiable(_ledgerEntries);

  Future<void> addLedgerEntry(LedgerEntry entry) async {
    _ledgerEntries.insert(0, entry);
    await _persistToDisk();
    TursoService().upsertLedgerCloud(entry);
    notifyListeners();
  }

  Future<void> deleteLedgerEntry(String id) async {
    _ledgerEntries.removeWhere((l) => l.id == id);
    await _persistToDisk();
    TursoService().deleteLedgerCloud(id);
    notifyListeners();
  }

  double getTotalIncome({String? cropName}) {
    return _ledgerEntries
        .where((l) => l.isIncome && (cropName == null || cropName == 'All' || l.cropName.toLowerCase() == cropName.toLowerCase()))
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double getTotalExpense({String? cropName}) {
    return _ledgerEntries
        .where((l) => !l.isIncome && (cropName == null || cropName == 'All' || l.cropName.toLowerCase() == cropName.toLowerCase()))
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double getNetProfit({String? cropName}) {
    return getTotalIncome(cropName: cropName) - getTotalExpense(cropName: cropName);
  }

  // Equipment Rental operations
  List<RentalEquipment> getRentalEquipment() => List.unmodifiable(_rentalEquipment);

  Future<void> addRentalEquipment(RentalEquipment eq) async {
    _rentalEquipment.insert(0, eq);
    await _persistToDisk();
    TursoService().upsertEquipmentCloud(eq);
    notifyListeners();
  }

  Future<void> deleteRentalEquipment(String id) async {
    _rentalEquipment.removeWhere((e) => e.id == id);
    await _persistToDisk();
    TursoService().deleteEquipmentCloud(id);
    notifyListeners();
  }

  // Farmland operations
  List<FarmlandListing> getFarmlandListings() => List.unmodifiable(_farmlandListings);

  Future<void> addFarmlandListing(FarmlandListing land) async {
    _farmlandListings.insert(0, land);
    await _persistToDisk();
    TursoService().upsertFarmlandCloud(land);
    notifyListeners();
  }

  Future<void> deleteFarmlandListing(String id) async {
    _farmlandListings.removeWhere((l) => l.id == id);
    await _persistToDisk();
    TursoService().deleteFarmlandCloud(id);
    notifyListeners();
  }

  // Market Listings operations
  List<Map<String, dynamic>> getMarketListings() => List.unmodifiable(_marketListings);

  Future<void> addMarketListing(Map<String, dynamic> item) async {
    _marketListings.insert(0, item);
    await _persistToDisk();
    TursoService().upsertMarketListingCloud(item);
    notifyListeners();
  }

  Future<void> deleteMarketListing(String id) async {
    _marketListings.removeWhere((l) => l['id'] == id);
    await _persistToDisk();
    TursoService().deleteMarketListingCloud(id);
    notifyListeners();
  }

  // Data maintenance
  Future<void> resetAllData() async {
    _loadDefaults();
    await _persistToDisk();
    notifyListeners();
  }

  String exportDataAsJson() {
    final Map<String, dynamic> data = {
      'profile': _profile.toJson(),
      'farms': _farms.map((f) => f.toJson()).toList(),
      'diary': _diaryEntries.map((d) => d.toJson()).toList(),
      'ledger': _ledgerEntries.map((l) => l.toJson()).toList(),
      'equipment': _rentalEquipment.map((e) => e.toJson()).toList(),
      'farmland': _farmlandListings.map((l) => l.toJson()).toList(),
      'marketListings': _marketListings,
      'appliedPlan': _appliedPlanTitle,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
