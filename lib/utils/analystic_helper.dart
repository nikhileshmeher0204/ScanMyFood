import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:read_the_label/core/constants/constans.dart';

class AnalysticHelper {
  AnalysticHelper._();

  static AnalysticHelper? _instance;

  static AnalysticHelper get instance => _instance ??= AnalysticHelper._();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      return;
    }
    await _initCrashlyticService();
    await _initFirebaseRemoteConfig();
    // _initAdjust(Env.adjustkey);
  }

  // void _initAdjust(String adjustkey) {
  //   AdjustConfig config = AdjustConfig(adjustkey,
  //       kDebugMode ? AdjustEnvironment.sandbox : AdjustEnvironment.production);
  //   Adjust.initSdk(config);
  // }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    try {
      return await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
        callOptions: callOptions,
      );
    } catch (e) {
      return;
    }
  }

  // void logCurrentScreenEvent({required String screenName, String? feature}) {
  //   Map<String, Object?>? parameters = {'screen_name': screenName};
  //   if (feature != null) {
  //     parameters.putIfAbsent(
  //       "feature",
  //       () => feature,
  //     );
  //   }
  //   logEvent(
  //     name: "screen_class",
  //     parameters: parameters,
  //   );
  // }

  // void logAdImpressionEvent(ad, AdType adType) {
  //   FirebaseAnalytics.instance.logAdImpression(
  //       adPlatform: 'max_applogin',
  //       adFormat: adType.value,
  //       adSource: ad.networkName,
  //       adUnitName: ad.adUnitId,
  //       currency: "USD",
  //       value: ad.revenue,
  //       parameters: {
  //         'placement': ad.placement,
  //       });
  //   final type = _getAdPlacementType(adType.value);
  //   logEvent(name: '${type}_${ad.placement}_imp');
  // }

  // void logAdClickedEvent(ad, AdType adType) {
  //   try {
  //     final type = _getAdPlacementType(adType.value.toString());
  //     log(type);
  //     logEvent(name: '${type}_${ad.placement}_click');
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  // void logAdmobAdImpressionEvent(AdRevenuePaidParams adRevenuePaidParams) {
  //   final type = _getAdPlacementType(adRevenuePaidParams.adType);
  //   logEvent(name: '${type}_${adRevenuePaidParams.placement}_imp_ADMOB');
  // }

  // void logAdmobAdClickedEvent(AdClickedParams adClickedParams) {
  //   final type = _getAdPlacementType(adClickedParams.adType);
  //   logEvent(name: '${type}_${adClickedParams.placement}_click_ADMOB');
  // }

  // String _getAdPlacementType(String adType) {
  //   if (adType == AdType.banner.value) return 'BN';
  //   if (adType == AdType.interstitial.value) return 'INT';
  //   if (adType == AdType.rewarded.value) return 'RV';
  //   if (adType == AdType.appOpen.value) return 'AOA';
  //   if (adType == AdType.native.value) return 'NT';
  //   if (adType == AdType.bannerCollapsible.value) return 'CL';
  //   return 'Unknow';
  // }

  _initCrashlyticService() {
    try {
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _initFirebaseRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 20),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults({
        RemoteConfigVariables.geminiKey: Env.defaultGeminiKey,
      });

      await remoteConfig.fetchAndActivate();
    } catch (e) {
      log(e.toString());
    }
  }
}
