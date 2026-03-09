import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wildherd/data/models/business.dart';
import 'package:wildherd/data/repositories/business_repository.dart';

/// 供应商管理页面
class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});

  @override
  ConsumerState<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen>
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
        title: const Text('供应商管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '供应商'),
            Tab(text: '采购记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SupplierTab(businessRepo: _businessRepo),
          _PurchaseRecordTab(businessRepo: _businessRepo),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddSupplierDialog();
          } else {
            _showAddPurchaseRecordDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSupplierDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSupplierSheet(
        onSave: (supplier) async {
          await _businessRepo.addSupplier(supplier);
          setState(() {});
        },
      ),
    );
  }

  void _showAddPurchaseRecordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddPurchaseRecordSheet(
        businessRepo: _businessRepo,
        onSave: (record) async {
          await _businessRepo.addPurchaseRecord(record);
          setState(() {});
        },
      ),
    );
  }
}

/// 供应商 Tab
class _SupplierTab extends StatelessWidget {
  final BusinessRepository businessRepo;

  const _SupplierTab({required this.businessRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Supplier>>(
      future: businessRepo.getSuppliers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suppliers = snapshot.data!;

        if (suppliers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无供应商', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.local_shipping, color: Colors.purple),
                ),
                title: Text(supplier.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (supplier.contact != null)
                      Text('联系人: ${supplier.contact}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    if (supplier.phone != null)
                      Text('电话: ${supplier.phone}',
                          style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                isThreeLine: supplier.contact != null && supplier.phone != null,
              ),
            );
          },
        );
      },
    );
  }
}

/// 采购记录 Tab
class _PurchaseRecordTab extends StatelessWidget {
  final BusinessRepository businessRepo;

  const _PurchaseRecordTab({required this.businessRepo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PurchaseRecord>>(
      future: businessRepo.getPurchaseRecords(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data!;

        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无采购记录', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: const Icon(Icons.shopping_cart, color: Colors.orange),
                ),
                title: Text(record.species),
                subtitle: Text(
                  '${record.date.month}/${record.date.day} | 数量: ${record.quantity}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Text(
                  '¥${record.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 添加供应商弹窗
class _AddSupplierSheet extends StatefulWidget {
  final Function(Supplier) onSave;

  const _AddSupplierSheet({required this.onSave});

  @override
  State<_AddSupplierSheet> createState() => _AddSupplierSheetState();
}

class _AddSupplierSheetState extends State<_AddSupplierSheet> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
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
              '添加供应商',
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
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: '联系人',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '电话',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '地址',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '备注',
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
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写供应商名称')),
      );
      return;
    }

    final supplier = Supplier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      contact: _contactController.text.isEmpty ? null : _contactController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.onSave(supplier);
    Navigator.pop(context);
  }
}

/// 添加采购记录弹窗
class _AddPurchaseRecordSheet extends StatefulWidget {
  final BusinessRepository businessRepo;
  final Function(PurchaseRecord) onSave;

  const _AddPurchaseRecordSheet({
    required this.businessRepo,
    required this.onSave,
  });

  @override
  State<_AddPurchaseRecordSheet> createState() => _AddPurchaseRecordSheetState();
}

class _AddPurchaseRecordSheetState extends State<_AddPurchaseRecordSheet> {
  final _speciesController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSupplierId;

  @override
  void dispose() {
    _speciesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
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
              '添加采购记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Supplier>>(
              future: widget.businessRepo.getSuppliers(),
              builder: (context, snapshot) {
                final suppliers = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedSupplierId,
                  decoration: const InputDecoration(
                    labelText: '供应商',
                    border: OutlineInputBorder(),
                  ),
                  items: suppliers
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: '品种 *',
                border: OutlineInputBorder(),
              ),
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
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '总价 *',
                      prefixText: '¥ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '备注',
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
      ),
    );
  }

  void _save() {
    if (_speciesController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写必填项')),
      );
      return;
    }

    final record = PurchaseRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      supplierId: _selectedSupplierId ?? '',
      species: _speciesController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      totalPrice: double.tryParse(_priceController.text) ?? 0,
      date: DateTime.now(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}
