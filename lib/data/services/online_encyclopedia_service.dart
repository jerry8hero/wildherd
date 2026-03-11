import 'dart:convert';
import 'package:http/http.dart' as http;

/// 在线百科搜索结果
class OnlineEncyclopediaResult {
  final String title;
  final String description;
  final String extract;
  final String url;
  final String? imageUrl;

  OnlineEncyclopediaResult({
    required this.title,
    required this.description,
    required this.extract,
    required this.url,
    this.imageUrl,
  });

  factory OnlineEncyclopediaResult.fromJson(Map<String, dynamic> json) {
    return OnlineEncyclopediaResult(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      extract: json['extract'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

/// 在线百科服务 - 使用 Wikipedia API
class OnlineEncyclopediaService {
  static const String _baseUrl = 'https://en.wikipedia.org/w/api.php';

  /// 搜索百科知识
  /// [keyword] 搜索关键词
  /// [limit] 返回结果数量限制
  static Future<List<OnlineEncyclopediaResult>> search(String keyword, {int limit = 10}) async {
    if (keyword.isEmpty) return [];

    try {
      // 使用 Wikipedia OpenSearch API
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'opensearch',
        'search': keyword,
        'limit': limit.toString(),
        'namespace': '0',
        'format': 'json',
        'origin': '*',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.length >= 4) {
          final titles = data[1] as List;
          final descriptions = data[2] as List;
          final urls = data[3] as List;

          final results = <OnlineEncyclopediaResult>[];
          for (int i = 0; i < titles.length; i++) {
            results.add(OnlineEncyclopediaResult(
              title: titles[i] ?? '',
              description: descriptions[i] ?? '',
              extract: descriptions[i] ?? '',
              url: urls[i] ?? '',
            ));
          }
          return results;
        }
      }
      return [];
    } catch (e) {
      print('Wikipedia search error: $e');
      return [];
    }
  }

  /// 获取词条详细信息
  /// [title] 词条标题
  static Future<OnlineEncyclopediaResult?> getArticleDetail(String title) async {
    if (title.isEmpty) return null;

    try {
      // 使用 Wikipedia Query API 获取摘要和图片
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'query',
        'titles': title,
        'prop': 'extracts|pageimages',
        'exintro': 'true',
        'explaintext': 'true',
        'pithumbsize': '300',
        'format': 'json',
        'origin': '*',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final pages = data['query']?['pages'] as Map<String, dynamic>?;

        if (pages != null && pages.isNotEmpty) {
          final page = pages.values.first as Map<String, dynamic>;
          final pageId = page['pageid'];

          if (pageId != null && pageId > 0) {
            final extract = page['extract'] ?? '';
            final thumbnail = page['thumbnail'] as Map<String, dynamic>?;
            final imageUrl = thumbnail?['source'];

            // 构建 Wikipedia 页面 URL
            final url = 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}';

            return OnlineEncyclopediaResult(
              title: title,
              description: extract.length > 200 ? '${extract.substring(0, 200)}...' : extract,
              extract: extract,
              url: url,
              imageUrl: imageUrl,
            );
          }
        }
      }
      return null;
    } catch (e) {
      print('Wikipedia get detail error: $e');
      return null;
    }
  }

  /// 搜索爬宠相关百科知识
  /// 在关键词后添加爬宠相关后缀进行更精准的搜索
  static Future<List<OnlineEncyclopediaResult>> searchReptile(String keyword, {int limit = 10}) async {
    // 尝试直接搜索
    var results = await search(keyword, limit: limit);

    // 如果结果太少，尝试添加爬宠相关关键词
    if (results.length < 3) {
      final reptileResults = await search('$keyword reptile', limit: limit);
      results = [...results, ...reptileResults];
    }

    return results.take(limit).toList();
  }

  /// 获取常见爬宠物种的百科信息
  static Future<List<OnlineEncyclopediaResult>> getCommonReptiles() async {
    final species = [
      'Red-eared slider', // 巴西龟
      'Leopard gecko', // 豹纹守宫
      'Corn snake', // 玉米蛇
      'Bearded dragon', // 鬃狮蜥
      'Ball python', // 球蟒
      'Crested gecko', // 睫角守宫
      'Blue-tongued skink', // 蓝舌石龙子
      'Russian tortoise', // 俄罗斯陆龟
      'Axolotl', // 墨西哥钝口螈
      'Turtle',
      'Lizard',
      'Snake',
      'Gecko',
    ];

    final results = <OnlineEncyclopediaResult>[];
    for (final name in species) {
      final detail = await getArticleDetail(name);
      if (detail != null) {
        results.add(detail);
      }
      // 添加小延迟避免请求过快
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }
}
