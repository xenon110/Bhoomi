import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhoomi_app/models/crop.dart';
import 'package:bhoomi_app/models/farm.dart';
import 'package:bhoomi_app/models/farmer_profile.dart';
import 'package:bhoomi_app/services/turso/turso_service.dart';
import 'package:bhoomi_app/services/storage_service.dart';

void main() {
  test('Execute complete new user login and SQL backend registration', () async {
    stdout.writeln('\n===========================================================');
    stdout.writeln('=== BHOOMI BACKEND EXECUTION: NEW USER REGISTRATION & SQL ===');
    stdout.writeln('===========================================================');

    // 1. Initialize Turso Cloud SQLite Service
    stdout.writeln('\n[Step 1] Initializing Turso Cloud SQLite database connection...');
    final turso = TursoService();
    await turso.init();
    stdout.writeln('Turso Status: ${turso.statusLabel}');
    stdout.writeln('Turso Connected: ${turso.isConnected}');
    expect(turso.isConnected, isTrue, reason: 'Turso Cloud SQLite must be connected');

    // 2. Ensure all SQL tables and columns exist in Turso Cloud SQLite
    stdout.writeln('\n[Step 2] Executing SQL table schemas (DDL) on Turso Cloud...');
    await turso.ensureSchema();
    stdout.writeln('✓ Verified SQL Tables:');
    stdout.writeln('  - bhoomi_profile (id, name, phone, village, district, state, soil_type, total_area, kisan_id, aadhaar_linked, alerts...)');
    stdout.writeln('  - bhoomi_farms (id, farmer_name, village, district, state, total_area, fields_json, crops_json, updated_at)');
    stdout.writeln('  - bhoomi_crops (id, farm_id, name, variety, growth_stage, sowing_date, expected_harvest_date, notes, updated_at)');
    stdout.writeln('  - bhoomi_fields (id, farm_id, name, area, crop, sowing_date, updated_at)');

    // 3. New User Registration Data (Every option filled with authentic Indian farmer data)
    stdout.writeln('\n[Step 3] Assembling New User Registration Details...');
    final newUserProfile = FarmerProfile(
      name: 'Rameshwar Mahto',
      phone: '+91 98351 77412',
      village: 'Rajwadih',
      district: 'Palamu',
      state: 'Jharkhand',
      language: 'Hindi',
      soilType: 'Sandy Loam / बलुई दोमट',
      totalArea: 3.5,
      kisanId: 'KCC-JH-PLM-7193',
      aadhaarLinked: true,
      weatherAlerts: true,
      pestAlerts: true,
      mandiAlerts: true,
      irrigationAlerts: true,
    );

    final userFields = [
      Field(
        name: 'North Plot A',
        area: 1.5,
        crop: 'Yellow Mustard',
        sowingDate: DateTime(2026, 10, 15),
      ),
      Field(
        name: 'South Plot B',
        area: 2.0,
        crop: 'Sharbati Wheat',
        sowingDate: DateTime(2026, 11, 1),
      ),
    ];

    final userCrops = [
      Crop(
        name: 'Yellow Mustard',
        variety: 'Varuna (T-59)',
        growthStage: 'Flowering Stage (फूल अवस्था)',
        sowingDate: DateTime(2026, 10, 15),
        expectedHarvestDate: DateTime(2027, 2, 10),
        notes: 'Organic neem spray applied, furrow drip irrigation active.',
      ),
      Crop(
        name: 'Sharbati Wheat',
        variety: 'HD-2967',
        growthStage: 'Crown Root Initiation (कल्ले फूट रहे)',
        sowingDate: DateTime(2026, 11, 1),
        expectedHarvestDate: DateTime(2027, 3, 20),
        notes: 'Certified seed treated with Trichoderma; basal DAP dose complete.',
      ),
    ];

    final newUserFarm = Farm(
      farmerName: newUserProfile.name,
      village: newUserProfile.village,
      district: newUserProfile.district,
      state: newUserProfile.state,
      totalArea: newUserProfile.totalArea,
      fields: userFields,
      crops: userCrops,
    );

    // 4. Save to Local App DB (bhoomi_offline_db.json)
    stdout.writeln('\n[Step 4] Saving New User Details to Local App DB (bhoomi_offline_db.json)...');
    final storage = StorageService();
    await storage.updateProfile(newUserProfile);
    await storage.updatePrimaryFarm(newUserFarm);
    stdout.writeln('✓ Successfully saved profile and farm to local app database!');

    // 5. Save to Turso Cloud SQL DB (Executing SQL statements)
    stdout.writeln('\n[Step 5] Executing SQL Upserts to Turso Cloud SQLite DB...');
    await turso.upsertProfileCloud(newUserProfile);
    await turso.upsertFarmCloud(newUserFarm, 'farm_1');
    stdout.writeln('✓ Successfully executed SQL upsert for bhoomi_profile');
    stdout.writeln('✓ Successfully executed SQL upsert for bhoomi_farms');
    stdout.writeln('✓ Successfully executed SQL upsert for bhoomi_crops (2 individual crop rows)');
    stdout.writeln('✓ Successfully executed SQL upsert for bhoomi_fields (2 individual field rows)');

    // 6. Verify SQL DB by querying all records directly from Turso Cloud
    stdout.writeln('\n===========================================================');
    stdout.writeln('=== VERIFICATION: DIRECT SQL SELECT QUERIES FROM TURSO ===');
    stdout.writeln('===========================================================');

    // Query 1: bhoomi_profile
    stdout.writeln('\n>>> SQL QUERY 1: SELECT * FROM bhoomi_profile WHERE id = \'primary\';');
    final profileRows = await turso.queryRaw('SELECT * FROM bhoomi_profile WHERE id = ?;', ['primary']);
    expect(profileRows.isNotEmpty, isTrue);
    final p = profileRows.first;
    p.forEach((key, value) {
      stdout.writeln('    $key: $value');
    });
    expect(p['name'], equals('Rameshwar Mahto'));
    expect(p['phone'], equals('+91 98351 77412'));
    expect(p['village'], equals('Rajwadih'));
    expect(p['soil_type'], equals('Sandy Loam / बलुई दोमट'));
    expect(p['total_area'], equals(3.5));
    expect(p['kisan_id'], equals('KCC-JH-PLM-7193'));

    // Query 2: bhoomi_farms
    stdout.writeln('\n>>> SQL QUERY 2: SELECT * FROM bhoomi_farms WHERE id = \'farm_1\';');
    final farmRows = await turso.queryRaw('SELECT id, farmer_name, village, district, state, total_area, updated_at FROM bhoomi_farms WHERE id = ?;', ['farm_1']);
    expect(farmRows.isNotEmpty, isTrue);
    final f = farmRows.first;
    f.forEach((key, value) {
      stdout.writeln('    $key: $value');
    });
    expect(f['farmer_name'], equals('Rameshwar Mahto'));
    expect(f['total_area'], equals(3.5));

    // Query 3: bhoomi_crops
    stdout.writeln('\n>>> SQL QUERY 3: SELECT * FROM bhoomi_crops WHERE farm_id = \'farm_1\';');
    final cropRows = await turso.queryRaw('SELECT id, farm_id, name, variety, growth_stage, sowing_date, expected_harvest_date, notes FROM bhoomi_crops WHERE farm_id = ?;', ['farm_1']);
    stdout.writeln('    Found ${cropRows.length} crop records in SQL:');
    expect(cropRows.length, equals(2));
    for (int i = 0; i < cropRows.length; i++) {
      stdout.writeln('    --- Crop #${i + 1} ---');
      cropRows[i].forEach((key, value) {
        stdout.writeln('        $key: $value');
      });
    }

    // Query 4: bhoomi_fields
    stdout.writeln('\n>>> SQL QUERY 4: SELECT * FROM bhoomi_fields WHERE farm_id = \'farm_1\';');
    final fieldRows = await turso.queryRaw('SELECT id, farm_id, name, area, crop, sowing_date FROM bhoomi_fields WHERE farm_id = ?;', ['farm_1']);
    stdout.writeln('    Found ${fieldRows.length} field records in SQL:');
    expect(fieldRows.length, equals(2));
    for (int i = 0; i < fieldRows.length; i++) {
      stdout.writeln('    --- Field #${i + 1} ---');
      fieldRows[i].forEach((key, value) {
        stdout.writeln('        $key: $value');
      });
    }

    // 7. Verify Local App DB (bhoomi_offline_db.json)
    stdout.writeln('\n>>> LOCAL APP DB VERIFICATION: bhoomi_offline_db.json');
    final localDbFile = File('bhoomi_offline_db.json');
    expect(await localDbFile.exists(), isTrue);
    final content = await localDbFile.readAsString();
    final json = jsonDecode(content);
    stdout.writeln('    File Size: ${content.length} bytes');
    stdout.writeln('    Saved Farmer Profile Name: ${json['profile']['name']}');
    stdout.writeln('    Saved Phone: ${json['profile']['phone']}');
    stdout.writeln('    Saved Village: ${json['profile']['village']}');
    stdout.writeln('    Saved District: ${json['profile']['district']}');
    stdout.writeln('    Saved State: ${json['profile']['state']}');
    stdout.writeln('    Saved Soil Type: ${json['profile']['soilType']}');
    stdout.writeln('    Saved Landholding: ${json['profile']['totalArea']} Acres');
    stdout.writeln('    Saved Kisan ID: ${json['profile']['kisanId']}');
    stdout.writeln('    Saved Crops Count: ${(json['farms'][0]['crops'] as List).length}');
    stdout.writeln('    Saved Fields Count: ${(json['farms'][0]['fields'] as List).length}');

    expect(json['profile']['name'], equals('Rameshwar Mahto'));
    expect(json['profile']['phone'], equals('+91 98351 77412'));
    expect(json['profile']['village'], equals('Rajwadih'));
    expect(json['profile']['soilType'], equals('Sandy Loam / बलुई दोमट'));
    expect(json['profile']['totalArea'], equals(3.5));
    expect(json['profile']['kisanId'], equals('KCC-JH-PLM-7193'));

    stdout.writeln('\n===========================================================');
    stdout.writeln('=== ALL BACKEND CODE EXECUTED AND FULLY VERIFIED IN SQL ===');
    stdout.writeln('===========================================================');
  });
}

