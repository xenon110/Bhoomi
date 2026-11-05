class DiaryEntry {
  final String id;
  final String title;
  final String category;
  final String date;
  final String notes;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'notes': notes,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      category: json['category'] as String,
      date: json['date'] as String,
      notes: json['notes'] as String,
    );
  }
}

