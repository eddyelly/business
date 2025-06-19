class ReportModel {
  final int? id;
  final String? userId;
  final String title;
  final String? description;
  final double? amount;
  final String? category;
  final DateTime? date;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportModel({
    this.id,
    this.userId,
    required this.title,
    this.description,
    this.amount,
    this.category,
    this.date,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id']?.toInt(),
      userId: map['user_id'],
      title: map['title'] ?? '',
      description: map['description'],
      amount: map['amount']?.toDouble(),
      category: map['category'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isSynced: (map['is_synced'] ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // For Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      description: json['description'],
      amount: json['amount']?.toDouble(),
      category: json['category'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isSynced: true, // Data from Supabase is considered synced
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  ReportModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, userId: $userId, title: $title, description: $description, amount: $amount, category: $category, date: $date, isSynced: $isSynced, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.isSynced == isSynced &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        date.hashCode ^
        isSynced.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 