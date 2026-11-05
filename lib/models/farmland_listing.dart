class FarmlandListing {
  final String id;
  final String title;
  final double totalAcres;
  final double pricePerAcreLakhs;
  final double totalPriceLakhs;
  final String village;
  final String district;
  final String state;
  final double distanceKm;
  final String sellerName;
  final String sellerPhone;
  final String waterSource;
  final String soilType;
  final String roadAccess;
  final String titleStatus;
  final String imagePath;
  final String description;
  final List<String> suitableCrops;
  final bool isUserListed;

  const FarmlandListing({
    required this.id,
    required this.title,
    required this.totalAcres,
    required this.pricePerAcreLakhs,
    required this.totalPriceLakhs,
    required this.village,
    required this.district,
    this.state = 'Jharkhand',
    this.distanceKm = 3.5,
    required this.sellerName,
    required this.sellerPhone,
    required this.waterSource,
    required this.soilType,
    required this.roadAccess,
    required this.titleStatus,
    required this.imagePath,
    required this.description,
    this.suitableCrops = const ['Mustard', 'Wheat', 'Vegetables'],
    this.isUserListed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalAcres': totalAcres,
        'pricePerAcreLakhs': pricePerAcreLakhs,
        'totalPriceLakhs': totalPriceLakhs,
        'village': village,
        'district': district,
        'state': state,
        'distanceKm': distanceKm,
        'sellerName': sellerName,
        'sellerPhone': sellerPhone,
        'waterSource': waterSource,
        'soilType': soilType,
        'roadAccess': roadAccess,
        'titleStatus': titleStatus,
        'imagePath': imagePath,
        'description': description,
        'suitableCrops': suitableCrops,
        'isUserListed': isUserListed,
      };

  factory FarmlandListing.fromJson(Map<String, dynamic> json) => FarmlandListing(
        id: json['id'] as String,
        title: json['title'] as String,
        totalAcres: (json['totalAcres'] as num).toDouble(),
        pricePerAcreLakhs: (json['pricePerAcreLakhs'] as num).toDouble(),
        totalPriceLakhs: (json['totalPriceLakhs'] as num).toDouble(),
        village: json['village'] as String,
        district: json['district'] as String? ?? 'Palamu',
        state: json['state'] as String? ?? 'Jharkhand',
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 3.5,
        sellerName: json['sellerName'] as String,
        sellerPhone: json['sellerPhone'] as String,
        waterSource: json['waterSource'] as String? ?? 'Borewell',
        soilType: json['soilType'] as String? ?? 'Loamy Soil',
        roadAccess: json['roadAccess'] as String? ?? 'Paved Road',
        titleStatus: json['titleStatus'] as String? ?? 'Clear Registry',
        imagePath: json['imagePath'] as String? ?? 'assets/images/optimized_farmland.jpg',
        description: json['description'] as String? ?? '',
        suitableCrops: (json['suitableCrops'] as List<dynamic>?)?.map((c) => c.toString()).toList() ??
            const ['Mustard', 'Wheat', 'Vegetables'],
        isUserListed: json['isUserListed'] as bool? ?? false,
      );
}

