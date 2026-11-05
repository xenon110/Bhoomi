class FarmerProfile {
  String name;
  String phone;
  String village;
  String district;
  String state;
  String language;
  bool weatherAlerts;
  bool pestAlerts;
  bool mandiAlerts;
  bool irrigationAlerts;
  String kisanId;
  bool aadhaarLinked;
  String soilType;
  double totalArea;

  FarmerProfile({
    required this.name,
    this.phone = '+91 98765 43210',
    required this.village,
    required this.district,
    required this.state,
    this.language = 'English',
    this.weatherAlerts = true,
    this.pestAlerts = true,
    this.mandiAlerts = true,
    this.irrigationAlerts = true,
    this.kisanId = 'KCC-JH-PLM-4821',
    this.aadhaarLinked = true,
    this.soilType = 'Loamy / Sandy Loam',
    this.totalArea = 2.0,
  });

  String get location => '$village, $district';

  FarmerProfile copyWith({
    String? name,
    String? phone,
    String? village,
    String? district,
    String? state,
    String? location,
    String? language,
    bool? weatherAlerts,
    bool? pestAlerts,
    bool? mandiAlerts,
    bool? irrigationAlerts,
    String? kisanId,
    bool? aadhaarLinked,
    String? soilType,
    double? totalArea,
  }) {
    String v = village ?? this.village;
    String d = district ?? this.district;
    if (location != null && location.contains(',')) {
      final parts = location.split(',');
      v = parts[0].trim();
      d = parts.sublist(1).join(',').trim();
    } else if (location != null) {
      v = location.trim();
    }
    return FarmerProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      village: v,
      district: d,
      state: state ?? this.state,
      language: language ?? this.language,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      pestAlerts: pestAlerts ?? this.pestAlerts,
      mandiAlerts: mandiAlerts ?? this.mandiAlerts,
      irrigationAlerts: irrigationAlerts ?? this.irrigationAlerts,
      kisanId: kisanId ?? this.kisanId,
      aadhaarLinked: aadhaarLinked ?? this.aadhaarLinked,
      soilType: soilType ?? this.soilType,
      totalArea: totalArea ?? this.totalArea,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'district': district,
      'state': state,
      'language': language,
      'weatherAlerts': weatherAlerts,
      'pestAlerts': pestAlerts,
      'mandiAlerts': mandiAlerts,
      'irrigationAlerts': irrigationAlerts,
      'kisanId': kisanId,
      'aadhaarLinked': aadhaarLinked,
      'soilType': soilType,
      'totalArea': totalArea,
    };
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      name: json['name'] as String? ?? 'Kisan User',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      village: json['village'] as String? ?? 'Chianki',
      district: json['district'] as String? ?? 'Palamu',
      state: json['state'] as String? ?? 'Jharkhand',
      language: json['language'] as String? ?? 'English',
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      pestAlerts: json['pestAlerts'] as bool? ?? true,
      mandiAlerts: json['mandiAlerts'] as bool? ?? true,
      irrigationAlerts: json['irrigationAlerts'] as bool? ?? true,
      kisanId: json['kisanId'] as String? ?? 'KCC-JH-PLM-4821',
      aadhaarLinked: json['aadhaarLinked'] as bool? ?? true,
      soilType: json['soilType'] as String? ?? 'Loamy / Sandy Loam',
      totalArea: (json['totalArea'] as num?)?.toDouble() ?? 2.0,
    );
  }
}
