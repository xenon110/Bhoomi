import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage_driver.dart';
import '../../models/crop.dart';
import '../../models/diary_entry.dart';
import '../../models/farm.dart';
import '../../models/farmer_profile.dart';
import '../../models/farmland_listing.dart';
import '../../models/ledger_entry.dart';
import '../../models/rental_equipment.dart';
import 'turso_client.dart';
import 'turso_config.dart';
import 'turso_response.dart';

enum TursoConnectionState {
  uninitialized,
  connecting,
  connected,
  offline,
  invalidToken,
  error,
}

class TursoService extends ChangeNotifier {
  static final TursoService _instance = TursoService._internal();
  factory TursoService() => _instance;
  TursoService._internal();

  String _pipelineUrl = TursoConfig.defaultPipelineUrl;
  String _authToken = TursoConfig.initialToken;
  TursoConnectionState _state = TursoConnectionState.uninitialized;
  int _latencyMs = 0;
  String? _lastError;
  bool _isInitialized = false;

  String get pipelineUrl => _pipelineUrl;
  String get authToken => _authToken;
  TursoConnectionState get state => _state;
  bool get isConnected => _state == TursoConnectionState.connected;
  int get latencyMs => _latencyMs;
  String? get lastError => _lastError;

  String get statusLabel {
    switch (_state) {
      case TursoConnectionState.connected:
        return 'Connected (${_latencyMs}ms · Mumbai)';
      case TursoConnectionState.connecting:
        return 'Connecting to Turso Cloud...';
      case TursoConnectionState.invalidToken:
        return 'Auth Token Required / Incomplete';
      case TursoConnectionState.offline:
        return 'Offline (Using Local Storage)';
      case TursoConnectionState.error:
        return 'Connection Error';
      case TursoConnectionState.uninitialized:
        return 'Database Initializing';
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final savedUrl = await readData(TursoConfig.storageKeyUrl);
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _pipelineUrl = savedUrl.trim();
      }

      final savedToken = await readData(TursoConfig.storageKeyToken);
      if (savedToken != null && savedToken.trim().length > 100) {
        _authToken = savedToken.trim();
      } else {
        _authToken = TursoConfig.initialToken;
      }
    } catch (_) {}

    await testConnection();
    if (_state == TursoConnectionState.connected) {
      await ensureSchema();
    }
  }

  Future<bool> updateCredentials({
    required String token,
    String? pipelineUrl,
  }) async {
    final cleanToken = token.trim();
    if (cleanToken.isNotEmpty) {
      _authToken = cleanToken;
      await writeData(TursoConfig.storageKeyToken, cleanToken);
    }

    if (pipelineUrl != null && pipelineUrl.trim().isNotEmpty) {
      _pipelineUrl = pipelineUrl.trim();
      await writeData(TursoConfig.storageKeyUrl, _pipelineUrl);
    }

    final success = await testConnection();
    if (success) {
      await ensureSchema();
    }
    notifyListeners();
    return success;
  }

  Future<bool> testConnection() async {
    _state = TursoConnectionState.connecting;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final payload = jsonEncode({
        'requests': [
          {
            'type': 'execute',
            'stmt': {'sql': 'SELECT 1 as ping;'}
          },
          {'type': 'close'}
        ]
      });

      final TursoHttpResponse res = await sendTursoPost(
        url: _pipelineUrl,
        token: _authToken,
        jsonPayload: payload,
      );

      stopwatch.stop();
      _latencyMs = stopwatch.elapsedMilliseconds;

      if (res.isSuccess) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final results = body['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          if (first['type'] == 'ok') {
            _state = TursoConnectionState.connected;
            _lastError = null;
            notifyListeners();
            return true;
          }
        }
      }

      // Diagnose failure
      if (res.statusCode == 400 || res.statusCode == 401 || res.body.contains('InvalidToken')) {
        _state = TursoConnectionState.invalidToken;
        _lastError = 'Invalid or incomplete JWT token. Please copy the full token from Turso dashboard.';
      } else if (res.statusCode == 408 || res.error != null) {
        _state = TursoConnectionState.offline;
        _lastError = res.error ?? 'Host unreachable';
      } else {
        _state = TursoConnectionState.error;
        _lastError = 'Turso error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      stopwatch.stop();
      _state = TursoConnectionState.offline;
      _lastError = e.toString();
    }

    notifyListeners();
    return false;
  }

  Future<void> ensureSchema() async {
    if (!isConnected) return;

    final statements = [
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        village TEXT,
        district TEXT,
        state TEXT,
        language TEXT,
        soil_type TEXT,
        total_area REAL,
        kisan_id TEXT,
        aadhaar_linked INTEGER,
        weather_alerts INTEGER,
        pest_alerts INTEGER,
        mandi_alerts INTEGER,
        irrigation_alerts INTEGER,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_farms (
        id TEXT PRIMARY KEY,
        farmer_name TEXT NOT NULL,
        village TEXT,
        district TEXT,
        state TEXT,
        total_area REAL,
        fields_json TEXT,
        crops_json TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_crops (
        id TEXT PRIMARY KEY,
        farm_id TEXT NOT NULL,
        name TEXT NOT NULL,
        variety TEXT,
        growth_stage TEXT,
        sowing_date TEXT,
        expected_harvest_date TEXT,
        notes TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_fields (
        id TEXT PRIMARY KEY,
        farm_id TEXT NOT NULL,
        name TEXT NOT NULL,
        area REAL NOT NULL,
        crop TEXT,
        sowing_date TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_equipment (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        rate_per_hour INTEGER NOT NULL,
        rate_per_day INTEGER NOT NULL,
        owner_name TEXT NOT NULL,
        owner_phone TEXT NOT NULL,
        village TEXT NOT NULL,
        district TEXT NOT NULL,
        distance_km REAL,
        image_path TEXT,
        rating REAL,
        total_bookings INTEGER,
        with_driver INTEGER,
        diesel_policy TEXT,
        description TEXT,
        specs_json TEXT,
        is_user_listed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_farmland (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        total_acres REAL NOT NULL,
        price_per_acre_lakhs REAL NOT NULL,
        total_price_lakhs REAL NOT NULL,
        village TEXT NOT NULL,
        district TEXT NOT NULL,
        state TEXT NOT NULL,
        distance_km REAL,
        seller_name TEXT NOT NULL,
        seller_phone TEXT NOT NULL,
        water_source TEXT,
        soil_type TEXT,
        road_access TEXT,
        title_status TEXT,
        image_path TEXT,
        description TEXT,
        suitable_crops_json TEXT,
        is_user_listed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_ledger (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        crop_name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        is_income INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_diary (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_chopal (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        title_hi TEXT,
        author TEXT,
        date TEXT,
        badge TEXT,
        is_urgent INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_claims (
        id TEXT PRIMARY KEY,
        crop_name TEXT NOT NULL,
        cause TEXT NOT NULL,
        damaged_area REAL,
        severity_percent REAL,
        estimated_loss REAL,
        status TEXT DEFAULT 'Under Review',
        date TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''',
      '''
      CREATE TABLE IF NOT EXISTS bhoomi_market_listings (
        id TEXT PRIMARY KEY,
        crop_name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        price TEXT NOT NULL,
        location TEXT NOT NULL,
        phone TEXT,
        date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      '''
    ];

    for (final sql in statements) {
      await executeRaw(sql);
    }
  }

  List<Map<String, dynamic>> _formatArgs(List<dynamic>? args) {
    if (args == null || args.isEmpty) return const [];
    return args.map<Map<String, dynamic>>((arg) {
      if (arg == null) {
        return {'type': 'null'};
      } else if (arg is int) {
        return {'type': 'integer', 'value': arg.toString()};
      } else if (arg is double) {
        return {'type': 'float', 'value': arg};
      } else if (arg is bool) {
        return {'type': 'integer', 'value': arg ? '1' : '0'};
      } else {
        return {'type': 'text', 'value': arg.toString()};
      }
    }).toList();
  }

  Future<bool> executeRaw(String sql, [List<dynamic>? args]) async {
    try {
      final stmt = <String, dynamic>{'sql': sql};
      if (args != null && args.isNotEmpty) {
        stmt['args'] = _formatArgs(args);
      }

      final payload = jsonEncode({
        'requests': [
          {'type': 'execute', 'stmt': stmt},
          {'type': 'close'}
        ]
      });

      final res = await sendTursoPost(
        url: _pipelineUrl,
        token: _authToken,
        jsonPayload: payload,
      );

      if (res.isSuccess) {
        final body = jsonDecode(res.body);
        final results = body['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          return first['type'] == 'ok';
        }
      }
    } catch (_) {}
    return false;
  }

  Future<List<Map<String, dynamic>>> queryRaw(String sql, [List<dynamic>? args]) async {
    try {
      final stmt = <String, dynamic>{'sql': sql};
      if (args != null && args.isNotEmpty) {
        stmt['args'] = _formatArgs(args);
      }

      final payload = jsonEncode({
        'requests': [
          {'type': 'execute', 'stmt': stmt},
          {'type': 'close'}
        ]
      });

      final res = await sendTursoPost(
        url: _pipelineUrl,
        token: _authToken,
        jsonPayload: payload,
      );

      if (res.isSuccess) {
        final body = jsonDecode(res.body);
        final results = body['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results[0] as Map<String, dynamic>;
          if (first['type'] == 'ok') {
            final execResult = first['response']['result'] as Map<String, dynamic>;
            final cols = (execResult['cols'] as List<dynamic>?)
                    ?.map((c) => (c as Map<String, dynamic>)['name'] as String)
                    .toList() ??
                [];
            final rows = execResult['rows'] as List<dynamic>? ?? [];

            final List<Map<String, dynamic>> mapped = [];
            for (final r in rows) {
              final rowValues = r as List<dynamic>;
              final Map<String, dynamic> rowMap = {};
              for (int i = 0; i < cols.length && i < rowValues.length; i++) {
                final colName = cols[i];
                final cell = rowValues[i];
                if (cell is Map<String, dynamic>) {
                  if (cell['type'] == 'null') {
                    rowMap[colName] = null;
                  } else if (cell['type'] == 'integer') {
                    rowMap[colName] = int.tryParse(cell['value'].toString());
                  } else if (cell['type'] == 'float') {
                    rowMap[colName] = (cell['value'] as num).toDouble();
                  } else {
                    rowMap[colName] = cell['value'];
                  }
                } else {
                  rowMap[colName] = cell;
                }
              }
              mapped.add(rowMap);
            }
            return mapped;
          }
        }
      }
    } catch (_) {}
    return [];
  }

  // ==========================================
  // --- 1. FARMER PROFILE CLOUD CRUD ---
  // ==========================================
  Future<FarmerProfile?> fetchProfileCloud() async {
    if (!isConnected) return null;
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_profile WHERE id = ? LIMIT 1;', ['primary']);
      if (rows.isEmpty) return null;
      final r = rows.first;
      return FarmerProfile(
        name: r['name']?.toString() ?? '',
        phone: r['phone']?.toString() ?? '',
        village: r['village']?.toString() ?? '',
        district: r['district']?.toString() ?? '',
        state: r['state']?.toString() ?? '',
        language: r['language']?.toString() ?? 'English',
        soilType: r['soil_type']?.toString() ?? '',
        totalArea: (r['total_area'] as num?)?.toDouble() ?? 0.0,
        kisanId: r['kisan_id']?.toString() ?? '',
        aadhaarLinked: (r['aadhaar_linked'] as num?)?.toInt() == 1,
        weatherAlerts: (r['weather_alerts'] as num?)?.toInt() != 0,
        pestAlerts: (r['pest_alerts'] as num?)?.toInt() != 0,
        mandiAlerts: (r['mandi_alerts'] as num?)?.toInt() != 0,
        irrigationAlerts: (r['irrigation_alerts'] as num?)?.toInt() != 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertProfileCloud(FarmerProfile p) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_profile (
        id, name, phone, village, district, state, language,
        soil_type, total_area, kisan_id, aadhaar_linked,
        weather_alerts, pest_alerts, mandi_alerts, irrigation_alerts, updated_at
      ) VALUES ('primary', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        name=excluded.name,
        phone=excluded.phone,
        village=excluded.village,
        district=excluded.district,
        state=excluded.state,
        language=excluded.language,
        soil_type=excluded.soil_type,
        total_area=excluded.total_area,
        kisan_id=excluded.kisan_id,
        aadhaar_linked=excluded.aadhaar_linked,
        weather_alerts=excluded.weather_alerts,
        pest_alerts=excluded.pest_alerts,
        mandi_alerts=excluded.mandi_alerts,
        irrigation_alerts=excluded.irrigation_alerts,
        updated_at=CURRENT_TIMESTAMP;
    ''';
    await executeRaw(sql, [
      p.name,
      p.phone,
      p.village,
      p.district,
      p.state,
      p.language,
      p.soilType,
      p.totalArea,
      p.kisanId,
      p.aadhaarLinked ? 1 : 0,
      p.weatherAlerts ? 1 : 0,
      p.pestAlerts ? 1 : 0,
      p.mandiAlerts ? 1 : 0,
      p.irrigationAlerts ? 1 : 0,
    ]);
  }

  // ==========================================
  // --- 2. FARMS & FIELDS CLOUD CRUD ---
  // ==========================================
  Future<List<Farm>> fetchFarmsCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_farms ORDER BY updated_at DESC;');
      return rows.map((r) {
        List<Field> fields = [];
        if (r['fields_json'] != null) {
          try {
            final decoded = jsonDecode(r['fields_json'] as String) as List<dynamic>;
            fields = decoded.map((f) => Field.fromJson(f as Map<String, dynamic>)).toList();
          } catch (_) {}
        }

        List<Crop> crops = [];
        if (r['crops_json'] != null) {
          try {
            final decoded = jsonDecode(r['crops_json'] as String) as List<dynamic>;
            crops = decoded.map((c) => Crop.fromJson(c as Map<String, dynamic>)).toList();
          } catch (_) {}
        }

        return Farm(
          farmerName: r['farmer_name']?.toString() ?? '',
          village: r['village']?.toString() ?? '',
          district: r['district']?.toString() ?? '',
          state: r['state']?.toString() ?? '',
          totalArea: (r['total_area'] as num?)?.toDouble() ?? 0.0,
          fields: fields,
          crops: crops,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertFarmCloud(Farm farm, [String id = 'farm_1']) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_farms (
        id, farmer_name, village, district, state, total_area,
        fields_json, crops_json, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        farmer_name=excluded.farmer_name,
        village=excluded.village,
        district=excluded.district,
        state=excluded.state,
        total_area=excluded.total_area,
        fields_json=excluded.fields_json,
        crops_json=excluded.crops_json,
        updated_at=CURRENT_TIMESTAMP;
    ''';
    await executeRaw(sql, [
      id,
      farm.farmerName,
      farm.village,
      farm.district,
      farm.state,
      farm.totalArea,
      jsonEncode(farm.fields.map((f) => f.toJson()).toList()),
      jsonEncode(farm.crops.map((c) => c.toJson()).toList()),
    ]);

    // Also store each crop as a first-class SQL row in bhoomi_crops
    for (int i = 0; i < farm.crops.length; i++) {
      final c = farm.crops[i];
      final cropId = '${id}_crop_${i + 1}';
      const cropSql = '''
        INSERT INTO bhoomi_crops (
          id, farm_id, name, variety, growth_stage, sowing_date,
          expected_harvest_date, notes, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ON CONFLICT(id) DO UPDATE SET
          name=excluded.name,
          variety=excluded.variety,
          growth_stage=excluded.growth_stage,
          sowing_date=excluded.sowing_date,
          expected_harvest_date=excluded.expected_harvest_date,
          notes=excluded.notes,
          updated_at=CURRENT_TIMESTAMP;
      ''';
      await executeRaw(cropSql, [
        cropId,
        id,
        c.name,
        c.variety ?? '',
        c.growthStage ?? '',
        c.sowingDate?.toIso8601String() ?? '',
        c.expectedHarvestDate?.toIso8601String() ?? '',
        c.notes ?? '',
      ]);
    }

    // Also store each field as a first-class SQL row in bhoomi_fields
    for (int i = 0; i < farm.fields.length; i++) {
      final f = farm.fields[i];
      final fieldId = '${id}_field_${i + 1}';
      const fieldSql = '''
        INSERT INTO bhoomi_fields (
          id, farm_id, name, area, crop, sowing_date, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ON CONFLICT(id) DO UPDATE SET
          name=excluded.name,
          area=excluded.area,
          crop=excluded.crop,
          sowing_date=excluded.sowing_date,
          updated_at=CURRENT_TIMESTAMP;
      ''';
      await executeRaw(fieldSql, [
        fieldId,
        id,
        f.name,
        f.area,
        f.crop,
        f.sowingDate?.toIso8601String() ?? '',
      ]);
    }
  }

  // ==========================================
  // --- 3. EQUIPMENT RENTAL CLOUD CRUD ---
  // ==========================================
  Future<List<RentalEquipment>> fetchEquipmentCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_equipment ORDER BY created_at DESC;');
      return rows.map((r) {
        Map<String, String> specs = {};
        if (r['specs_json'] != null) {
          try {
            final decoded = jsonDecode(r['specs_json'] as String) as Map<String, dynamic>;
            specs = decoded.map((k, v) => MapEntry(k, v.toString()));
          } catch (_) {}
        }

        return RentalEquipment(
          id: r['id']?.toString() ?? '',
          name: r['name']?.toString() ?? '',
          category: r['category']?.toString() ?? 'Tractor',
          ratePerHour: (r['rate_per_hour'] as num?)?.toInt() ?? 500,
          ratePerDay: (r['rate_per_day'] as num?)?.toInt() ?? 4000,
          ownerName: r['owner_name']?.toString() ?? '',
          ownerPhone: r['owner_phone']?.toString() ?? '',
          village: r['village']?.toString() ?? '',
          district: r['district']?.toString() ?? 'Palamu',
          distanceKm: (r['distance_km'] as num?)?.toDouble() ?? 2.5,
          imagePath: r['image_path']?.toString() ?? 'assets/images/tractor_rental.jpg',
          rating: (r['rating'] as num?)?.toDouble() ?? 4.8,
          totalBookings: (r['total_bookings'] as num?)?.toInt() ?? 20,
          withDriver: (r['with_driver'] as num?)?.toInt() == 1,
          dieselPolicy: r['diesel_policy']?.toString() ?? 'Diesel by farmer',
          description: r['description']?.toString() ?? '',
          specs: specs,
          isUserListed: (r['is_user_listed'] as num?)?.toInt() == 1,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertEquipmentCloud(RentalEquipment eq) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_equipment (
        id, name, category, rate_per_hour, rate_per_day,
        owner_name, owner_phone, village, district, distance_km,
        image_path, rating, total_bookings, with_driver, diesel_policy,
        description, specs_json, is_user_listed
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        name=excluded.name,
        category=excluded.category,
        rate_per_hour=excluded.rate_per_hour,
        rate_per_day=excluded.rate_per_day,
        owner_name=excluded.owner_name,
        owner_phone=excluded.owner_phone,
        village=excluded.village,
        district=excluded.district,
        distance_km=excluded.distance_km,
        image_path=excluded.image_path,
        rating=excluded.rating,
        total_bookings=excluded.total_bookings,
        with_driver=excluded.with_driver,
        diesel_policy=excluded.diesel_policy,
        description=excluded.description,
        specs_json=excluded.specs_json,
        is_user_listed=excluded.is_user_listed;
    ''';
    await executeRaw(sql, [
      eq.id,
      eq.name,
      eq.category,
      eq.ratePerHour,
      eq.ratePerDay,
      eq.ownerName,
      eq.ownerPhone,
      eq.village,
      eq.district,
      eq.distanceKm,
      eq.imagePath,
      eq.rating,
      eq.totalBookings,
      eq.withDriver ? 1 : 0,
      eq.dieselPolicy,
      eq.description,
      jsonEncode(eq.specs),
      eq.isUserListed ? 1 : 0,
    ]);
  }

  Future<void> deleteEquipmentCloud(String id) async {
    if (!isConnected) return;
    await executeRaw('DELETE FROM bhoomi_equipment WHERE id = ?;', [id]);
  }

  // ==========================================
  // --- 4. FARMLAND MARKETPLACE CLOUD CRUD ---
  // ==========================================
  Future<List<FarmlandListing>> fetchFarmlandCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_farmland ORDER BY created_at DESC;');
      return rows.map((r) {
        List<String> suitableCrops = ['Mustard', 'Wheat', 'Vegetables'];
        if (r['suitable_crops_json'] != null) {
          try {
            final decoded = jsonDecode(r['suitable_crops_json'] as String) as List<dynamic>;
            suitableCrops = decoded.map((c) => c.toString()).toList();
          } catch (_) {}
        }

        return FarmlandListing(
          id: r['id']?.toString() ?? '',
          title: r['title']?.toString() ?? '',
          totalAcres: (r['total_acres'] as num?)?.toDouble() ?? 1.0,
          pricePerAcreLakhs: (r['price_per_acre_lakhs'] as num?)?.toDouble() ?? 5.0,
          totalPriceLakhs: (r['total_price_lakhs'] as num?)?.toDouble() ?? 5.0,
          village: r['village']?.toString() ?? '',
          district: r['district']?.toString() ?? 'Palamu',
          state: r['state']?.toString() ?? 'Jharkhand',
          distanceKm: (r['distance_km'] as num?)?.toDouble() ?? 3.5,
          sellerName: r['seller_name']?.toString() ?? '',
          sellerPhone: r['seller_phone']?.toString() ?? '',
          waterSource: r['water_source']?.toString() ?? 'Borewell',
          soilType: r['soil_type']?.toString() ?? 'Loamy Soil',
          roadAccess: r['road_access']?.toString() ?? 'Paved Road',
          titleStatus: r['title_status']?.toString() ?? 'Clear Registry',
          imagePath: r['image_path']?.toString() ?? 'assets/images/farmland_sale.jpg',
          description: r['description']?.toString() ?? '',
          suitableCrops: suitableCrops,
          isUserListed: (r['is_user_listed'] as num?)?.toInt() == 1,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertFarmlandCloud(FarmlandListing land) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_farmland (
        id, title, total_acres, price_per_acre_lakhs, total_price_lakhs,
        village, district, state, distance_km, seller_name, seller_phone,
        water_source, soil_type, road_access, title_status, image_path,
        description, suitable_crops_json, is_user_listed
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title=excluded.title,
        total_acres=excluded.total_acres,
        price_per_acre_lakhs=excluded.price_per_acre_lakhs,
        total_price_lakhs=excluded.total_price_lakhs,
        village=excluded.village,
        district=excluded.district,
        state=excluded.state,
        distance_km=excluded.distance_km,
        seller_name=excluded.seller_name,
        seller_phone=excluded.seller_phone,
        water_source=excluded.water_source,
        soil_type=excluded.soil_type,
        road_access=excluded.road_access,
        title_status=excluded.title_status,
        image_path=excluded.image_path,
        description=excluded.description,
        suitable_crops_json=excluded.suitable_crops_json,
        is_user_listed=excluded.is_user_listed;
    ''';
    await executeRaw(sql, [
      land.id,
      land.title,
      land.totalAcres,
      land.pricePerAcreLakhs,
      land.totalPriceLakhs,
      land.village,
      land.district,
      land.state,
      land.distanceKm,
      land.sellerName,
      land.sellerPhone,
      land.waterSource,
      land.soilType,
      land.roadAccess,
      land.titleStatus,
      land.imagePath,
      land.description,
      jsonEncode(land.suitableCrops),
      land.isUserListed ? 1 : 0,
    ]);
  }

  Future<void> deleteFarmlandCloud(String id) async {
    if (!isConnected) return;
    await executeRaw('DELETE FROM bhoomi_farmland WHERE id = ?;', [id]);
  }

  // ==========================================
  // --- 5. KISAN LEDGER (BAHI-KHATA) CRUD ---
  // ==========================================
  Future<List<LedgerEntry>> fetchLedgerCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_ledger ORDER BY date DESC;');
      return rows.map((r) {
        return LedgerEntry(
          id: r['id']?.toString() ?? '',
          title: r['title']?.toString() ?? 'General Entry',
          cropName: r['crop_name']?.toString() ?? 'General',
          category: r['category']?.toString() ?? 'Other',
          amount: (r['amount'] as num?)?.toDouble() ?? 0.0,
          isIncome: (r['is_income'] as num?)?.toInt() == 1,
          date: r['date'] != null
              ? DateTime.tryParse(r['date'] as String) ?? DateTime.now()
              : DateTime.now(),
          notes: r['notes']?.toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertLedgerCloud(LedgerEntry entry) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_ledger (
        id, title, crop_name, category, amount, is_income, date, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title=excluded.title,
        crop_name=excluded.crop_name,
        category=excluded.category,
        amount=excluded.amount,
        is_income=excluded.is_income,
        date=excluded.date,
        notes=excluded.notes;
    ''';
    await executeRaw(sql, [
      entry.id,
      entry.title,
      entry.cropName,
      entry.category,
      entry.amount,
      entry.isIncome ? 1 : 0,
      entry.date.toIso8601String(),
      entry.notes ?? '',
    ]);
  }

  Future<void> deleteLedgerCloud(String id) async {
    if (!isConnected) return;
    await executeRaw('DELETE FROM bhoomi_ledger WHERE id = ?;', [id]);
  }

  // ==========================================
  // --- 6. FARM DIARY CLOUD CRUD ---
  // ==========================================
  Future<List<DiaryEntry>> fetchDiaryCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_diary ORDER BY id DESC;');
      return rows.map((r) {
        return DiaryEntry(
          id: r['id']?.toString() ?? '',
          title: r['title']?.toString() ?? '',
          category: r['category']?.toString() ?? '',
          date: r['date']?.toString() ?? '',
          notes: r['notes']?.toString() ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertDiaryCloud(DiaryEntry entry) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_diary (id, title, category, date, notes)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title=excluded.title,
        category=excluded.category,
        date=excluded.date,
        notes=excluded.notes;
    ''';
    await executeRaw(sql, [
      entry.id,
      entry.title,
      entry.category,
      entry.date,
      entry.notes,
    ]);
  }

  Future<void> deleteDiaryCloud(String id) async {
    if (!isConnected) return;
    await executeRaw('DELETE FROM bhoomi_diary WHERE id = ?;', [id]);
  }

  // ==========================================
  // --- 7. KISAN CHOPAL & NOTICES CRUD ---
  // ==========================================
  Future<List<Map<String, dynamic>>> fetchChopalNoticesCloud() async {
    if (!isConnected) return [];
    try {
      return await queryRaw('SELECT * FROM bhoomi_chopal ORDER BY created_at DESC;');
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertChopalNoticeCloud(Map<String, dynamic> notice) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_chopal (id, title, title_hi, author, date, badge, is_urgent)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title=excluded.title,
        title_hi=excluded.title_hi,
        author=excluded.author,
        date=excluded.date,
        badge=excluded.badge,
        is_urgent=excluded.is_urgent;
    ''';
    await executeRaw(sql, [
      notice['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      notice['title']?.toString() ?? '',
      notice['title_hi']?.toString() ?? '',
      notice['author']?.toString() ?? '',
      notice['date']?.toString() ?? '',
      notice['badge']?.toString() ?? '',
      (notice['isUrgent'] == true || notice['is_urgent'] == 1) ? 1 : 0,
    ]);
  }

  // ==========================================
  // --- 8. PMFBY CLAIMS CLOUD CRUD ---
  // ==========================================
  Future<List<Map<String, dynamic>>> fetchClaimsCloud() async {
    if (!isConnected) return [];
    try {
      return await queryRaw('SELECT * FROM bhoomi_claims ORDER BY created_at DESC;');
    } catch (_) {
      return [];
    }
  }

  Future<void> insertClaimCloud(Map<String, dynamic> claim) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_claims (id, crop_name, cause, damaged_area, severity_percent, estimated_loss, status, date)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    ''';
    await executeRaw(sql, [
      claim['id']?.toString() ?? 'CLM_${DateTime.now().millisecondsSinceEpoch}',
      claim['cropName']?.toString() ?? '',
      claim['cause']?.toString() ?? '',
      (claim['damagedArea'] as num?)?.toDouble() ?? 0.0,
      (claim['severityPercent'] as num?)?.toDouble() ?? 0.0,
      (claim['estimatedLoss'] as num?)?.toDouble() ?? 0.0,
      claim['status']?.toString() ?? 'Submitted',
      claim['date']?.toString() ?? DateTime.now().toIso8601String(),
    ]);
  }

  // ==========================================
  // --- 9. BATCH MARKET LISTINGS CLOUD CRUD ---
  // ==========================================
  Future<List<Map<String, dynamic>>> fetchMarketListingsCloud() async {
    if (!isConnected) return [];
    try {
      final rows = await queryRaw('SELECT * FROM bhoomi_market_listings ORDER BY created_at DESC;');
      return rows.map((r) => {
        'id': r['id']?.toString() ?? '',
        'crop': r['crop_name']?.toString() ?? '',
        'quantity': r['quantity']?.toString() ?? '',
        'price': r['price']?.toString() ?? '',
        'location': r['location']?.toString() ?? '',
        'phone': r['phone']?.toString() ?? '',
        'date': r['date']?.toString() ?? '',
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertMarketListingCloud(Map<String, dynamic> item) async {
    if (!isConnected) return;
    const sql = '''
      INSERT INTO bhoomi_market_listings (id, crop_name, quantity, price, location, phone, date)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        crop_name=excluded.crop_name,
        quantity=excluded.quantity,
        price=excluded.price,
        location=excluded.location,
        phone=excluded.phone,
        date=excluded.date;
    ''';
    await executeRaw(sql, [
      item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      item['crop']?.toString() ?? '',
      item['quantity']?.toString() ?? '',
      item['price']?.toString() ?? '',
      item['location']?.toString() ?? '',
      item['phone']?.toString() ?? '',
      item['date']?.toString() ?? 'Today',
    ]);
  }

  Future<void> deleteMarketListingCloud(String id) async {
    if (!isConnected) return;
    await executeRaw('DELETE FROM bhoomi_market_listings WHERE id = ?;', [id]);
  }
}
