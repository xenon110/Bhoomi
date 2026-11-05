class RentalEquipment {
  final String id;
  final String name;
  final String category;
  final int ratePerHour;
  final int ratePerDay;
  final String ownerName;
  final String ownerPhone;
  final String village;
  final String district;
  final double distanceKm;
  final String imagePath;
  final double rating;
  final int totalBookings;
  final bool withDriver;
  final String dieselPolicy;
  final String description;
  final Map<String, String> specs;
  final bool isUserListed;

  const RentalEquipment({
    required this.id,
    required this.name,
    required this.category,
    required this.ratePerHour,
    required this.ratePerDay,
    required this.ownerName,
    required this.ownerPhone,
    required this.village,
    required this.district,
    required this.distanceKm,
    required this.imagePath,
    this.rating = 4.8,
    this.totalBookings = 24,
    this.withDriver = true,
    this.dieselPolicy = 'Diesel provided by farmer',
    required this.description,
    this.specs = const {},
    this.isUserListed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'ratePerHour': ratePerHour,
        'ratePerDay': ratePerDay,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'village': village,
        'district': district,
        'distanceKm': distanceKm,
        'imagePath': imagePath,
        'rating': rating,
        'totalBookings': totalBookings,
        'withDriver': withDriver,
        'dieselPolicy': dieselPolicy,
        'description': description,
        'specs': specs,
        'isUserListed': isUserListed,
      };

  factory RentalEquipment.fromJson(Map<String, dynamic> json) => RentalEquipment(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        ratePerHour: (json['ratePerHour'] as num).toInt(),
        ratePerDay: (json['ratePerDay'] as num).toInt(),
        ownerName: json['ownerName'] as String,
        ownerPhone: json['ownerPhone'] as String,
        village: json['village'] as String,
        district: json['district'] as String? ?? 'Palamu',
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 2.5,
        imagePath: json['imagePath'] as String? ?? 'assets/images/farmer_field.jpg',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
        totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 20,
        withDriver: json['withDriver'] as bool? ?? true,
        dieselPolicy: json['dieselPolicy'] as String? ?? 'Diesel by farmer',
        description: json['description'] as String? ?? '',
        specs: (json['specs'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v.toString()),
            ) ??
            const {},
        isUserListed: json['isUserListed'] as bool? ?? false,
      );
}

