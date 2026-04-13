import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/reptile.dart';
import '../models/record.dart';
import '../repositories/repositories.dart';

/// 数据导出服务 - 用于将 Flutter App 数据导出为 JSON 文件
/// 导出的数据格式与微信小程序端兼容
class DataExportService {
  final ReptileRepository _reptileRepository = ReptileRepository();
  final RecordRepository _recordRepository = RecordRepository();

  /// 导出数据结构版本
  static const String exportVersion = '1.0';

  /// 导出所有用户数据
  /// 返回导出的文件路径
  Future<String?> exportAllData() async {
    try {
      // 1. 收集所有数据
      final reptiles = await _reptileRepository.getAllReptiles();
      final feedingRecords = <FeedingRecord>[];
      final healthRecords = <HealthRecord>[];

      // 获取每只爬宠的记录
      for (final reptile in reptiles) {
        final feeding = await _recordRepository.getFeedingRecords(reptile.id);
        feedingRecords.addAll(feeding);
        final health = await _recordRepository.getHealthRecords(reptile.id);
        healthRecords.addAll(health);
      }

      // 2. 构建导出数据结构
      final exportData = {
        'version': exportVersion,
        'exportTime': DateTime.now().toIso8601String(),
        'data': {
          'reptiles': reptiles.map((r) => _reptileToExport(r)).toList(),
          'feedingRecords': feedingRecords.map((r) => _feedingRecordToExport(r)).toList(),
          'healthRecords': healthRecords.map((r) => _healthRecordToExport(r)).toList(),
        },
      };

      // 3. 转换为 JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // 4. 保存到临时文件
      final directory = await getTemporaryDirectory();
      final fileName = 'wildherd_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('数据导出失败: $e');
      return null;
    }
  }

  /// 分享导出文件
  Future<bool> shareExport() async {
    final filePath = await exportAllData();
    if (filePath == null) {
      return false;
    }

    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'WildHerd 数据备份',
        text: '这是 WildHerd 爬宠管理应用的数据备份文件，可导入到微信小程序版本。',
      );
      return true;
    } catch (e) {
      print('分享失败: $e');
      return false;
    }
  }

  /// 爬宠数据转换为导出格式
  Map<String, dynamic> _reptileToExport(Reptile reptile) {
    return {
      'name': reptile.name,
      'species': reptile.species,
      'speciesChinese': reptile.speciesChinese,
      'gender': reptile.gender,
      'birthDate': reptile.birthDate?.toIso8601String().split('T')[0],
      'weight': reptile.weight,
      'length': reptile.length,
      'imageUrl': reptile.imagePath, // Flutter 用 imagePath，小程序用 imageUrl
      'acquisitionDate': reptile.acquisitionDate?.toIso8601String().split('T')[0],
      'breedingStatus': _convertBreedingStatus(reptile.breedingStatus),
      'notes': reptile.notes,
    };
  }

  /// 喂食记录转换为导出格式
  Map<String, dynamic> _feedingRecordToExport(FeedingRecord record) {
    return {
      'reptileId': record.reptileId,
      'foodType': _convertFoodType(record.foodType),
      'foodAmount': record.foodAmount,
      'feedingTime': record.feedingTime.toIso8601String().split('T')[0],
      'notes': record.notes,
    };
  }

  /// 健康记录转换为导出格式
  Map<String, dynamic> _healthRecordToExport(HealthRecord record) {
    return {
      'reptileId': record.reptileId,
      'recordDate': record.recordDate.toIso8601String().split('T')[0],
      'weight': record.weight,
      'length': record.length,
      'status': _convertHealthStatus(record.status),
      'defecation': _convertDefecation(record.defecation),
      'notes': record.notes,
    };
  }

  /// 转换繁殖状态为英文（与小程序一致）
  String? _convertBreedingStatus(String? status) {
    switch (status) {
      case 'available':
        return 'available';
      case 'breeding':
        return 'bred';
      case 'retired':
        return 'resting';
      default:
        return 'available';
    }
  }

  /// 转换食物类型为英文（与小程序一致）
  String _convertFoodType(String foodType) {
    switch (foodType) {
      case '老鼠':
      case 'mouse':
        return 'mouse';
      case '乳鼠':
      case 'pink_mouse':
        return 'pink_mouse';
      case '蜥蜴':
      case 'lizard':
        return 'lizard';
      case '蛙类':
      case 'frog':
        return 'frog';
      case '昆虫':
      case 'insect':
        return 'insect';
      default:
        return 'other';
    }
  }

  /// 转换健康状态为英文
  String? _convertHealthStatus(String? status) {
    switch (status) {
      case '正常':
      case 'normal':
        return 'normal';
      case '异常':
      case 'abnormal':
        return 'abnormal';
      default:
        return 'normal';
    }
  }

  /// 转换排便状态为英文
  String? _convertDefecation(String? defecation) {
    switch (defecation) {
      case '正常':
      case 'normal':
        return 'normal';
      case '异常':
      case 'abnormal':
        return 'abnormal';
      case '便秘':
      case 'constipated':
        return 'constipated';
      default:
        return 'normal';
    }
  }
}
