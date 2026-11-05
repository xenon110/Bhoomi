class Crop {
  String name;
  String? variety;
  DateTime? sowingDate;
  DateTime? expectedHarvestDate;
  String? growthStage;
  String? notes;

  Crop({
    required this.name,
    this.variety,
    this.sowingDate,
    this.expectedHarvestDate,
    this.growthStage,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'variety': variety,
      'sowingDate': sowingDate?.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
      'growthStage': growthStage,
      'notes': notes,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      name: json['name'] as String,
      variety: json['variety'] as String?,
      sowingDate: json['sowingDate'] != null
          ? DateTime.tryParse(json['sowingDate'] as String)
          : null,
      expectedHarvestDate: json['expectedHarvestDate'] != null
          ? DateTime.tryParse(json['expectedHarvestDate'] as String)
          : null,
      growthStage: json['growthStage'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
