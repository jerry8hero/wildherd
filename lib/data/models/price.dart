// 宠物价格数据模型
class PetPrice {
  final String speciesId;
  final String nameChinese;
  final String nameEnglish;
  final String category;
  final double currentPrice;
  final double priceChange;
  final double minPrice;
  final double maxPrice;
  final DateTime updateTime;
  final String trend;

  PetPrice({
    required this.speciesId,
    required this.nameChinese,
    required this.nameEnglish,
    required this.category,
    required this.currentPrice,
    required this.priceChange,
    required this.minPrice,
    required this.maxPrice,
    required this.updateTime,
    required this.trend,
  });

  // 计算变化百分比
  double get changePercent {
    if (currentPrice == 0) return 0;
    return (priceChange / currentPrice) * 100;
  }

  // 获取趋势图标
  String get trendIcon {
    switch (trend) {
      case 'up':
        return '↑';
      case 'down':
        return '↓';
      default:
        return '→';
    }
  }

  // 获取趋势颜色
  int get trendColorValue {
    switch (trend) {
      case 'up':
        return 0xFF4CAF50; // 绿色上涨
      case 'down':
        return 0xFFE53935; // 红色下跌
      default:
        return 0xFF9E9E9E; // 灰色稳定
    }
  }

  factory PetPrice.fromMap(Map<String, dynamic> map) {
    return PetPrice(
      speciesId: map['species_id'] ?? '',
      nameChinese: map['name_chinese'] ?? '',
      nameEnglish: map['name_english'] ?? '',
      category: map['category'] ?? '',
      currentPrice: (map['current_price'] ?? 0).toDouble(),
      priceChange: (map['price_change'] ?? 0).toDouble(),
      minPrice: (map['min_price'] ?? 0).toDouble(),
      maxPrice: (map['max_price'] ?? 0).toDouble(),
      updateTime: map['update_time'] != null
          ? DateTime.parse(map['update_time'])
          : DateTime.now(),
      trend: map['trend'] ?? 'stable',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'species_id': speciesId,
      'name_chinese': nameChinese,
      'name_english': nameEnglish,
      'category': category,
      'current_price': currentPrice,
      'price_change': priceChange,
      'min_price': minPrice,
      'max_price': maxPrice,
      'update_time': updateTime.toIso8601String(),
      'trend': trend,
    };
  }
}
