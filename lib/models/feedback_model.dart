class FeedbackModel {
  final int? id;
  final String? userId;
  final String title;
  final String description;
  final String? category;
  final int? rating;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeedbackModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.category,
    this.rating,
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
      'category': category,
      'rating': rating,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id']?.toInt(),
      userId: map['user_id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'],
      rating: map['rating']?.toInt(),
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
      'category': category,
      'rating': rating,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      rating: json['rating'],
      isSynced: true, // Data from Supabase is considered synced
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  FeedbackModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    int? rating,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FeedbackModel(id: $id, userId: $userId, title: $title, description: $description, category: $category, rating: $rating, isSynced: $isSynced, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeedbackModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.rating == rating &&
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
        category.hashCode ^
        rating.hashCode ^
        isSynced.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 