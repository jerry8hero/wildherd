import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 定位服务
class LocationService {
  /// 检查定位权限
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 获取当前位置
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('定位超时'),
      );
    } catch (e) {
      return null;
    }
  }

  /// 通过经纬度获取城市名称
  static Future<String?> getCityName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // 优先使用城市名，其次使用区县名
        return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      }
    } catch (e) {
      // 地理编码失败，返回null
    }
    return null;
  }

  /// 获取当前位置并返回城市名称
  static Future<String?> getCurrentCity() async {
    final position = await getCurrentPosition();
    if (position != null) {
      return await getCityName(position.latitude, position.longitude);
    }
    return null;
  }

  /// 打开系统定位设置
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// 打开应用设置
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
