import 'crop.dart';

class Field {
  String name;
  double area; // acres
  String crop;
  DateTime? sowingDate;

  Field({
    required this.name,
    required this.area,
    required this.crop,
    this.sowingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'area': area,
      'crop': crop,
      'sowingDate': sowingDate?.toIso8601String(),
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      name: json['name'] as String,
      area: (json['area'] as num).toDouble(),
      crop: json['crop'] as String,
      sowingDate: json['sowingDate'] != null
          ? DateTime.tryParse(json['sowingDate'] as String)
          : null,
    );
  }
}

class Farm {
  String farmerName;
  String village;
  String district;
  String state;
  double totalArea; // in acres
  List<Field> fields;
  List<Crop> crops;

  Farm({
    required this.farmerName,
    required this.village,
    required this.district,
    required this.state,
    required this.totalArea,
    List<Field>? fields,
    List<Crop>? crops,
  })  : fields = fields ?? [],
        crops = crops ?? [];

  Map<String, dynamic> toJson() {
    return {
      'farmerName': farmerName,
      'village': village,
      'district': district,
      'state': state,
      'totalArea': totalArea,
      'fields': fields.map((f) => f.toJson()).toList(),
      'crops': crops.map((c) => c.toJson()).toList(),
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      farmerName: json['farmerName'] as String,
      village: json['village'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      totalArea: (json['totalArea'] as num).toDouble(),
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => Field.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      crops: (json['crops'] as List<dynamic>?)
              ?.map((c) => Crop.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
