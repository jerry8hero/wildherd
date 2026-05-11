class FeedingReminder {
  final String id;
  final String reptileId;
  final String reptileName;
  final String foodType;
  final int intervalDays;
  final int feedTimeHour;
  final int feedTimeMinute;
  final bool enabled;
  final DateTime? lastTriggered;
  final DateTime createdAt;

  const FeedingReminder({
    required this.id,
    required this.reptileId,
    required this.reptileName,
    required this.foodType,
    required this.intervalDays,
    required this.feedTimeHour,
    required this.feedTimeMinute,
    this.enabled = true,
    this.lastTriggered,
    required this.createdAt,
  });

  factory FeedingReminder.fromMap(Map<String, dynamic> map) {
    return FeedingReminder(
      id: map['id'] as String,
      reptileId: map['reptile_id'] as String,
      reptileName: map['reptile_name'] as String,
      foodType: map['food_type'] as String,
      intervalDays: map['interval_days'] as int,
      feedTimeHour: map['feed_time_hour'] as int,
      feedTimeMinute: map['feed_time_minute'] as int,
      enabled: (map['enabled'] as int) == 1,
      lastTriggered: map['last_triggered'] != null
          ? DateTime.parse(map['last_triggered'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'reptile_name': reptileName,
      'food_type': foodType,
      'interval_days': intervalDays,
      'feed_time_hour': feedTimeHour,
      'feed_time_minute': feedTimeMinute,
      'enabled': enabled ? 1 : 0,
      'last_triggered': lastTriggered?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  FeedingReminder copyWith({
    bool? enabled,
    DateTime? lastTriggered,
  }) {
    return FeedingReminder(
      id: id,
      reptileId: reptileId,
      reptileName: reptileName,
      foodType: foodType,
      intervalDays: intervalDays,
      feedTimeHour: feedTimeHour,
      feedTimeMinute: feedTimeMinute,
      enabled: enabled ?? this.enabled,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      createdAt: createdAt,
    );
  }
}
