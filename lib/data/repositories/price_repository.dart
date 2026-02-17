import '../models/price.dart';

class PriceRepository {
  // 模拟价格数据
  final List<PetPrice> _mockPrices = [
    PetPrice(
      speciesId: '1',
      nameChinese: '玉米蛇',
      nameEnglish: 'Corn Snake',
      category: 'snake',
      currentPrice: 220,
      priceChange: 10,
      minPrice: 150,
      maxPrice: 300,
      updateTime: DateTime.now().subtract(const Duration(hours: 2)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '6',
      nameChinese: '球蟒',
      nameEnglish: 'Ball Python',
      category: 'snake',
      currentPrice: 550,
      priceChange: 50,
      minPrice: 300,
      maxPrice: 800,
      updateTime: DateTime.now().subtract(const Duration(hours: 5)),
      trend: 'up',
    ),
    PetPrice(
      speciesId: '3',
      nameChinese: '豹纹守宫',
      nameEnglish: 'Leopard Gecko',
      category: 'gecko',
      currentPrice: 120,
      priceChange: -15,
      minPrice: 80,
      maxPrice: 200,
      updateTime: DateTime.now().subtract(const Duration(hours: 1)),
      trend: 'down',
    ),
    PetPrice(
      speciesId: '2',
      nameChinese: '睫角守宫',
      nameEnglish: 'Crested Gecko',
      category: 'gecko',
      currentPrice: 280,
      priceChange: 30,
      minPrice: 150,
      maxPrice: 350,
      updateTime: DateTime.now().subtract(const Duration(hours: 3)),
      trend: 'up',
    ),
    PetPrice(
      speciesId: '11',
      nameChinese: '鬃狮蜥',
      nameEnglish: 'Bearded Dragon',
      category: 'lizard',
      currentPrice: 350,
      priceChange: 0,
      minPrice: 200,
      maxPrice: 500,
      updateTime: DateTime.now().subtract(const Duration(hours: 6)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '10',
      nameChinese: '绿鬣蜥',
      nameEnglish: 'Green Iguana',
      category: 'lizard',
      currentPrice: 280,
      priceChange: -20,
      minPrice: 150,
      maxPrice: 400,
      updateTime: DateTime.now().subtract(const Duration(hours: 8)),
      trend: 'down',
    ),
    PetPrice(
      speciesId: '12',
      nameChinese: '红耳龟',
      nameEnglish: 'Red-eared Slider',
      category: 'turtle',
      currentPrice: 35,
      priceChange: -5,
      minPrice: 20,
      maxPrice: 50,
      updateTime: DateTime.now().subtract(const Duration(hours: 4)),
      trend: 'down',
    ),
    PetPrice(
      speciesId: '64',
      nameChinese: '独角仙',
      nameEnglish: 'Japanese Beetle',
      category: 'insect',
      currentPrice: 55,
      priceChange: 5,
      minPrice: 30,
      maxPrice: 80,
      updateTime: DateTime.now().subtract(const Duration(hours: 12)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '69',
      nameChinese: '仓鼠',
      nameEnglish: 'Hamster',
      category: 'mammal',
      currentPrice: 20,
      priceChange: 0,
      minPrice: 10,
      maxPrice: 30,
      updateTime: DateTime.now().subtract(const Duration(hours: 2)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '75',
      nameChinese: '虎皮鹦鹉',
      nameEnglish: 'Budgerigar',
      category: 'bird',
      currentPrice: 55,
      priceChange: 5,
      minPrice: 30,
      maxPrice: 80,
      updateTime: DateTime.now().subtract(const Duration(hours: 7)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '80',
      nameChinese: '金鱼',
      nameEnglish: 'Goldfish',
      category: 'fish',
      currentPrice: 15,
      priceChange: 0,
      minPrice: 5,
      maxPrice: 30,
      updateTime: DateTime.now().subtract(const Duration(hours: 1)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '82',
      nameChinese: '孔雀鱼',
      nameEnglish: 'Guppy',
      category: 'fish',
      currentPrice: 8,
      priceChange: -2,
      minPrice: 3,
      maxPrice: 15,
      updateTime: DateTime.now().subtract(const Duration(hours: 3)),
      trend: 'down',
    ),
    PetPrice(
      speciesId: '70',
      nameChinese: '兔子',
      nameEnglish: 'Rabbit',
      category: 'mammal',
      currentPrice: 150,
      priceChange: 10,
      minPrice: 80,
      maxPrice: 300,
      updateTime: DateTime.now().subtract(const Duration(hours: 5)),
      trend: 'stable',
    ),
    PetPrice(
      speciesId: '84',
      nameChinese: '龙鱼',
      nameEnglish: 'Arowana',
      category: 'fish',
      currentPrice: 2800,
      priceChange: 200,
      minPrice: 1500,
      maxPrice: 5000,
      updateTime: DateTime.now().subtract(const Duration(hours: 10)),
      trend: 'up',
    ),
  ];

  // 获取所有价格数据
  Future<List<PetPrice>> getAllPrices() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrices;
  }

  // 按类别获取价格
  Future<List<PetPrice>> getPricesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (category == 'all') {
      return _mockPrices;
    }
    return _mockPrices.where((p) => p.category == category).toList();
  }

  // 搜索价格
  Future<List<PetPrice>> searchPrices(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final kw = keyword.toLowerCase();
    return _mockPrices.where((p) =>
      p.nameChinese.toLowerCase().contains(kw) ||
      p.nameEnglish.toLowerCase().contains(kw)
    ).toList();
  }

  // 获取上涨的物种
  Future<List<PetPrice>> getRisingPrices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockPrices.where((p) => p.trend == 'up').toList();
  }

  // 获取下跌的物种
  Future<List<PetPrice>> getFallingPrices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockPrices.where((p) => p.trend == 'down').toList();
  }

  // 获取热门物种（价格较高的）
  Future<List<PetPrice>> getHotPrices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final sorted = List<PetPrice>.from(_mockPrices)
      ..sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
    return sorted.take(5).toList();
  }
}
