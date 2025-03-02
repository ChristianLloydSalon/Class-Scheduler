import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Gets a unique device ID for Android
  Future<String> getDeviceId() async {
    try {
      // Try to get existing device ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId != null) {
        return deviceId;
      }

      // Generate new device ID using Android ID
      final androidInfo = await _deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Android ID persists through app reinstalls

      // Save the device ID
      await prefs.setString(_deviceIdKey, deviceId);

      return deviceId;
    } catch (e) {
      // Return a default ID if something goes wrong
      return 'unknown_device';
    }
  }

  /// Gets Android device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final fcmToken = await FirebaseMessaging.instance.getToken();

      return {
        'brand': androidInfo.brand,
        'model': androidInfo.model,
        'androidVersion': androidInfo.version.release,
        'manufacturer': androidInfo.manufacturer,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'fcmToken': fcmToken,
      };
    } catch (e) {
      return {
        'brand': 'unknown',
        'model': 'unknown',
        'androidVersion': 'unknown',
        'manufacturer': 'unknown',
        'isPhysicalDevice': false,
      };
    }
  }
}
