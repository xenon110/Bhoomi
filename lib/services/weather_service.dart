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
  });

  double get temp => temperature;

  factory WeatherForecast.fallback() {
    return WeatherForecast(
      temperature: 28.0,
      condition: 'Partly cloudy',
      rainChance: 20,
      humidity: 62,
      windSpeed: 11.0,
      agriculturalAdvice:
          'Favorable window for field irrigation and light weeding. Safe for morning foliar spray.',
      dailyForecasts: [
        DailyForecast(
          day: 'Today',
          temp: '28° / 17° C',
          condition: 'Partly cloudy',
          rainProb: '20%',
          advice: 'Safe for morning organic neem spraying.',
        ),
        DailyForecast(
          day: 'Tomorrow',
          temp: '29° / 18° C',
          condition: 'Mostly Sunny',
          rainProb: '10%',
          advice: 'Ideal for soil tillage and drying harvested produce.',
        ),
        DailyForecast(
          day: 'Thursday',
          temp: '28° / 17° C',
          condition: 'Clear Sky',
          rainProb: '5%',
          advice: 'Schedule evening drip irrigation.',
        ),
      ],
      isLive: true,
      lastUpdated: DateTime.now(),
      source: 'Palamu Weather Station (Local Dummy Feed)',
    );
  }
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  WeatherForecast? _cachedForecast;

  Future<WeatherForecast> getWeather({
    double lat = 24.04, // Palamu / Medininagar Coordinates
    double lon = 84.07,
  }) async {
    // Current dummy implementation requested by user:
    // 28°C, Partly cloudy, Rain 20%, Palamu
    // (Will be connected to custom backend API later)
    _cachedForecast = WeatherForecast.fallback();
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

