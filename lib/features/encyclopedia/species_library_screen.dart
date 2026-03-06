import 'package:flutter/material.dart';
import '../../data/services/knowledge_base_service.dart';

class SpeciesLibraryScreen extends StatefulWidget {
  const SpeciesLibraryScreen({super.key});

  @override
  State<SpeciesLibraryScreen> createState() => _SpeciesLibraryScreenState();
}

class _SpeciesLibraryScreenState extends State<SpeciesLibraryScreen> {
  List<KnowledgeCategory> _categories = [];
  List<Species> _allSpecies = [];
  List<Species> _filteredSpecies = [];
  String? _selectedCategory;
  String _searchKeyword = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _categories = await KnowledgeBaseService.getCategories();
    _allSpecies = await KnowledgeBaseService.getAllSpecies();
    _filteredSpecies = _allSpecies;

    setState(() => _isLoading = false);
  }

  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      _applyFilters();
    });
  }

  void _search(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredSpecies = _allSpecies.where((species) {
      // 分类过滤
      if (_selectedCategory != null && species.category != _selectedCategory) {
        return false;
      }
      // 搜索过滤
      if (_searchKeyword.isNotEmpty) {
        final kw = _searchKeyword.toLowerCase();
        return species.nameChinese.toLowerCase().contains(kw) ||
            species.nameEnglish.toLowerCase().contains(kw) ||
            species.scientificName.toLowerCase().contains(kw) ||
            species.tags.any((t) => t.toLowerCase().contains(kw));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物种库'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索物种...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 分类筛选
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _buildCategoryChip(null, '全部', _allSpecies.length),
                      ..._categories.map((cat) => _buildCategoryChip(
                            cat.id,
                            cat.name,
                            _allSpecies.where((s) => s.category == cat.id).length,
                          )),
                    ],
                  ),
                ),
                // 物种列表
                Expanded(
                  child: _filteredSpecies.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSpecies.length,
                          itemBuilder: (context, index) {
                            return _buildSpeciesCard(_filteredSpecies[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String? id, String name, int count) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$name ($count)'),
        selected: isSelected,
        onSelected: (_) => _filterByCategory(id),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          const Text('未找到相关物种'),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(Species species) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSpeciesDetail(species),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    species.categoryIcon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            species.nameChinese,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildDifficultyBadge(species.difficulty),
                      ],
                    ),
                    if (species.nameEnglish.isNotEmpty)
                      Text(
                        species.nameEnglish,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    if (species.scientificName.isNotEmpty)
                      Text(
                        species.scientificName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // 标签
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: species.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(int difficulty) {
    Color color;
    String text;
    switch (difficulty) {
      case 1:
        color = Colors.green;
        text = '入门';
        break;
      case 2:
        color = Colors.orange;
        text = '进阶';
        break;
      case 3:
        color = Colors.red;
        text = '高级';
        break;
      default:
        color = Colors.green;
        text = '入门';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSpeciesDetail(Species species) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _SpeciesDetailSheet(
          species: species,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _SpeciesDetailSheet extends StatelessWidget {
  final Species species;
  final ScrollController scrollController;

  const _SpeciesDetailSheet({
    required this.species,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // 顶部拖动条
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题
          Row(
            children: [
              Text(
                species.categoryIcon,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.nameChinese,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (species.nameEnglish.isNotEmpty)
                      Text(
                        species.nameEnglish,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (species.scientificName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              species.scientificName,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // 标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: species.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const Divider(height: 32),
          // 描述
          Text(
            '简介',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(species.description),
          const SizedBox(height: 16),
          // 基本信息
          _buildInfoSection(context),
          const SizedBox(height: 16),
          // 饲养信息
          if (species.feeding.isNotEmpty) ...[
            _buildCareSection(
              context,
              '喂食',
              Icons.restaurant,
              species.feeding,
            ),
            const SizedBox(height: 12),
          ],
          if (species.housing.isNotEmpty) ...[
            _buildCareSection(
              context,
              '饲养环境',
              Icons.home,
              species.housing,
            ),
            const SizedBox(height: 12),
          ],
          if (species.care.isNotEmpty) ...[
            _buildCareSection(
              context,
              '日常护理',
              Icons.favorite,
              species.care,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final items = <MapEntry<String, String>>[];
    if (species.lifespan.isNotEmpty) items.add(MapEntry('寿命', species.lifespan));
    if (species.size.isNotEmpty) items.add(MapEntry('体型', species.size));
    if (species.distribution.isNotEmpty) items.add(MapEntry('分布', species.distribution));
    if (species.habitat.isNotEmpty) items.add(MapEntry('栖息地', species.habitat));
    if (species.diet.isNotEmpty) items.add(MapEntry('食性', species.diet));
    if (species.temperature.isNotEmpty) items.add(MapEntry('温度', species.temperature));
    if (species.humidity.isNotEmpty) items.add(MapEntry('湿度', species.humidity));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本信息',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: items.map((item) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      item.key,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCareSection(BuildContext context, String title, IconData icon, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
