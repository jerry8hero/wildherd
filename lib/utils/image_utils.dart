import 'package:flutter/material.dart';

/// 图片工具类 - 统一处理网络图片和本地图片
class ImageUtils {
  /// 根据图片路径类型返回对应的 ImageProvider
  /// 支持：http/https 网络图片、assets 本地资源、file 本地文件
  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    if (imagePath.startsWith('file://')) {
      return FileImage(Uri.parse(imagePath).toFilePath() as File);
    }
    return AssetImage(imagePath);
  }

  /// 构建带错误处理的图片组件
  static Widget buildImage(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildErrorPlaceholder(errorWidget);
    }

    return Image(
      image: getImageProvider(imageUrl),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorPlaceholder(errorWidget);
      },
    );
  }

  static Widget _buildErrorPlaceholder(Widget? customWidget) {
    return customWidget ??
        Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
  }
}
