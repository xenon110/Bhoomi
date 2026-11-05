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
    this.phone = '',
    required this.village,
    required this.district,
    required this.state,
    this.language = 'English',
    this.weatherAlerts = true,
    this.pestAlerts = true,
    this.mandiAlerts = true,
    this.irrigationAlerts = true,
    this.kisanId = '',
    this.aadhaarLinked = false,
    this.soilType = '',
    this.totalArea = 0.0,
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
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      language: json['language'] as String? ?? 'English',
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      pestAlerts: json['pestAlerts'] as bool? ?? true,
      mandiAlerts: json['mandiAlerts'] as bool? ?? true,
      irrigationAlerts: json['irrigationAlerts'] as bool? ?? true,
      kisanId: json['kisanId'] as String? ?? '',
      aadhaarLinked: json['aadhaarLinked'] as bool? ?? false,
      soilType: json['soilType'] as String? ?? '',
      totalArea: (json['totalArea'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
