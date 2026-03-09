import 'package:wildherd/data/local/database_helper.dart';
import 'package:wildherd/data/models/business.dart';

/// 商业数据仓库
/// 用于爬宠副业管理的财务、库存、客户、供应商等功能
class BusinessRepository {
  static final BusinessRepository _instance = BusinessRepository._internal();
  factory BusinessRepository() => _instance;
  BusinessRepository._internal();

  final _dbHelper = DatabaseHelper.instance;

  // ========== 财务记录 ==========

  /// 获取财务记录
  Future<List<FinanceRecord>> getFinanceRecords({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _dbHelper.query('finance_records');
    var records = data.map((e) => FinanceRecord.fromJson(e)).toList();

    // 筛选
    if (type != null) {
      records = records.where((r) => r.type == type).toList();
    }
    if (startDate != null) {
      records = records.where((r) => r.date.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      records = records.where((r) => r.date.isBefore(endDate)).toList();
    }

    // 按日期倒序
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  /// 添加财务记录
  Future<void> addFinanceRecord(FinanceRecord record) async {
    await _dbHelper.insert('finance_records', record.toJson());
  }

  /// 删除财务记录
  Future<void> deleteFinanceRecord(String id) async {
    await _dbHelper.delete('finance_records', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取财务统计
  Future<Map<String, double>> getFinanceStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = await getFinanceRecords(
      startDate: startDate,
      endDate: endDate,
    );

    double income = 0;
    double expense = 0;

    for (var record in records) {
      if (record.type == 'income') {
        income += record.amount;
      } else {
        expense += record.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'profit': income - expense,
    };
  }

  // ========== 活体库存 ==========

  /// 获取活体库存
  Future<List<InventoryReptile>> getInventoryReptiles({String? status}) async {
    final data = await _dbHelper.query('inventory_reptiles');
    var reptiles = data.map((e) => InventoryReptile.fromJson(e)).toList();

    if (status != null) {
      reptiles = reptiles.where((r) => r.status == status).toList();
    }

    reptiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reptiles;
  }

  /// 添加活体库存
  Future<void> addInventoryReptile(InventoryReptile reptile) async {
    await _dbHelper.insert('inventory_reptiles', reptile.toJson());
  }

  /// 更新活体库存
  Future<void> updateInventoryReptile(InventoryReptile reptile) async {
    await _dbHelper.update('inventory_reptiles', reptile.toJson(), where: 'id = ?', whereArgs: [reptile.id]);
  }

  /// 删除活体库存
  Future<void> deleteInventoryReptile(String id) async {
    await _dbHelper.delete('inventory_reptiles', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取在售活体数量
  Future<int> getInStockReptileCount() async {
    final reptiles = await getInventoryReptiles(status: InventoryStatus.inStock);
    return reptiles.length;
  }

  // ========== 消耗品库存 ==========

  /// 获取消耗品库存
  Future<List<InventorySupply>> getInventorySupplies({String? category}) async {
    final data = await _dbHelper.query('inventory_supplies');
    var supplies = data.map((e) => InventorySupply.fromJson(e)).toList();

    if (category != null) {
      supplies = supplies.where((s) => s.category == category).toList();
    }

    return supplies;
  }

  /// 添加消耗品库存
  Future<void> addInventorySupply(InventorySupply supply) async {
    await _dbHelper.insert('inventory_supplies', supply.toJson());
  }

  /// 更新消耗品库存
  Future<void> updateInventorySupply(InventorySupply supply) async {
    await _dbHelper.update('inventory_supplies', supply.toJson(), where: 'id = ?', whereArgs: [supply.id]);
  }

  /// 删除消耗品库存
  Future<void> deleteInventorySupply(String id) async {
    await _dbHelper.delete('inventory_supplies', where: 'id = ?', whereArgs: [id]);
  }

  // ========== 客户 ==========

  /// 获取客户列表
  Future<List<Customer>> getCustomers() async {
    final data = await _dbHelper.query('customers');
    var customers = data.map((e) => Customer.fromJson(e)).toList();
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return customers;
  }

  /// 获取客户
  Future<Customer?> getCustomer(String id) async {
    final data = await _dbHelper.queryWhere('customers', where: 'id = ?', whereArgs: [id]);
    if (data.isEmpty) return null;
    return Customer.fromJson(data.first);
  }

  /// 添加客户
  Future<void> addCustomer(Customer customer) async {
    await _dbHelper.insert('customers', customer.toJson());
  }

  /// 更新客户
  Future<void> updateCustomer(Customer customer) async {
    await _dbHelper.update('customers', customer.toJson(), where: 'id = ?', whereArgs: [customer.id]);
  }

  /// 删除客户
  Future<void> deleteCustomer(String id) async {
    await _dbHelper.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取客户数量
  Future<int> getCustomerCount() async {
    final customers = await getCustomers();
    return customers.length;
  }

  // ========== 供应商 ==========

  /// 获取供应商列表
  Future<List<Supplier>> getSuppliers() async {
    final data = await _dbHelper.query('suppliers');
    return data.map((e) => Supplier.fromJson(e)).toList();
  }

  /// 添加供应商
  Future<void> addSupplier(Supplier supplier) async {
    await _dbHelper.insert('suppliers', supplier.toJson());
  }

  /// 更新供应商
  Future<void> updateSupplier(Supplier supplier) async {
    await _dbHelper.update('suppliers', supplier.toJson(), where: 'id = ?', whereArgs: [supplier.id]);
  }

  /// 删除供应商
  Future<void> deleteSupplier(String id) async {
    await _dbHelper.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  // ========== 采购记录 ==========

  /// 获取采购记录
  Future<List<PurchaseRecord>> getPurchaseRecords({String? supplierId}) async {
    final data = await _dbHelper.query('purchase_records');
    var records = data.map((e) => PurchaseRecord.fromJson(e)).toList();

    if (supplierId != null) {
      records = records.where((r) => r.supplierId == supplierId).toList();
    }

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  /// 添加采购记录
  Future<void> addPurchaseRecord(PurchaseRecord record) async {
    await _dbHelper.insert('purchase_records', record.toJson());
  }

  /// 删除采购记录
  Future<void> deletePurchaseRecord(String id) async {
    await _dbHelper.delete('purchase_records', where: 'id = ?', whereArgs: [id]);
  }

  // ========== 销售订单 ==========

  /// 获取销售订单
  Future<List<SalesOrder>> getSalesOrders({String? status}) async {
    final data = await _dbHelper.query('sales_orders');
    var orders = data.map((e) => SalesOrder.fromJson(e)).toList();

    if (status != null) {
      orders = orders.where((o) => o.status == status).toList();
    }

    orders.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return orders;
  }

  /// 获取销售订单
  Future<SalesOrder?> getSalesOrder(String id) async {
    final data = await _dbHelper.queryWhere('sales_orders', where: 'id = ?', whereArgs: [id]);
    if (data.isEmpty) return null;
    return SalesOrder.fromJson(data.first);
  }

  /// 添加销售订单
  Future<void> addSalesOrder(SalesOrder order) async {
    await _dbHelper.insert('sales_orders', order.toJson());
  }

  /// 更新销售订单
  Future<void> updateSalesOrder(SalesOrder order) async {
    await _dbHelper.update('sales_orders', order.toJson(), where: 'id = ?', whereArgs: [order.id]);
  }

  /// 更新订单状态
  Future<void> updateSalesOrderStatus(String id, String status) async {
    final order = await getSalesOrder(id);
    if (order != null) {
      await updateSalesOrder(order.copyWith(status: status));
    }
  }

  /// 删除销售订单
  Future<void> deleteSalesOrder(String id) async {
    await _dbHelper.delete('sales_orders', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取待处理订单数量
  Future<int> getPendingOrderCount() async {
    final orders = await getSalesOrders(status: OrderStatus.pending);
    return orders.length;
  }

  // ========== 经营统计 ==========

  /// 获取经营概览数据
  Future<BusinessStats> getBusinessStats() async {
    final stats = await getFinanceStats();
    final reptileCount = await getInStockReptileCount();
    final pendingOrders = await getPendingOrderCount();
    final customerCount = await getCustomerCount();

    return BusinessStats(
      totalIncome: stats['income'] ?? 0,
      totalExpense: stats['expense'] ?? 0,
      profit: stats['profit'] ?? 0,
      reptileCount: reptileCount,
      pendingOrders: pendingOrders,
      customerCount: customerCount,
    );
  }

  /// 获取本月统计
  Future<Map<String, double>> getMonthlyStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return getFinanceStats(startDate: startOfMonth, endDate: endOfMonth);
  }
}
