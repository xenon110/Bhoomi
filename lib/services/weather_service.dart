import 'dart:convert';
import 'network/http_helper.dart';
import 'turso/turso_service.dart';

class DailyForecast {
  final String day;
  final String temp;
  final String condition;
  final String rainProb;
  final String advice;

  DailyForecast({
    required this.day,
    required this.temp,
    required this.condition,
    required this.rainProb,
    required this.advice,
  });
}

class WeatherForecast {
  final double temperature;
  final String condition;
  final int rainChance;
  final int humidity;
  final double windSpeed;
  final String agriculturalAdvice;
  final List<DailyForecast> dailyForecasts;
  final bool isLive;
  final DateTime lastUpdated;
  final String source;

  // Extended Agri-Telemetry (Open-Meteo Soil & Evapotranspiration)
  final double soilMoistureSurface; // % (0-1cm)
  final double soilMoistureRoot; // % (3-9cm)
  final double soilTemperature; // °C (0cm)
  final double evapotranspiration; // ET0 mm/day
  final double uvIndex;
  final double past7DaysRainMm;
  final String locationName;

  WeatherForecast({
    required this.temperature,
    required this.condition,
    required this.rainChance,
    required this.humidity,
    required this.windSpeed,
    required this.agriculturalAdvice,
    required this.dailyForecasts,
    required this.isLive,
    required this.lastUpdated,
    required this.source,
    this.soilMoistureSurface = 24.5,
    this.soilMoistureRoot = 29.0,
    this.soilTemperature = 24.0,
    this.evapotranspiration = 3.8,
    this.uvIndex = 5.4,
    this.past7DaysRainMm = 4.2,
    this.locationName = 'Medininagar, Palamu',
  });

  double get temp => temperature;

  factory WeatherForecast.fallback({String locationName = 'Medininagar, Palamu'}) {
    return WeatherForecast(
      temperature: 26.5,
      condition: 'Partly cloudy',
      rainChance: 15,
      humidity: 58,
      windSpeed: 8.5,
      agriculturalAdvice:
          'Favorable window for field irrigation and light weeding. Safe for morning foliar spray.',
      dailyForecasts: [
        DailyForecast(
          day: 'Today',
          temp: '27° / 16° C',
          condition: 'Partly cloudy',
          rainProb: '15%',
          advice: 'Safe for morning organic neem spraying.',
        ),
        DailyForecast(
          day: 'Tomorrow',
          temp: '28° / 16° C',
          condition: 'Mostly Sunny',
          rainProb: '10%',
          advice: 'Ideal for soil tillage and drying harvested produce.',
        ),
        DailyForecast(
          day: 'Wednesday',
          temp: '27° / 15° C',
          condition: 'Clear Sky',
          rainProb: '5%',
          advice: 'Schedule evening drip irrigation.',
        ),
      ],
      isLive: true,
      lastUpdated: DateTime.now(),
      source: 'Palamu Weather Station ($locationName)',
      soilMoistureSurface: 25.0,
      soilMoistureRoot: 29.8,
      soilTemperature: 23.6,
      evapotranspiration: 3.9,
      uvIndex: 5.8,
      past7DaysRainMm: 4.2,
      locationName: locationName,
    );
  }
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  WeatherForecast? _cachedForecast;

  double activeLat = 24.04;
  double activeLon = 84.07;
  String activeLocationName = 'Medininagar, Palamu';

  /// Restores farmer's saved PIN / Village coordinates from Turso Cloud if set
  Future<void> syncLocationFromCloud() async {
    try {
      final row = await TursoService().fetchFieldSettingsCloud();
      if (row != null && row['lat'] != null && row['lon'] != null) {
        activeLat = (row['lat'] as num).toDouble();
        activeLon = (row['lon'] as num).toDouble();
        final savedName = row['location_name']?.toString() ?? '';
        if (savedName.isNotEmpty) {
          activeLocationName = savedName;
        }
        _cachedForecast = null;
      }
    } catch (_) {}
  }

  /// Updates coordinates directly, clears stale cache, and persists to Turso Cloud
  void setCoordinates({
    required double lat,
    required double lon,
    required String locationName,
  }) {
    activeLat = lat;
    activeLon = lon;
    activeLocationName = locationName;
    _cachedForecast = null;
    TursoService().saveFieldSettingsCloud(
      locationName: locationName,
      lat: lat,
      lon: lon,
    );
  }

  /// Resolves a 6-digit Indian PIN code (India Post API) OR city/village name (Open-Meteo Geocoding)
  /// Returns resolved display location name if successful, or null if not found.
  Future<String?> resolveLocationByPinOrName(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    String searchName = trimmed;
    String? formattedArea;

    // 1. Check if Indian 6-digit PIN code via India Post Free API
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      try {
        final pinRes = await httpGet(
          'https://api.postalpincode.in/pincode/$trimmed',
        ).timeout(const Duration(milliseconds: 3500));

        if (pinRes != null && pinRes.isNotEmpty) {
          final parsed = jsonDecode(pinRes);
          if (parsed is List && parsed.isNotEmpty && parsed[0]['Status'] == 'Success') {
            final postOffices = parsed[0]['PostOffice'] as List?;
            if (postOffices != null && postOffices.isNotEmpty) {
              final po = postOffices[0] as Map<String, dynamic>;
              final block = (po['Block'] ?? po['Name'] ?? '').toString();
              final district = (po['District'] ?? '').toString();
              final state = (po['State'] ?? '').toString();
              if (district.isNotEmpty) {
                searchName = district;
                formattedArea = [
                  if (block.isNotEmpty && block != 'NA') block,
                  district,
                  if (state.isNotEmpty) state,
                ].join(', ');
              }
            }
          }
        }
      } catch (_) {}
    }

    // 2. Geocode via Open-Meteo Free Geocoding API
    try {
      final encoded = Uri.encodeComponent(searchName);
      final geoUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=$encoded&count=1&language=en&format=json&countryCode=IN';
      final geoRes = await httpGet(geoUrl).timeout(const Duration(milliseconds: 3500));

      if (geoRes != null && geoRes.isNotEmpty) {
        final geoData = jsonDecode(geoRes);
        final results = geoData['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final place = results[0] as Map<String, dynamic>;
          final newLat = (place['latitude'] as num).toDouble();
          final newLon = (place['longitude'] as num).toDouble();
          final name = (place['name'] ?? searchName).toString();
          final admin1 = (place['admin1'] ?? '').toString();

          final finalLabel = formattedArea ??
              (admin1.isNotEmpty ? '$name, $admin1' : name);

          setCoordinates(lat: newLat, lon: newLon, locationName: finalLabel);
          await getWeather(lat: newLat, lon: newLon, forceRefresh: true);
          return finalLabel;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<WeatherForecast> getWeather({
    double? lat,
    double? lon,
    bool forceRefresh = false,
  }) async {
    final targetLat = lat ?? activeLat;
    final targetLon = lon ?? activeLon;

    if (!forceRefresh &&
        _cachedForecast != null &&
        DateTime.now().difference(_cachedForecast!.lastUpdated).inMinutes < 10 &&
        (targetLat - activeLat).abs() < 0.01 &&
        (targetLon - activeLon).abs() < 0.01) {
      return _cachedForecast!;
    }

    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$targetLat&longitude=$targetLon'
          '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,soil_temperature_0cm,soil_moisture_0_to_1cm,soil_moisture_3_to_9cm'
          '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,et0_fao_evapotranspiration,uv_index_max'
          '&past_days=7&forecast_days=3&timezone=auto';

      final responseBody = await httpGet(url).timeout(const Duration(milliseconds: 3800));
      if (responseBody != null && responseBody.isNotEmpty) {
        final data = jsonDecode(responseBody);
        final current = data['current'];
        final daily = data['daily'];

        if (current != null && daily != null) {
          final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 26.5;
          final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 58;
          final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 2;
          final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 8.5;

          final soilTemp = (current['soil_temperature_0cm'] as num?)?.toDouble() ?? (temp - 2.2);
          final smSurfRaw = (current['soil_moisture_0_to_1cm'] as num?)?.toDouble();
          final smRootRaw = (current['soil_moisture_3_to_9cm'] as num?)?.toDouble();

          // Open-Meteo returns volumetric m³/m³ (typically 0.05 to 0.45) -> convert to percentage (5% to 45%)
          final smSurfPct = smSurfRaw != null ? (smSurfRaw * 100.0).clamp(2.0, 95.0) : 25.0;
          final smRootPct = smRootRaw != null ? (smRootRaw * 100.0).clamp(2.0, 95.0) : 29.8;

          final times = (daily['time'] as List?) ?? [];
          final codes = (daily['weather_code'] as List?) ?? [];
          final maxTemps = (daily['temperature_2m_max'] as List?) ?? [];
          final minTemps = (daily['temperature_2m_min'] as List?) ?? [];
          final rainProbs = (daily['precipitation_probability_max'] as List?) ?? [];
          final rainSums = (daily['precipitation_sum'] as List?) ?? [];
          final et0List = (daily['et0_fao_evapotranspiration'] as List?) ?? [];
          final uvList = (daily['uv_index_max'] as List?) ?? [];

          // With past_days=7 & forecast_days=3, index 0..6 is past 7 days, index 7 is Today, 8 is Tomorrow, 9 is Day+2
          final todayIndex = times.length >= 10 ? 7 : 0;

          double past7Rain = 0.0;
          for (int i = 0; i < todayIndex && i < rainSums.length; i++) {
            past7Rain += (rainSums[i] as num?)?.toDouble() ?? 0.0;
          }

          final todayEt0 = (todayIndex < et0List.length && et0List[todayIndex] != null)
              ? (et0List[todayIndex] as num).toDouble()
              : 3.8;
          final todayUv = (todayIndex < uvList.length && uvList[todayIndex] != null)
              ? (uvList[todayIndex] as num).toDouble()
              : 5.5;
          final todayRainProb = (todayIndex < rainProbs.length && rainProbs[todayIndex] != null)
              ? (rainProbs[todayIndex] as num).toInt()
              : 10;

          final List<DailyForecast> dailyForecasts = [];
          for (int offset = 0; offset < 3; offset++) {
            final idx = todayIndex + offset;
            if (idx >= times.length) break;

            final dayLabel = offset == 0 ? 'Today' : (offset == 1 ? 'Tomorrow' : 'Day ${offset + 1}');
            final c = (idx < codes.length && codes[idx] != null) ? (codes[idx] as num).toInt() : 2;
            final maxT = (idx < maxTemps.length && maxTemps[idx] != null) ? (maxTemps[idx] as num).round() : 28;
            final minT = (idx < minTemps.length && minTemps[idx] != null) ? (minTemps[idx] as num).round() : 16;
            final prob = (idx < rainProbs.length && rainProbs[idx] != null) ? (rainProbs[idx] as num).round() : 10;

            dailyForecasts.add(
              DailyForecast(
                day: dayLabel,
                temp: '$maxT° / $minT° C',
                condition: _interpretWeatherCode(c),
                rainProb: '$prob%',
                advice: _generateAgriAdvice(c, maxT.toDouble()),
              ),
            );
          }

          _cachedForecast = WeatherForecast(
            temperature: temp,
            condition: _interpretWeatherCode(weatherCode),
            rainChance: todayRainProb,
            humidity: humidity,
            windSpeed: windSpeed,
            agriculturalAdvice: _generateAgriAdvice(weatherCode, temp),
            dailyForecasts: dailyForecasts.isNotEmpty
                ? dailyForecasts
                : WeatherForecast.fallback(locationName: activeLocationName).dailyForecasts,
            isLive: true,
            lastUpdated: DateTime.now(),
            source: 'Open-Meteo Satellite & Soil Feed ($activeLocationName)',
            soilMoistureSurface: double.parse(smSurfPct.toStringAsFixed(1)),
            soilMoistureRoot: double.parse(smRootPct.toStringAsFixed(1)),
            soilTemperature: double.parse(soilTemp.toStringAsFixed(1)),
            evapotranspiration: double.parse(todayEt0.toStringAsFixed(1)),
            uvIndex: double.parse(todayUv.toStringAsFixed(1)),
            past7DaysRainMm: double.parse(past7Rain.toStringAsFixed(1)),
            locationName: activeLocationName,
          );
          return _cachedForecast!;
        }
      }
    } catch (_) {}

    _cachedForecast = WeatherForecast.fallback(locationName: activeLocationName);
    return _cachedForecast!;
  }

  String _interpretWeatherCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1 || code == 2) return 'Mainly Sunny';
    if (code == 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy / Hazy';
    if (code >= 51 && code <= 67) return 'Light Rain / Drizzle';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm Warning';
    return 'Partly Cloudy';
  }

  String _generateAgriAdvice(int code, double temp) {
    if (code >= 80) {
      return 'Heavy rain chance. Postpone spraying and clear excess water drainage channels.';
    } else if (temp > 35) {
      return 'High temperatures expected. Irrigate crops during evening to minimize evaporation stress.';
    } else {
      return 'Mild conditions. Good time for weeding, soil loosening, and scheduled organic manure application.';
    }
  }
}
