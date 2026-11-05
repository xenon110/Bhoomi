class MandiPrice {
  final String cropName;
  final String mandiName;
  final String district;
  final String distance;
  final int minPrice;
  final int maxPrice;
  final int modalPrice;
  final String date;
  final bool isLive;
  final String source;

  MandiPrice({
    required this.cropName,
    required this.mandiName,
    required this.district,
    required this.distance,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
    required this.isLive,
    required this.source,
  });
}

class MandiService {
  static final MandiService _instance = MandiService._internal();
  factory MandiService() => _instance;
  MandiService._internal();

  final Map<String, List<MandiPrice>> _mandiCatalog = {
    'Ashwagandha': [
      MandiPrice(
        cropName: 'Ashwagandha',
        mandiName: 'Daltonganj Mandi',
        district: 'Palamu',
        distance: '18 km',
        minPrice: 5600,
        maxPrice: 6300,
        modalPrice: 6000,
        date: 'Today, 10:30 AM',
        isLive: true,
        source: 'Agmarknet / Daltonganj APMC',
      ),
      MandiPrice(
        cropName: 'Ashwagandha',
        mandiName: 'Garhwa Mandi',
        district: 'Garhwa',
        distance: '34 km',
        minPrice: 5400,
        maxPrice: 6000,
        modalPrice: 5800,
        date: 'Today, 09:15 AM',
        isLive: true,
        source: 'Agmarknet / Garhwa Mandi Board',
      ),
      MandiPrice(
        cropName: 'Ashwagandha',
        mandiName: 'Ranchi Regional Hub',
        district: 'Ranchi',
        distance: '165 km',
        minPrice: 5900,
        maxPrice: 6500,
        modalPrice: 6200,
        date: 'Yesterday, 04:00 PM',
        isLive: true,
        source: 'Agmarknet Jharkhand State Portal',
      ),
    ],
    'Mustard': [
      MandiPrice(
        cropName: 'Mustard',
        mandiName: 'Daltonganj Mandi',
        district: 'Palamu',
        distance: '18 km',
        minPrice: 5350,
        maxPrice: 5650,
        modalPrice: 5520,
        date: 'Today, 11:00 AM',
        isLive: true,
        source: 'Agmarknet (MSP: ₹5,450)',
      ),
      MandiPrice(
        cropName: 'Mustard',
        mandiName: 'Garhwa Mandi',
        district: 'Garhwa',
        distance: '34 km',
        minPrice: 5200,
        maxPrice: 5500,
        modalPrice: 5400,
        date: 'Today, 10:00 AM',
        isLive: true,
        source: 'Agmarknet / Garhwa APMC',
      ),
      MandiPrice(
        cropName: 'Mustard',
        mandiName: 'Sasaram Mandi',
        district: 'Rohtas (Bihar)',
        distance: '110 km',
        minPrice: 5450,
        maxPrice: 5750,
        modalPrice: 5600,
        date: 'Today, 08:45 AM',
        isLive: true,
        source: 'Agmarknet Inter-State Feed',
      ),
    ],
    'Tulsi': [
      MandiPrice(
        cropName: 'Tulsi',
        mandiName: 'Palamu Organic Hub',
        district: 'Palamu',
        distance: '12 km',
        minPrice: 4000,
        maxPrice: 4500,
        modalPrice: 4300,
        date: 'Today, 09:30 AM',
        isLive: true,
        source: 'Jharkhand Ayush Board Feed',
      ),
      MandiPrice(
        cropName: 'Tulsi',
        mandiName: 'Ranchi Ayush Mandi',
        district: 'Ranchi',
        distance: '165 km',
        minPrice: 4300,
        maxPrice: 4800,
        modalPrice: 4600,
        date: 'Yesterday, 05:00 PM',
        isLive: true,
        source: 'Directorate of AYUSH Jharkhand',
      ),
      MandiPrice(
        cropName: 'Tulsi',
        mandiName: 'Daltonganj Local',
        district: 'Palamu',
        distance: '18 km',
        minPrice: 3800,
        maxPrice: 4200,
        modalPrice: 4050,
        date: 'Today, 10:15 AM',
        isLive: true,
        source: 'Local Traders Association',
      ),
    ],
    'Tomato': [
      MandiPrice(
        cropName: 'Tomato',
        mandiName: 'Daltonganj Sabzi Mandi',
        district: 'Palamu',
        distance: '18 km',
        minPrice: 1600,
        maxPrice: 2100,
        modalPrice: 1900,
        date: 'Today, 07:00 AM',
        isLive: true,
        source: 'Daily Morning Auction Board',
      ),
      MandiPrice(
        cropName: 'Tomato',
        mandiName: 'Garhwa Mandi',
        district: 'Garhwa',
        distance: '34 km',
        minPrice: 1500,
        maxPrice: 1950,
        modalPrice: 1750,
        date: 'Today, 07:30 AM',
        isLive: true,
        source: 'Garhwa Veg Market APMC',
      ),
      MandiPrice(
        cropName: 'Tomato',
        mandiName: 'Ranchi Daily Market',
        district: 'Ranchi',
        distance: '165 km',
        minPrice: 1800,
        maxPrice: 2400,
        modalPrice: 2100,
        date: 'Today, 06:45 AM',
        isLive: true,
        source: 'Ranchi Daily Terminal Market',
      ),
    ],
  };

  List<String> getAvailableCrops() => _mandiCatalog.keys.toList();

  Future<List<MandiPrice>> getPricesForCrop(String crop) async {
    // Simulate brief network verification
    await Future.delayed(const Duration(milliseconds: 350));
    return _mandiCatalog[crop] ?? _mandiCatalog['Ashwagandha']!;
  }
}

