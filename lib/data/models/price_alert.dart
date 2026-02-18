// 降价提醒数据模型
class PriceAlert {
  final String id;
  final String speciesId;
  final String speciesName;
  final String speciesNameEnglish;
  final double targetPrice;
  final String alertType; // custom: 自定义目标价, lowest: 历史最低价
  final bool isEnabled;
  final DateTime createdAt;
  final double? currentPrice; // 当前价格（用于展示）
  final double? lowestPrice; // 历史最低价（用于展示）

  PriceAlert({
    required this.id,
    required this.speciesId,
    required this.speciesName,
    required this.speciesNameEnglish,
    required this.targetPrice,
    required this.alertType,
    required this.isEnabled,
    required this.createdAt,
    this.currentPrice,
    this.lowestPrice,
  });

  // 提醒类型描述
  String get alertTypeText {
    switch (alertType) {
      case 'custom':
        return '自定义价格';
      case 'lowest':
        return '历史最低价';
      default:
        return '未知';
    }
  }

  // 是否达到提醒条件
  bool get isTriggered {
    if (!isEnabled) return false;
    if (currentPrice == null) return false;

    if (alertType == 'lowest') {
      // 历史最低价模式：当前价格 <= 历史最低价
      return lowestPrice != null && currentPrice! <= lowestPrice!;
    } else {
      // 自定义价格模式：当前价格 <= 目标价格
      return currentPrice! <= targetPrice;
    }
  }

  // 距离目标的差价
  double? get priceDiff {
    if (currentPrice == null) return null;
    return currentPrice! - targetPrice;
  }

  // 差价百分比
  double? get priceDiffPercent {
    if (currentPrice == null || targetPrice == 0) return null;
    return (priceDiff! / targetPrice) * 100;
  }

  factory PriceAlert.fromMap(Map<String, dynamic> map) {
    return PriceAlert(
      id: map['id'] ?? '',
      speciesId: map['species_id'] ?? '',
      speciesName: map['species_name'] ?? '',
      speciesNameEnglish: map['species_name_english'] ?? '',
      targetPrice: (map['target_price'] ?? 0).toDouble(),
      alertType: map['alert_type'] ?? 'custom',
      isEnabled: map['is_enabled'] == 1 || map['is_enabled'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      currentPrice: map['current_price']?.toDouble(),
      lowestPrice: map['lowest_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_id': speciesId,
      'species_name': speciesName,
      'species_name_english': speciesNameEnglish,
      'target_price': targetPrice,
      'alert_type': alertType,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PriceAlert copyWith({
    String? id,
    String? speciesId,
    String? speciesName,
    String? speciesNameEnglish,
    double? targetPrice,
    String? alertType,
    bool? isEnabled,
    DateTime? createdAt,
    double? currentPrice,
    double? lowestPrice,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      speciesName: speciesName ?? this.speciesName,
      speciesNameEnglish: speciesNameEnglish ?? this.speciesNameEnglish,
      targetPrice: targetPrice ?? this.targetPrice,
      alertType: alertType ?? this.alertType,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      currentPrice: currentPrice ?? this.currentPrice,
      lowestPrice: lowestPrice ?? this.lowestPrice,
    );
  }
}
