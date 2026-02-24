import 'package:flutter/material.dart';
import '../../data/models/medical.dart';
import '../../data/repositories/repositories.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> with SingleTickerProviderStateMixin {
  final MedicalRepository _repository = MedicalRepository();
  late TabController _tabController;
  List<Disease> _diseases = [];
  List<Symptom> _symptoms = [];
  List<EmergencyGuide> _emergencyGuides = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final diseases = await _repository.getAllDiseases();
      final symptoms = await _repository.getAllSymptoms();
      final guides = await _repository.getEmergencyGuides();
      setState(() {
        _diseases = diseases;
        _symptoms = symptoms;
        _emergencyGuides = guides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('医疗健康'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '疾病库'),
            Tab(text: '症状检查'),
            Tab(text: '紧急处理'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDiseaseTab(),
                _buildSymptomTab(),
                _buildEmergencyTab(),
              ],
            ),
    );
  }

  Widget _buildDiseaseTab() {
    final filteredDiseases = _selectedCategory == null
        ? _diseases
        : _diseases.where((d) => d.speciesCategory == _selectedCategory).toList();

    return Column(
      children: [
        // 分类筛选
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildCategoryChip(null, '全部'),
              _buildCategoryChip('snake', '蛇类'),
              _buildCategoryChip('gecko', '守宫'),
              _buildCategoryChip('lizard', '蜥蜴'),
              _buildCategoryChip('turtle', '龟类'),
              _buildCategoryChip('amphibian', '两栖'),
            ],
          ),
        ),
        Expanded(
          child: filteredDiseases.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDiseases.length,
                  itemBuilder: (context, index) {
                    return _buildDiseaseCard(filteredDiseases[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String? value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : null;
          });
        },
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(disease),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      disease.nameZh,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (disease.isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '紧急',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                disease.name,
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(
                disease.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.pets, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    disease.relatedSpecies ?? disease.speciesCategory ?? '',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.category, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    disease.categoryName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomTab() {
    return Column(
      children: [
        // 说明
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '选择宠物表现出的症状，系统将列出可能的疾病',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _navigateToSymptomChecker(),
          icon: const Icon(Icons.healing),
          label: const Text('开始症状检查'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _symptoms.length,
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              return ListTile(
                leading: const Icon(Icons.medical_services),
                title: Text(symptom.nameZh),
                subtitle: Text(symptom.name),
                onTap: () => _showSymptomDetail(symptom),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emergencyGuides.length,
      itemBuilder: (context, index) {
        final guide = _emergencyGuides[index];
        return _buildEmergencyCard(guide);
      },
    );
  }

  Widget _buildEmergencyCard(EmergencyGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red[50],
      child: InkWell(
        onTap: () => _showEmergencyDetail(guide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red[700], size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.titleZh,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.title,
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: MedicalSearchDelegate(repository: _repository),
    );
  }

  void _navigateToDetail(Disease disease) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDetailScreen(diseaseId: disease.id),
      ),
    );
  }

  void _navigateToSymptomChecker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SymptomCheckerScreen(),
      ),
    );
  }

  void _showSymptomDetail(Symptom symptom) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symptom.nameZh,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              symptom.name,
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            if (symptom.description != null) ...[
              const SizedBox(height: 12),
              Text(symptom.description!),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToSymptomChecker();
              },
              child: const Text('开始检查'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDetail(EmergencyGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.emergency, color: Colors.red[700], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    guide.titleZh,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                guide.content,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 疾病详情页
class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseId;

  const DiseaseDetailScreen({super.key, required this.diseaseId});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final MedicalRepository _repository = MedicalRepository();
  Disease? _disease;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final disease = await _repository.getDiseaseDetail(widget.diseaseId);
      setState(() {
        _disease = disease;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('疾病详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disease == null
              ? const Center(child: Text('疾病不存在'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final disease = _disease!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Expanded(
                child: Text(
                  disease.nameZh,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (disease.isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '紧急',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Text(
            disease.name,
            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          // 基本信息
          _buildInfoRow('相关物种', disease.relatedSpecies ?? disease.speciesCategory ?? '未知'),
          _buildInfoRow('疾病类别', disease.categoryName),
          const SizedBox(height: 24),
          // 描述
          _buildSection('疾病描述', disease.description),
          // 症状
          if (disease.symptoms.isNotEmpty) _buildSection('症状', disease.symptoms.join('\n')),
          // 病因
          _buildSection('病因', disease.cause),
          // 治疗
          _buildSection('治疗方案', disease.treatment, isHighlight: true),
          // 预防
          _buildSection('预防措施', disease.prevention),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green[700] : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlight ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isHighlight ? Colors.green[800] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

// 症状检查器
class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final MedicalRepository _repository = MedicalRepository();
  List<Symptom> _symptoms = [];
  List<String> _selectedSymptomIds = [];
  List<Disease> _matchedDiseases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    try {
      final symptoms = await _repository.getAllSymptoms();
      setState(() {
        _symptoms = symptoms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkDiseases() async {
    if (_selectedSymptomIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个症状')),
      );
      return;
    }
    final diseases = await _repository.findDiseasesBySymptoms(_selectedSymptomIds);
    setState(() => _matchedDiseases = diseases);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('症状检查'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 进度提示
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '已选择 ${_selectedSymptomIds.length} 个症状',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
                // 症状列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _symptoms.length,
                    itemBuilder: (context, index) {
                      final symptom = _symptoms[index];
                      final isSelected = _selectedSymptomIds.contains(symptom.id);
                      return CheckboxListTile(
                        title: Text(symptom.nameZh),
                        subtitle: Text(symptom.name),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedSymptomIds.add(symptom.id);
                            } else {
                              _selectedSymptomIds.remove(symptom.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                // 检查按钮
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkDiseases,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('查看可能的疾病'),
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: _matchedDiseases.isNotEmpty ? _buildResultSheet() : null,
    );
  }

  Widget _buildResultSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '可能的疾病',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _matchedDiseases = []),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _matchedDiseases.length,
              itemBuilder: (context, index) {
                final disease = _matchedDiseases[index];
                return ListTile(
                  title: Text(disease.nameZh),
                  subtitle: Text(disease.categoryName),
                  trailing: disease.isEmergency
                      ? const Icon(Icons.warning, color: Colors.red)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseDetailScreen(diseaseId: disease.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 搜索代理
class MedicalSearchDelegate extends SearchDelegate<String> {
  final MedicalRepository repository;

  MedicalSearchDelegate({required this.repository});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('输入关键词搜索疾病'));
    }
    return FutureBuilder<List<Disease>>(
      future: repository.searchDiseases(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('未找到相关疾病'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final disease = results[index];
            return ListTile(
              title: Text(disease.nameZh),
              subtitle: Text(disease.description, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: disease.isEmergency
                  ? const Icon(Icons.warning, color: Colors.red)
                  : null,
              onTap: () {
                close(context, disease.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiseaseDetailScreen(diseaseId: disease.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
