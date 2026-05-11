import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/providers.dart';
import '../../data/models/record.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';

class GrowthChartScreen extends ConsumerStatefulWidget {
  final String reptileId;
  final String reptileName;

  const GrowthChartScreen({
    super.key,
    required this.reptileId,
    required this.reptileName,
  });

  @override
  ConsumerState<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends ConsumerState<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HealthRecord> _allRecords = [];
  List<HealthRecord> _weightRecords = [];
  List<HealthRecord> _lengthRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final records = await ref.read(recordRepositoryProvider).getHealthRecords(widget.reptileId);
    setState(() {
      _allRecords = records;
      _weightRecords = records.where((r) => r.weight != null).toList();
      _lengthRecords = records.where((r) => r.length != null).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('成长记录 - ${widget.reptileName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '体重(g)'),
            Tab(text: '体长(cm)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartView(_weightRecords, 'weight'),
          _buildChartView(_lengthRecords, 'length'),
        ],
      ),
    );
  }

  Widget _buildChartView(List<HealthRecord> records, String type) {
    if (records.isEmpty) {
      return EmptyState(
        icon: Icons.monitor_weight,
        title: '暂无记录',
        subtitle: type == 'weight' ? '暂无体重记录' : '暂无体长记录',
      );
    }

    final valueKey = type == 'weight' ? 'weight' : 'length';
    final unit = type == 'weight' ? 'g' : 'cm';
    final color = type == 'weight' ? Colors.green : Colors.blue;

    // Convert records to FlSpot data points
    final spots = records
        .map((record) => FlSpot(
              record.recordDate.millisecondsSinceEpoch.toDouble(),
              record.weight != null && value == 'weight'
                  ? record.weight!
                  : record.length!,
            ))
        .toList();

    // Sort by date
    spots.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(
                          DateTimeUtils.formatMonthDay(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}$unit',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildDataTable(records, type),
        ),
      ],
    );
  }

  Widget _buildDataTable(List<HealthRecord> records, String type) {
    final valueKey = type == 'weight' ? 'weight' : 'length';
    final unit = type == 'weight' ? 'g' : 'cm';

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('日期')),
          DataColumn(label: Text('数值')),
        ],
        rows: records.map((record) {
          final value = (valueKey == 'weight' ? record.weight : record.length)!.toStringAsFixed(1);
          return DataRow(
            cells: [
              DataCell(Text(DateTimeUtils.formatDate(record.recordDate))),
              DataCell(Text('$value$unit')),
            ],
          );
        }).toList(),
      ),
    );
  }
}