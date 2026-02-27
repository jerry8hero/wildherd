import 'package:flutter/material.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';
import '../../utils/gender_utils.dart';
import '../../l10n/generated/app_localizations.dart';

class ReptileAddScreen extends StatefulWidget {
  const ReptileAddScreen({super.key});

  @override
  State<ReptileAddScreen> createState() => _ReptileAddScreenState();
}

class _ReptileAddScreenState extends State<ReptileAddScreen> {
  final ReptileRepository _repository = ReptileRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _speciesChineseController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  DateTime? _selectedAcquisitionDate;
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _speciesChineseController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedAcquisitionDate = picked;
        }
      });
    }
  }

  Future<void> _saveReptile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final reptile = Reptile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        speciesChinese: _speciesChineseController.text.trim().isEmpty
            ? null
            : _speciesChineseController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        acquisitionDate: _selectedAcquisitionDate,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        length: _lengthController.text.isNotEmpty
            ? double.tryParse(_lengthController.text)
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addReptile(reptile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加成功')),
        );
        Navigator.pop(context, true); // 返回 true 表示添加成功
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addPet),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 名字
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.petName,
                prefixIcon: const Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入宠物名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 物种（英文）
            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: '物种 (英文)',
                prefixIcon: Icon(Icons.category),
                hintText: '例如: Ball Python',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入物种';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 物种（中文）
            TextFormField(
              controller: _speciesChineseController,
              decoration: const InputDecoration(
                labelText: '物种 (中文)',
                prefixIcon: Icon(Icons.translate),
                hintText: '例如: 球蟒',
              ),
            ),
            const SizedBox(height: 16),

            // 性别
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: l10n.gender,
                prefixIcon: const Icon(Icons.wc),
              ),
              items: [
                DropdownMenuItem(value: 'male', child: Text(GenderUtils.getGenderText('male'))),
                DropdownMenuItem(value: 'female', child: Text(GenderUtils.getGenderText('female'))),
                DropdownMenuItem(value: 'unknown', child: Text(GenderUtils.getGenderText('unknown'))),
              ],
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 16),

            // 出生日期
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake),
              title: Text(l10n.birthDate),
              subtitle: Text(
                _selectedBirthDate != null
                    ? '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
                    : '未设置',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, true),
              ),
            ),
            const Divider(),

            // 获取日期
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n.acquisitionDate),
              subtitle: Text(
                _selectedAcquisitionDate != null
                    ? '${_selectedAcquisitionDate!.year}-${_selectedAcquisitionDate!.month.toString().padLeft(2, '0')}-${_selectedAcquisitionDate!.day.toString().padLeft(2, '0')}'
                    : '未设置',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, false),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // 体重
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '体重 (g)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 体长
            TextFormField(
              controller: _lengthController,
              decoration: const InputDecoration(
                labelText: '体长 (cm)',
                prefixIcon: Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 备注
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 保存按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReptile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
