/// Model representing an agricultural income or expense entry in Kisan Bahi-Khata.
class LedgerEntry {
  final String id;
  final String title;
  final String cropName;
  final String category; // 'Seed', 'Fertilizer', 'Diesel/Tractor', 'Labor', 'Irrigation', 'Pesticide', 'Sale', 'Govt Subsidy', 'Other'
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String? notes;

  LedgerEntry({
    required this.id,
    required this.title,
    required this.cropName,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cropName': cropName,
      'category': category,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'General Entry',
      cropName: json['cropName'] as String? ?? 'General',
      category: json['category'] as String? ?? 'Other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome: json['isIncome'] as bool? ?? false,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}

