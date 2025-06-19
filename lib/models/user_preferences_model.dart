class UserPreferences {
  final int? id;
  final String? userId;
  final String themeMode;
  final bool notificationsEnabled;
  final bool autoBackup;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    this.userId,
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.autoBackup = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'theme_mode': themeMode,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'auto_backup': autoBackup ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      id: map['id']?.toInt(),
      userId: map['user_id'],
      themeMode: map['theme_mode'] ?? 'system',
      notificationsEnabled: (map['notifications_enabled'] ?? 1) == 1,
      autoBackup: (map['auto_backup'] ?? 1) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'theme_mode': themeMode,
      'notifications_enabled': notificationsEnabled,
      'auto_backup': autoBackup,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      themeMode: json['theme_mode'] ?? 'system',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      autoBackup: json['auto_backup'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  UserPreferences copyWith({
    int? id,
    String? userId,
    String? themeMode,
    bool? notificationsEnabled,
    bool? autoBackup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(id: $id, userId: $userId, themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, autoBackup: $autoBackup, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreferences &&
        other.id == id &&
        other.userId == userId &&
        other.themeMode == themeMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.autoBackup == autoBackup &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        themeMode.hashCode ^
        notificationsEnabled.hashCode ^
        autoBackup.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 