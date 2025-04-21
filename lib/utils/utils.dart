import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static PackageInfo? packageInfo;
  static final deviceInfo = DeviceInfoPlugin();
  static String currentVersionCode = '';
  static String currentVersionName = '';
  static AndroidDeviceInfo? androidInfo;
  static String appPackageName = '';

  static Future<String> getAppVersionName() async {
    if (currentVersionName.isNotEmpty) return currentVersionName;
    packageInfo ??= await PackageInfo.fromPlatform();
    currentVersionName = packageInfo?.version ?? '';
    return currentVersionName;
  }

  static Future<String> getAppVersionCode() async {
    if (currentVersionCode.isNotEmpty) return currentVersionCode;
    packageInfo ??= await PackageInfo.fromPlatform();
    currentVersionCode = packageInfo?.buildNumber ?? '';
    return currentVersionCode;
  }

  static Future<bool> isAppInReview(String remoteVersion) async {
    final String currentVersion = await getAppVersionCode();

    return currentVersion == remoteVersion;
  }

  static Future<int?> getCurrentSDKLevel() async {
    if (Platform.isAndroid) {
      androidInfo ??= await deviceInfo.androidInfo;
      return androidInfo!.version.sdkInt;
    }
    return null;
  }

  static Future<String> getAppPackageName() async {
    if (appPackageName.isNotEmpty) return appPackageName;
    packageInfo ??= await PackageInfo.fromPlatform();
    appPackageName = packageInfo?.packageName ?? '';
    return appPackageName;
  }

  static Future<bool> requestPermission() async {
    try {
      final int? sdkLevel = await Utils.getCurrentSDKLevel();
      if (sdkLevel != null && sdkLevel >= 33) {
        final bool result = await requestImagePermission();
        if (result) {
          // AnalysticHelper.instance.logEvent(name: "storage_permission_accept");
        }
        return result;
      } else {
        final bool result = await requestStoragePermission();
        if (result) {
          // AnalysticHelper.instance.logEvent(name: "storage_permission_accept");
        }
        return result;
      }
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestImagePermission() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}

void logger(String message) {
  if (kDebugMode) log(message);
}
