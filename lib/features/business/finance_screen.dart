import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wildherd/data/models/business.dart';
import 'package:wildherd/data/repositories/business_repository.dart';

/// 财务管理页面
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _businessRepo = BusinessRepository();

  String? _selectedType; // income / expense
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('财务管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '收入'),
            Tab(text: '支出'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedType = null;
                  break;
                case 1:
                  _selectedType = 'income';
                  break;
                case 2:
                  _selectedType = 'expense';
                  break;
              }
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showProfitAnalysis(),
            tooltip: '盈亏分析',
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计卡片
          _buildStatsCard(),
          // 筛选
          _buildFilterBar(),
          // 记录列表
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCard() {
    return FutureBuilder<Map<String, double>>(
      future: _businessRepo.getFinanceStats(),
      builder: (context, snapshot) {
        final income = snapshot.data?['income'] ?? 0.0;
        final expense = snapshot.data?['expense'] ?? 0.0;
        final profit = income - expense;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('收入', income, Colors.green),
              _buildStatItem('支出', expense, Colors.red),
              _buildStatItem('利润', profit, profit >= 0 ? Colors.blue : Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('全部', null),
          if (_selectedType == 'income') ...[
            _buildFilterChip('卖爬宠', FinanceCategory.saleReptile),
            _buildFilterChip('卖苗子', FinanceCategory.saleOffspring),
            _buildFilterChip('卖器材', FinanceCategory.saleEquipment),
          ],
          if (_selectedType == 'expense') ...[
            _buildFilterChip('饲料', FinanceCategory.feed),
            _buildFilterChip('器材', FinanceCategory.equipment),
            _buildFilterChip('电费', FinanceCategory.electricity),
            _buildFilterChip('租金', FinanceCategory.rent),
            _buildFilterChip('药品', FinanceCategory.medicine),
            _buildFilterChip('采购', FinanceCategory.purchase),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  Widget _buildRecordList() {
    return FutureBuilder<List<FinanceRecord>>(
      future: _businessRepo.getFinanceRecords(type: _selectedType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var records = snapshot.data!;

        // 筛选类别
        if (_selectedCategory != null) {
          records = records.where((r) => r.category == _selectedCategory).toList();
        }

        if (records.isEmpty) {
          return const Center(
            child: Text('暂无记录'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildRecordItem(record);
          },
        );
      },
    );
  }

  Widget _buildRecordItem(FinanceRecord record) {
    final isIncome = record.type == 'income';
    final categoryName = FinanceCategory.getCategoryName(record.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(categoryName),
        subtitle: Text(
          '${record.date.month}/${record.date.day} ${record.description ?? ''}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}¥${record.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onLongPress: () => _showDeleteDialog(record),
      ),
    );
  }

  void _showAddRecordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddRecordSheet(
        onSave: (record) async {
          await _businessRepo.addFinanceRecord(record);
          setState(() {});
        },
      ),
    );
  }

  void _showDeleteDialog(FinanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _businessRepo.deleteFinanceRecord(record.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示盈亏分析弹窗
  void _showProfitAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProfitAnalysisSheet(businessRepo: _businessRepo),
    );
  }
}

/// 添加记录弹窗
class _AddRecordSheet extends StatefulWidget {
  final Function(FinanceRecord) onSave;

  const _AddRecordSheet({required this.onSave});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  String _type = 'expense';
  String _category = FinanceCategory.feed;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加记录',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 类型选择
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('支出'),
                  selected: _type == 'expense',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _type = 'expense';
                        _category = FinanceCategory.feed;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('收入'),
                  selected: _type == 'income',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _type = 'income';
                        _category = FinanceCategory.saleReptile;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 类别选择
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: '类别',
              border: OutlineInputBorder(),
            ),
            items: (_type == 'income'
                    ? FinanceCategory.incomeCategories
                    : FinanceCategory.expenseCategories)
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(FinanceCategory.getCategoryName(c)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          // 金额
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '金额',
              prefixText: '¥ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // 备注
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: '备注（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    final record = FinanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      category: _category,
      amount: amount,
      description: _descController.text.isEmpty ? null : _descController.text,
      date: DateTime.now(),
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}

/// 盈亏分析弹窗
class _ProfitAnalysisSheet extends StatefulWidget {
  final BusinessRepository businessRepo;

  const _ProfitAnalysisSheet({required this.businessRepo});

  @override
  State<_ProfitAnalysisSheet> createState() => _ProfitAnalysisSheetState();
}

class _ProfitAnalysisSheetState extends State<_ProfitAnalysisSheet> {
  final _avgPriceController = TextEditingController(text: '50'); // 默认龟苗售价

  @override
  void dispose() {
    _avgPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // 拖动条
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                '养殖盈亏分析',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '记录饲养成本，预测扭亏为盈时间',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // 累计成本统计
              _buildCostAnalysis(),
              const SizedBox(height: 24),

              // 龟苗售价设置
              _buildPriceSetting(),
              const SizedBox(height: 24),

              // 盈亏预测
              _buildProfitForecast(),
            ],
          ),
        );
      },
    );
  }

  /// 构建成本分析卡片
  Widget _buildCostAnalysis() {
    return FutureBuilder<Map<String, double>>(
      future: widget.businessRepo.getFinanceStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'income': 0.0, 'expense': 0.0, 'profit': -0.0};
        final totalExpense = stats['expense'] ?? 0.0;
        final totalIncome = stats['income'] ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.savings, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    '累计饲养成本',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCostItem('饲料', FinanceCategory.feed, totalExpense),
                  _buildCostItem('器材', FinanceCategory.equipment, totalExpense),
                  _buildCostItem('电费', FinanceCategory.electricity, totalExpense),
                  _buildCostItem('其他', null, totalExpense),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('总支出:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '¥${totalExpense.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('总收入:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '¥${totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostItem(String label, String? category, double totalExpense) {
    // 这里简化处理，实际应该按类别统计
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '¥0',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// 龟苗售价设置
  Widget _buildPriceSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                '龟苗售价设置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avgPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '平均每只龟苗售价',
              prefixText: '¥ ',
              border: OutlineInputBorder(),
              helperText: '输入你预期或实际的龟苗平均售价',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  /// 盈亏预测
  Widget _buildProfitForecast() {
    return FutureBuilder<Map<String, double>>(
      future: widget.businessRepo.getFinanceStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'income': 0.0, 'expense': 0.0, 'profit': -0.0};
        final totalExpense = stats['expense'] ?? 0.0;
        final totalIncome = stats['income'] ?? 0.0;
        final avgPrice = double.tryParse(_avgPriceController.text) ?? 0;

        final currentProfit = totalIncome - totalExpense;
        final isProfitable = currentProfit >= 0;

        // 计算需要出售多少苗子
        int needToSell = 0;
        if (avgPrice > 0 && totalExpense > totalIncome) {
          needToSell = ((totalExpense - totalIncome) / avgPrice).ceil();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isProfitable ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isProfitable ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isProfitable ? Icons.check_circle : Icons.trending_up,
                    color: isProfitable ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isProfitable ? '已盈利' : '还在亏损中',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isProfitable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 当前状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('当前盈亏:'),
                  Text(
                    '${isProfitable ? '+' : ''}¥${currentProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isProfitable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!isProfitable && avgPrice > 0) ...[
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  '📊 扭亏为盈预测',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('还需覆盖成本:'),
                          Text(
                            '¥${(totalExpense - totalIncome).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('每只龟苗售价:'),
                          Text(
                            '¥${avgPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '需要出售:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$needToSell 只龟苗',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '💡 提示: 继续记录饲养成本，系统会自动计算还需要出售多少龟苗才能回本',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],

              if (isProfitable) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '恭喜！你已经扭亏为盈啦！继续加油繁殖更多龟苗！',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
