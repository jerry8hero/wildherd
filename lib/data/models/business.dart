/// 商业数据模型
/// 用于爬宠副业管理的财务、库存、客户、供应商等功能

/// 财务记录类型
class FinanceRecord {
  final String id;
  final String type; // income / expense
  final String category; // 类别
  final double amount; // 金额
  final String? reptileId; // 关联爬宠（可选）
  final String? description; // 备注
  final DateTime date;

  FinanceRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.reptileId,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'category': category,
        'amount': amount,
        'reptileId': reptileId,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory FinanceRecord.fromJson(Map<String, dynamic> json) => FinanceRecord(
        id: json['id'],
        type: json['type'],
        category: json['category'],
        amount: (json['amount'] as num).toDouble(),
        reptileId: json['reptileId'],
        description: json['description'],
        date: DateTime.parse(json['date']),
      );

  FinanceRecord copyWith({
    String? id,
    String? type,
    String? category,
    double? amount,
    String? reptileId,
    String? description,
    DateTime? date,
  }) {
    return FinanceRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      reptileId: reptileId ?? this.reptileId,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

/// 财务类别常量
class FinanceCategory {
  // 收入类别
  static const String saleReptile = 'sale_reptile'; // 卖爬宠
  static const String saleOffspring = 'sale_offspring'; // 卖苗子
  static const String saleEquipment = 'sale_equipment'; // 卖器材

  // 支出类别
  static const String feed = 'feed'; // 饲料
  static const String equipment = 'equipment'; // 器材
  static const String electricity = 'electricity'; // 电费
  static const String rent = 'rent'; // 租金
  static const String medicine = 'medicine'; // 药品
  static const String purchase = 'purchase'; // 采购
  static const String other = 'other'; // 其他

  static const List<String> incomeCategories = [
    saleReptile,
    saleOffspring,
    saleEquipment,
  ];

  static const List<String> expenseCategories = [
    feed,
    equipment,
    electricity,
    rent,
    medicine,
    purchase,
    other,
  ];

  static String getCategoryName(String category) {
    switch (category) {
      case saleReptile:
        return '卖爬宠';
      case saleOffspring:
        return '卖苗子';
      case saleEquipment:
        return '卖器材';
      case feed:
        return '饲料';
      case equipment:
        return '器材';
      case electricity:
        return '电费';
      case rent:
        return '租金';
      case medicine:
        return '药品';
      case purchase:
        return '采购';
      case other:
        return '其他';
      default:
        return category;
    }
  }
}

/// 库存 - 活体
class InventoryReptile {
  final String id;
  final String species; // 品种
  final String? morph; // 变异/基因
  final double weight; // 体重(g)
  final double? length; // 体长(cm)
  final String source; // 来源: self(自繁), purchase(外购)
  final double? purchasePrice; // 采购价
  final double? sellPrice; // 售价
  final String status; // in_stock(在售), sold(已售), reserved(预留)
  final DateTime? saleDate; // 出售日期
  final String? customerId; // 买家ID
  final String? notes; // 备注
  final DateTime createdAt;

  InventoryReptile({
    required this.id,
    required this.species,
    this.morph,
    required this.weight,
    this.length,
    required this.source,
    this.purchasePrice,
    this.sellPrice,
    required this.status,
    this.saleDate,
    this.customerId,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'species': species,
        'morph': morph,
        'weight': weight,
        'length': length,
        'source': source,
        'purchasePrice': purchasePrice,
        'sellPrice': sellPrice,
        'status': status,
        'saleDate': saleDate?.toIso8601String(),
        'customerId': customerId,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory InventoryReptile.fromJson(Map<String, dynamic> json) =>
      InventoryReptile(
        id: json['id'],
        species: json['species'],
        morph: json['morph'],
        weight: (json['weight'] as num).toDouble(),
        length: json['length'] != null ? (json['length'] as num).toDouble() : null,
        source: json['source'],
        purchasePrice: json['purchasePrice'] != null
            ? (json['purchasePrice'] as num).toDouble()
            : null,
        sellPrice: json['sellPrice'] != null
            ? (json['sellPrice'] as num).toDouble()
            : null,
        status: json['status'],
        saleDate:
            json['saleDate'] != null ? DateTime.parse(json['saleDate']) : null,
        customerId: json['customerId'],
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  InventoryReptile copyWith({
    String? id,
    String? species,
    String? morph,
    double? weight,
    double? length,
    String? source,
    double? purchasePrice,
    double? sellPrice,
    String? status,
    DateTime? saleDate,
    String? customerId,
    String? notes,
    DateTime? createdAt,
  }) {
    return InventoryReptile(
      id: id ?? this.id,
      species: species ?? this.species,
      morph: morph ?? this.morph,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      source: source ?? this.source,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellPrice: sellPrice ?? this.sellPrice,
      status: status ?? this.status,
      saleDate: saleDate ?? this.saleDate,
      customerId: customerId ?? this.customerId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 库存状态常量
class InventoryStatus {
  static const String inStock = 'in_stock';
  static const String sold = 'sold';
  static const String reserved = 'reserved';

  static String getStatusName(String status) {
    switch (status) {
      case inStock:
        return '在售';
      case sold:
        return '已售';
      case reserved:
        return '预留';
      default:
        return status;
    }
  }
}

/// 来源类型常量
class SourceType {
  static const String self = 'self';
  static const String purchase = 'purchase';

  static String getSourceName(String source) {
    switch (source) {
      case self:
        return '自繁';
      case purchase:
        return '外购';
      default:
        return source;
    }
  }
}

/// 库存 - 消耗品
class InventorySupply {
  final String id;
  final String name; // 名称
  final String category; // 类别: feed(龟粮), supplement(添加剂), substrate(垫材)
  final double quantity; // 数量
  final String unit; // 单位: 袋, 盒, 斤
  final double? price; // 单价
  final DateTime? expiryDate; // 过期日期
  final String? notes; // 备注

  InventorySupply({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.price,
    this.expiryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'expiryDate': expiryDate?.toIso8601String(),
        'notes': notes,
      };

  factory InventorySupply.fromJson(Map<String, dynamic> json) => InventorySupply(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'],
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        notes: json['notes'],
      );

  InventorySupply copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? price,
    DateTime? expiryDate,
    String? notes,
  }) {
    return InventorySupply(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
    );
  }
}

/// 消耗品类别常量
class SupplyCategory {
  static const String feed = 'feed';
  static const String supplement = 'supplement';
  static const String substrate = 'substrate';
  static const String other = 'other';

  static String getCategoryName(String category) {
    switch (category) {
      case feed:
        return '龟粮';
      case supplement:
        return '添加剂';
      case substrate:
        return '垫材';
      case other:
        return '其他';
      default:
        return category;
    }
  }
}

/// 客户
class Customer {
  final String id;
  final String name; // 姓名/昵称
  final String? phone; // 电话
  final String? wechat; // 微信
  final String? address; // 地址
  final List<String> purchaseHistory; // 购买记录IDs
  final String? notes; // 备注
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.wechat,
    this.address,
    this.purchaseHistory = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'wechat': wechat,
        'address': address,
        'purchaseHistory': purchaseHistory,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        wechat: json['wechat'],
        address: json['address'],
        purchaseHistory: List<String>.from(json['purchaseHistory'] ?? []),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? wechat,
    String? address,
    List<String>? purchaseHistory,
    String? notes,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      wechat: wechat ?? this.wechat,
      address: address ?? this.address,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 供应商
class Supplier {
  final String id;
  final String name; // 名称
  final String? contact; // 联系人
  final String? phone;
  final String? address;
  final List<String> purchaseRecords; // 采购记录IDs
  final String? notes; // 备注

  Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.phone,
    this.address,
    this.purchaseRecords = const [],
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'phone': phone,
        'address': address,
        'purchaseRecords': purchaseRecords,
        'notes': notes,
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'],
        name: json['name'],
        contact: json['contact'],
        phone: json['phone'],
        address: json['address'],
        purchaseRecords: List<String>.from(json['purchaseRecords'] ?? []),
        notes: json['notes'],
      );

  Supplier copyWith({
    String? id,
    String? name,
    String? contact,
    String? phone,
    String? address,
    List<String>? purchaseRecords,
    String? notes,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      purchaseRecords: purchaseRecords ?? this.purchaseRecords,
      notes: notes ?? this.notes,
    );
  }
}

/// 采购记录
class PurchaseRecord {
  final String id;
  final String supplierId;
  final String species; // 品种
  final int quantity; // 数量
  final double totalPrice; // 总价
  final DateTime date;
  final String? notes;

  PurchaseRecord({
    required this.id,
    required this.supplierId,
    required this.species,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplierId': supplierId,
        'species': species,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
        id: json['id'],
        supplierId: json['supplierId'],
        species: json['species'],
        quantity: json['quantity'],
        totalPrice: (json['totalPrice'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        notes: json['notes'],
      );

  PurchaseRecord copyWith({
    String? id,
    String? supplierId,
    String? species,
    int? quantity,
    double? totalPrice,
    DateTime? date,
    String? notes,
  }) {
    return PurchaseRecord(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      species: species ?? this.species,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

/// 销售订单
class SalesOrder {
  final String id;
  final String customerId;
  final List<String> reptileIds; // 销售的爬宠ID列表
  final double totalAmount; // 总金额
  final String status; // pending(待处理), shipped(已发货), completed(已完成), cancelled(已取消)
  final DateTime saleDate;
  final String? shippingMethod; // 物流方式
  final String? trackingNumber; // 快递单号
  final String? notes;

  SalesOrder({
    required this.id,
    required this.customerId,
    required this.reptileIds,
    required this.totalAmount,
    required this.status,
    required this.saleDate,
    this.shippingMethod,
    this.trackingNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'reptileIds': reptileIds,
        'totalAmount': totalAmount,
        'status': status,
        'saleDate': saleDate.toIso8601String(),
        'shippingMethod': shippingMethod,
        'trackingNumber': trackingNumber,
        'notes': notes,
      };

  factory SalesOrder.fromJson(Map<String, dynamic> json) => SalesOrder(
        id: json['id'],
        customerId: json['customerId'],
        reptileIds: List<String>.from(json['reptileIds']),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'],
        saleDate: DateTime.parse(json['saleDate']),
        shippingMethod: json['shippingMethod'],
        trackingNumber: json['trackingNumber'],
        notes: json['notes'],
      );

  SalesOrder copyWith({
    String? id,
    String? customerId,
    List<String>? reptileIds,
    double? totalAmount,
    String? status,
    DateTime? saleDate,
    String? shippingMethod,
    String? trackingNumber,
    String? notes,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      reptileIds: reptileIds ?? this.reptileIds,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      saleDate: saleDate ?? this.saleDate,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
}

/// 订单状态常量
class OrderStatus {
  static const String pending = 'pending';
  static const String shipped = 'shipped';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static String getStatusName(String status) {
    switch (status) {
      case pending:
        return '待处理';
      case shipped:
        return '已发货';
      case completed:
        return '已完成';
      case cancelled:
        return '已取消';
      default:
        return status;
    }
  }
}

/// 经营统计数据
class BusinessStats {
  final double totalIncome; // 总收入
  final double totalExpense; // 总支出
  final double profit; // 利润
  final int reptileCount; // 在售活体数量
  final int pendingOrders; // 待处理订单数
  final int customerCount; // 客户数量

  BusinessStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.reptileCount,
    required this.pendingOrders,
    required this.customerCount,
  });
}
