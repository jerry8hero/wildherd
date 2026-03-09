import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wildherd/data/models/business.dart';
import 'package:wildherd/data/repositories/business_repository.dart';

/// 库存管理页面
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _businessRepo = BusinessRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('库存管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '活体'),
            Tab(text: '消耗品'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReptileInventoryTab(businessRepo: _businessRepo),
          _SupplyInventoryTab(businessRepo: _businessRepo),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddReptileDialog();
          } else {
            _showAddSupplyDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddReptileDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddReptileSheet(
        onSave: (reptile) async {
          await _businessRepo.addInventoryReptile(reptile);
          setState(() {});
        },
      ),
    );
  }

  void _showAddSupplyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSupplySheet(
        onSave: (supply) async {
          await _businessRepo.addInventorySupply(supply);
          setState(() {});
        },
      ),
    );
  }
}

/// 活体库存 Tab
class _ReptileInventoryTab extends StatelessWidget {
  final BusinessRepository businessRepo;

  const _ReptileInventoryTab({required this.businessRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InventoryReptile>>(
      future: businessRepo.getInventoryReptiles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reptiles = snapshot.data!;

        if (reptiles.isEmpty) {
          return const Center(
            child: Text('暂无活体库存'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reptiles.length,
          itemBuilder: (context, index) {
            final reptile = reptiles[index];
            return _buildReptileCard(context, reptile);
          },
        );
      },
    );
  }

  Widget _buildReptileCard(BuildContext context, InventoryReptile reptile) {
    final statusName = InventoryStatus.getStatusName(reptile.status);
    final sourceName = SourceType.getSourceName(reptile.source);

    Color statusColor;
    switch (reptile.status) {
      case InventoryStatus.inStock:
        statusColor = Colors.green;
        break;
      case InventoryStatus.sold:
        statusColor = Colors.grey;
        break;
      case InventoryStatus.reserved:
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reptile.species,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (reptile.morph != null) ...[
              const SizedBox(height: 4),
              Text(
                reptile.morph!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('体重', '${reptile.weight}g'),
                const SizedBox(width: 12),
                if (reptile.length != null)
                  _buildInfoChip('体长', '${reptile.length}cm'),
                const SizedBox(width: 12),
                _buildInfoChip('来源', sourceName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (reptile.purchasePrice != null)
                  Text(
                    '采购: ¥${reptile.purchasePrice}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                const Spacer(),
                if (reptile.sellPrice != null)
                  Text(
                    '售价: ¥${reptile.sellPrice}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// 消耗品库存 Tab
class _SupplyInventoryTab extends StatelessWidget {
  final BusinessRepository businessRepo;

  const _SupplyInventoryTab({required this.businessRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InventorySupply>>(
      future: businessRepo.getInventorySupplies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final supplies = snapshot.data!;

        if (supplies.isEmpty) {
          return const Center(
            child: Text('暂无消耗品库存'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: supplies.length,
          itemBuilder: (context, index) {
            final supply = supplies[index];
            return _buildSupplyCard(context, supply);
          },
        );
      },
    );
  }

  Widget _buildSupplyCard(BuildContext context, InventorySupply supply) {
    final categoryName = SupplyCategory.getCategoryName(supply.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.inventory_2, color: Colors.blue),
        ),
        title: Text(supply.name),
        subtitle: Text(
          '$categoryName | 库存: ${supply.quantity} ${supply.unit}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: supply.price != null
            ? Text(
                '¥${supply.price}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }
}

/// 添加活体弹窗
class _AddReptileSheet extends StatefulWidget {
  final Function(InventoryReptile) onSave;

  const _AddReptileSheet({required this.onSave});

  @override
  State<_AddReptileSheet> createState() => _AddReptileSheetState();
}

class _AddReptileSheetState extends State<_AddReptileSheet> {
  final _speciesController = TextEditingController();
  final _morphController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellPriceController = TextEditingController();

  String _source = SourceType.purchase;

  @override
  void dispose() {
    _speciesController.dispose();
    _morphController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _purchasePriceController.dispose();
    _sellPriceController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '添加活体',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: '品种 *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _morphController,
              decoration: const InputDecoration(
                labelText: '变异/基因',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '体重(g) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '体长(cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _source,
              decoration: const InputDecoration(
                labelText: '来源',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: SourceType.purchase, child: Text('外购')),
                DropdownMenuItem(value: SourceType.self, child: Text('自繁')),
              ],
              onChanged: (value) {
                setState(() {
                  _source = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _purchasePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '采购价',
                      prefixText: '¥ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _sellPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '售价',
                      prefixText: '¥ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }

  void _save() {
    if (_speciesController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写必填项')),
      );
      return;
    }

    final reptile = InventoryReptile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      species: _speciesController.text,
      morph: _morphController.text.isEmpty ? null : _morphController.text,
      weight: double.tryParse(_weightController.text) ?? 0,
      length: double.tryParse(_lengthController.text),
      source: _source,
      purchasePrice: double.tryParse(_purchasePriceController.text),
      sellPrice: double.tryParse(_sellPriceController.text),
      status: InventoryStatus.inStock,
      createdAt: DateTime.now(),
    );

    widget.onSave(reptile);
    Navigator.pop(context);
  }
}

/// 添加消耗品弹窗
class _AddSupplySheet extends StatefulWidget {
  final Function(InventorySupply) onSave;

  const _AddSupplySheet({required this.onSave});

  @override
  State<_AddSupplySheet> createState() => _AddSupplySheetState();
}

class _AddSupplySheetState extends State<_AddSupplySheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();

  String _category = SupplyCategory.feed;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _unitController.dispose();
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
            '添加消耗品',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '名称 *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: '类别',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: SupplyCategory.feed, child: Text('龟粮')),
              DropdownMenuItem(value: SupplyCategory.supplement, child: Text('添加剂')),
              DropdownMenuItem(value: SupplyCategory.substrate, child: Text('垫材')),
              DropdownMenuItem(value: SupplyCategory.other, child: Text('其他')),
            ],
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '数量 *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: '单位 *',
                    hintText: '袋/盒/斤',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '单价',
              prefixText: '¥ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty || _unitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写必填项')),
      );
      return;
    }

    final supply = InventorySupply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      category: _category,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unit: _unitController.text,
      price: double.tryParse(_priceController.text),
    );

    widget.onSave(supply);
    Navigator.pop(context);
  }
}
