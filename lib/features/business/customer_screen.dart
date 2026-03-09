import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wildherd/data/models/business.dart';
import 'package:wildherd/data/repositories/business_repository.dart';

/// 客户管理页面
class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  final _businessRepo = BusinessRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客户管理'),
      ),
      body: FutureBuilder<List<Customer>>(
        future: _businessRepo.getCustomers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!;

          if (customers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无客户', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _buildCustomerCard(customer);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '?',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null)
              Text(customer.phone!, style: TextStyle(color: Colors.grey.shade600)),
            if (customer.wechat != null)
              Text('微信: ${customer.wechat}', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        isThreeLine: customer.phone != null && customer.wechat != null,
        trailing: Text(
          '${customer.purchaseHistory.length}笔',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        onTap: () => _showCustomerDetail(customer),
      ),
    );
  }

  void _showAddCustomerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddCustomerSheet(
        onSave: (customer) async {
          await _businessRepo.addCustomer(customer);
          setState(() {});
        },
      ),
    );
  }

  void _showCustomerDetail(Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (customer.phone != null)
              _buildDetailRow(Icons.phone, '电话', customer.phone!),
            if (customer.wechat != null)
              _buildDetailRow(Icons.wechat, '微信', customer.wechat!),
            if (customer.address != null)
              _buildDetailRow(Icons.location_on, '地址', customer.address!),
            if (customer.notes != null)
              _buildDetailRow(Icons.note, '备注', customer.notes!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditCustomerDialog(customer);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('编辑'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 查看购买历史
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('购买记录'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddCustomerSheet(
        customer: customer,
        onSave: (updated) async {
          await _businessRepo.updateCustomer(updated);
          setState(() {});
        },
      ),
    );
  }
}

/// 添加/编辑客户弹窗
class _AddCustomerSheet extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSave;

  const _AddCustomerSheet({this.customer, required this.onSave});

  @override
  State<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<_AddCustomerSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wechatController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _wechatController.text = widget.customer!.wechat ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _notesController.text = widget.customer!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wechatController.dispose();
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
            Text(
              isEdit ? '编辑客户' : '添加客户',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名/昵称 *',
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
              controller: _wechatController,
              decoration: const InputDecoration(
                labelText: '微信',
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
        const SnackBar(content: Text('请填写姓名')),
      );
      return;
    }

    final customer = Customer(
      id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      wechat: _wechatController.text.isEmpty ? null : _wechatController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      purchaseHistory: widget.customer?.purchaseHistory ?? [],
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    widget.onSave(customer);
    Navigator.pop(context);
  }
}
