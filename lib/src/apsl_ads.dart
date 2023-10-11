import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:apsl_ads_flutter/apsl_ads_flutter.dart';
import 'package:apsl_ads_flutter/src/apsl_admob/apsl_admob_interstitial_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_admob/apsl_admob_rewarded_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_applovin/apsl_applovin_banner_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_applovin/apsl_applovin_interstitial_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_applovin/apsl_applovin_rewarded_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_facebook/apsl_facebook_banner_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_facebook/apsl_facebook_full_screen_ad.dart';
import 'package:apsl_ads_flutter/src/apsl_unity/apsl_unity_ad.dart';
import 'package:apsl_ads_flutter/src/utils/apsl_event_controller.dart';
import 'package:apsl_ads_flutter/src/utils/apsl_logger.dart';
import 'package:apsl_ads_flutter/src/utils/auto_hiding_loader_dialog.dart';
import 'package:apsl_ads_flutter/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'apsl_admob/apsl_admob_native_ad.dart';

class ApslAds {
  ApslAds._apslAds();
  static final ApslAds instance = ApslAds._apslAds();

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  late final AdsIdManager adIdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  final _eventController = ApslEventController();
  Stream<AdEvent> get onEvent => _eventController.onEvent;

  List<ApslAdBase> get _allAds => [..._interstitialAds, ..._rewardedAds];

  /// All the App Open Ads ads will be stored in it
  final List<ApslAdBase> _appOpenAds = [];

  /// All the Interstitial ads will be stored in it
  final List<ApslAdBase> _interstitialAds = [];

  /// All the Rewarded ads will be stored in it
  final List<ApslAdBase> _rewardedAds = [];

  /// [_logger] is used to show Ad logs in the console
  final ApslLogger _logger = ApslLogger();

  /// On banner, ad badge will appear
  bool get showAdBadge => _showAdBadge;
  bool _showAdBadge = false;

  bool _preLoadRewardedAds = false;

  int _interstitialAdIndex = 0;
  int _rewardedAdIndex = 0;
  int _appOpenAdIndex = 0;

  int _navigationCount = 0;
  int _showNavigationAdAfterCount = 1;

  /// [_isMobileAdNetworkInitialized] is used to check if admob is initialized or not
  bool _isMobileAdNetworkInitialized = false;

  StreamSubscription? _streamSubscription;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  /// [fbTestingId] can be obtained by running the app once without the testingId.
  Future<void> initialize(
    AdsIdManager manager, {
    bool unityTestMode = false,
    bool fbTestMode = false,
    bool isShowAppOpenOnAppStateChange = false,
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    String? fbTestingId,
    bool fbiOSAdvertiserTrackingEnabled = false,
    bool isAgeRestrictedUserForApplovin = false,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
    bool showAdBadge = false,
    int showNavigationAdAfterCount = 1,
    bool preloadRewardedAds = false,
  }) async {
    _showAdBadge = showAdBadge;
    _showNavigationAdAfterCount = showNavigationAdAfterCount;
    _preLoadRewardedAds = preloadRewardedAds;
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    if (admobConfiguration != null) {
      MobileAds.instance.updateRequestConfiguration(admobConfiguration);
    }

    for (var appAdId in manager.appAdIds) {
      if (appAdId.appId.isNotEmpty) {
        final adNetworkName = getAdNetworkFromString(appAdId.adNetwork);
        switch (adNetworkName) {
          case AdNetwork.admob:

            // Initializing Mobile Ads SDK
            if (!_isMobileAdNetworkInitialized) {
              final response = await MobileAds.instance.initialize();
              final status = response.adapterStatuses.values.firstOrNull?.state;

              response.adapterStatuses.forEach((key, value) {
                _logger.logInfo(
                    'Google-mobile-ads Adapter status for $key: ${value.description}');
              });

              _eventController.fireNetworkInitializedEvent(
                  AdNetwork.admob, status == AdapterInitializationState.ready);

              _isMobileAdNetworkInitialized = true;
            }

            // Initializing admob Ads
            await ApslAds.instance._initAdmob(
              appOpenAdUnitId: appAdId.appOpenId,
              interstitialAdUnitId: appAdId.interstitialId,
              rewardedAdUnitId: appAdId.rewardedId,
              appOpenAdOrientation: appOpenAdOrientation,
              isShowAppOpenOnAppStateChange: isShowAppOpenOnAppStateChange,
            );

            break;
          case AdNetwork.unity:
            // Initializing unity Ads
            ApslAds.instance._initUnity(
              unityGameId: appAdId.appId,
              testMode: unityTestMode,
              interstitialPlacementId: appAdId.interstitialId,
              rewardedPlacementId: appAdId.rewardedId,
            );
            break;
          case AdNetwork.facebook:
            // Initializing facebook Ads
            ApslAds.instance._initFacebook(
              testingId: fbTestingId,
              testMode: fbTestMode,
              iOSAdvertiserTrackingEnabled: fbiOSAdvertiserTrackingEnabled,
              interstitialPlacementId: appAdId.interstitialId,
              rewardedPlacementId: appAdId.rewardedId,
            );
            break;
          case AdNetwork.appLovin:
            // Initializing applovin Ads
            ApslAds.instance._initAppLovin(
              sdkKey: appAdId.appId,
              keywords: adMobAdRequest?.keywords,
              isAgeRestrictedUser: isAgeRestrictedUserForApplovin,
              interstitialAdUnitId: appAdId.interstitialId,
              rewardedAdUnitId: appAdId.rewardedId,
            );
          case AdNetwork.any:
            break;
          default:
            break;
        }
      }
    }
  }

  /// Returns [ApslAdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  ApslAdBase? createBanner(
      {required AdNetwork adNetwork, AdSize adSize = AdSize.banner}) {
    ApslAdBase? ad;
    final bannerId = adIdManager.getAppIds(adNetwork).bannerId;

    switch (adNetwork) {
      case AdNetwork.admob:
        assert(bannerId != null,
            'You are trying to create a banner and Admob Banner id is null in ad id manager');
        if (bannerId != null) {
          ad = ApslAdmobBannerAd(bannerId,
              adSize: adSize, adRequest: _adRequest);
          _eventController.setupEvents(ad);
        }
        break;
      case AdNetwork.unity:
        assert(bannerId != null,
            'You are trying to create a banner and Unity Banner id is null in ad id manager');
        if (bannerId != null) {
          ad = ApslUnityBannerAd(bannerId, adSize: adSize);
          _eventController.setupEvents(ad);
        }
        break;
      case AdNetwork.facebook:
        assert(bannerId != null,
            'You are trying to create a banner and Facebook Banner id is null in ad id manager');
        if (bannerId != null) {
          ad = ApslFacebookBannerAd(bannerId, adSize: adSize);
          _eventController.setupEvents(ad);
        }
        break;
      case AdNetwork.appLovin:
        assert(bannerId != null,
            'You are trying to create a banner and Applovin Banner id is null in ad id manager');
        if (bannerId != null) {
          ad = ApslApplovinBannerAd(bannerId);
          _eventController.setupEvents(ad);
        }
        break;
      default:
        ad = null;
    }
    return ad;
  }

  ApslAdBase? createNative({
    required AdNetwork adNetwork,
    NativeTemplateStyle? nativeTemplateStyle,
    TemplateType? templateType,
  }) {
    ApslAdBase? ad;
    final nativeId = adIdManager.getAppIds(adNetwork).nativeId;

    switch (adNetwork) {
      case AdNetwork.admob:
        assert(nativeId != null,
            'You are trying to create a native ad and Admob Native id is null in ad id manager');
        if (nativeId != null) {
          ad = ApslAdmobNativeAd(
            nativeId,
            nativeTemplateStyle: nativeTemplateStyle,
            templateType: templateType,
          );
        }
        break;
      case AdNetwork.unity:
        // assert(nativeId != null,
        //     'You are trying to create a native ad and Unity Native id is null in ad id manager');
        if (nativeId != null) {
          // ad = ApslUnityNativeAd();
        }
        break;
      case AdNetwork.facebook:
        // assert(nativeId != null,
        //     'You are trying to create a native ad and Facebook Native id is null in ad id manager');
        if (nativeId != null) {
          // ad = ApslFacebookNativeAd();
        }
        break;
      default:
        ad = null;
    }
    return ad;
  }

  Future<void> _initAdmob({
    String? appOpenAdUnitId,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
    bool immersiveModeEnabled = true,
    bool isShowAppOpenOnAppStateChange = true,
    int appOpenAdOrientation = AppOpenAd.orientationPortrait,
  }) async {
    // init interstitial ads
    ApslLogger().logInfo("InterstitialAdUnitId $interstitialAdUnitId");
    if (interstitialAdUnitId != null &&
        _interstitialAds.doesNotContain(
          AdNetwork.admob,
          AdUnitType.interstitial,
          interstitialAdUnitId,
        )) {
      final ad = ApslAdmobInterstitialAd(
          interstitialAdUnitId, _adRequest, immersiveModeEnabled);
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedAdUnitId != null &&
        _rewardedAds.doesNotContain(
          AdNetwork.admob,
          AdUnitType.rewarded,
          rewardedAdUnitId,
        )) {
      final ad = ApslAdmobRewardedAd(
        adRequest: _adRequest,
        adUnitId: rewardedAdUnitId,
        immersiveModeEnabled: immersiveModeEnabled,
        preLoadRewardedAds: _preLoadRewardedAds,
      );
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      if (_preLoadRewardedAds) {
        await ad.load(); //dv removed preloading of rewarded ad
      }
    }

    if (appOpenAdUnitId != null &&
        _appOpenAds.doesNotContain(
          AdNetwork.admob,
          AdUnitType.appOpen,
          appOpenAdUnitId,
        )) {
      final appOpenAdManager =
          ApslAdmobAppOpenAd(appOpenAdUnitId, _adRequest, appOpenAdOrientation);
      await appOpenAdManager.load();
      if (isShowAppOpenOnAppStateChange) {
        _appLifecycleReactor =
            AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
        _appLifecycleReactor.listenToAppStateChanges();
      }
      _appOpenAds.add(appOpenAdManager);
      _eventController.setupEvents(appOpenAdManager);
    }
  }

  Future<void> _initAppLovin({
    required String sdkKey,
    bool? isAgeRestrictedUser,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
    List<String>? keywords,
  }) async {
    final response = await AppLovinMAX.initialize(sdkKey);

    AppLovinMAX.targetingData.maximumAdContentRating =
        isAgeRestrictedUser == true
            ? AdContentRating.allAudiences
            : AdContentRating.none;

    if (keywords != null) {
      AppLovinMAX.targetingData.keywords = keywords;
    }

    if (response != null) {
      _eventController.fireNetworkInitializedEvent(AdNetwork.appLovin, true);
    } else {
      _eventController.fireNetworkInitializedEvent(AdNetwork.appLovin, false);
    }

    // init interstitial ads
    if (interstitialAdUnitId != null &&
        _interstitialAds.doesNotContain(
          AdNetwork.appLovin,
          AdUnitType.interstitial,
          interstitialAdUnitId,
        )) {
      final ad = ApslApplovinInterstitialAd(interstitialAdUnitId);
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedAdUnitId != null &&
        _rewardedAds.doesNotContain(
          AdNetwork.appLovin,
          AdUnitType.rewarded,
          rewardedAdUnitId,
        )) {
      final ad = ApslApplovinRewardedAd(rewardedAdUnitId);
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      if (_preLoadRewardedAds) {
        await ad.load(); //dv removed preloading of rewarded ad
      }
    }
  }

  /// * [unityGameId] - identifier from Project Settings in Unity Dashboard.
  /// * [testMode] - if true, then test ads are shown.
  Future _initUnity({
    String? unityGameId,
    bool testMode = false,
    String? interstitialPlacementId,
    String? rewardedPlacementId,
  }) async {
    // placementId
    if (unityGameId != null) {
      await UnityAds.init(
        gameId: unityGameId,
        testMode: testMode,
        onComplete: () =>
            _eventController.fireNetworkInitializedEvent(AdNetwork.unity, true),
        onFailed: (UnityAdsInitializationError error, String s) =>
            _eventController.fireNetworkInitializedEvent(
                AdNetwork.unity, false),
      );
    }

    // init interstitial ads
    if (interstitialPlacementId != null &&
        _interstitialAds.doesNotContain(
          AdNetwork.unity,
          AdUnitType.interstitial,
          interstitialPlacementId,
        )) {
      final ad = ApslUnityAd(
          adUnitId: interstitialPlacementId,
          adUnitType: AdUnitType.interstitial);
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedPlacementId != null &&
        _rewardedAds.doesNotContain(
          AdNetwork.unity,
          AdUnitType.rewarded,
          rewardedPlacementId,
        )) {
      final ad = ApslUnityAd(
        adUnitId: rewardedPlacementId,
        adUnitType: AdUnitType.rewarded,
        preLoadRewardedAds: _preLoadRewardedAds,
      );
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      if (_preLoadRewardedAds) {
        await ad.load(); //dv removed preloading of rewarded ad
      }
    }
  }

  Future _initFacebook({
    required bool iOSAdvertiserTrackingEnabled,
    required bool testMode,
    String? testingId,
    String? interstitialPlacementId,
    String? rewardedPlacementId,
  }) async {
    final status = await EasyAudienceNetwork.init(
      testingId: testingId,
      testMode: testMode,
      iOSAdvertiserTrackingEnabled: iOSAdvertiserTrackingEnabled,
    );

    _eventController.fireNetworkInitializedEvent(
        AdNetwork.facebook, status ?? false);

    // init interstitial ads
    if (interstitialPlacementId != null &&
        _interstitialAds.doesNotContain(
          AdNetwork.facebook,
          AdUnitType.interstitial,
          interstitialPlacementId,
        )) {
      final ad = ApslFacebookFullScreenAd(
        adUnitId: interstitialPlacementId,
        adUnitType: AdUnitType.interstitial,
      );
      _interstitialAds.add(ad);
      _eventController.setupEvents(ad);

      await ad.load();
    }

    // init rewarded ads
    if (rewardedPlacementId != null &&
        _rewardedAds.doesNotContain(
          AdNetwork.facebook,
          AdUnitType.rewarded,
          rewardedPlacementId,
        )) {
      final ad = ApslFacebookFullScreenAd(
        adUnitId: rewardedPlacementId,
        adUnitType: AdUnitType.rewarded,
        preLoadRewardedAds: _preLoadRewardedAds,
      );
      _rewardedAds.add(ad);
      _eventController.setupEvents(ad);

      if (_preLoadRewardedAds) {
        await ad.load(); //dv removed preloading of rewarded ad
      }
    }
  }

  /// Displays [adUnitType] ad from [adNetwork]. It will check if first ad it found from list is loaded,
  /// it will be displayed if [adNetwork] is not mentioned otherwise it will load the ad.
  ///
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  /// if [adNetwork] is provided, only that network's ad would be displayed
  /// if [shouldShowLoader] before interstitial. If it's true, you have to provide build context.

  bool showAd(
    AdUnitType adUnitType, {
    AdNetwork adNetwork = AdNetwork.any,
    bool shouldShowLoader = false,
    int delayInSeconds = 2,
    BuildContext? context,
  }) {
    try {
      final ad = _fetchAdByTypeAndNetwork(adUnitType, adNetwork);

      _logger.logInfo("message: ${ad?.adNetwork} ${ad?.adUnitType} $ad");

      if (ad == null || !ad.isAdLoaded) {
        _logger.logInfo(
            '${ad?.adNetwork ?? 'No ad'} $adUnitType was not loaded, so called loading');
        ad?.load();
        if (adNetwork == AdNetwork.any) _updateAdIndex(adUnitType);
        return false;
      }

      if (adNetwork == AdNetwork.any || adNetwork == ad.adNetwork) {
        if (ad.adUnitType == AdUnitType.interstitial &&
            shouldShowLoader &&
            context != null) {
          showAutoHideLoaderDialog(context, delay: delayInSeconds)
              .then((_) => ad.show());
        } else {
          ad.show();
        }
        if (adNetwork == AdNetwork.any) _updateAdIndex(adUnitType);
        return true;
      }
    } catch (e) {
      _logger.logInfo('Error in showing ad: $e'); // log the exception
      return false;
    }

    return false;
  }

  /// Displays a Rewarded ad from [adNetwork]. If [adNetwork] is not specified,
  /// the function will attempt to display the first loaded ad from the list.
  /// If [adNetwork] is specified, only that network's ad will be displayed.
  ///
  /// Returns `true` if the ad was successfully displayed, `false` otherwise.

  bool loadAndShowRewardedAd({
    required BuildContext context,
    AdNetwork adNetwork = AdNetwork.any,
  }) {
    try {
      final ad = _fetchAdByTypeAndNetwork(AdUnitType.rewarded, adNetwork);
      ad?.load();

      showLoaderDialog(context);

      _streamSubscription?.cancel();
      _streamSubscription = ApslAds.instance.onEvent.listen((event) {
        if (event.adUnitType == AdUnitType.rewarded) {
          _logger.logInfo(
              "message: ${event.adNetwork} ${event.adUnitType} $event");

          if (event.type == AdEventType.adLoaded) {
            _updateAdIndex(AdUnitType.rewarded);
            hideLoaderDialog();
            ad?.show();
          } else if (event.type == AdEventType.adFailedToLoad) {
            _updateAdIndex(AdUnitType.rewarded);
            hideLoaderDialog();
          }
        }
      });
    } catch (e) {
      _logger.logInfo("Error in showing rewarded ad: $e"); // log the extention
      return false;
    }
    return false;
  }

  ApslAdBase? _fetchAdByTypeAndNetwork(
      AdUnitType adUnitType, AdNetwork adNetwork) {
    final mapForAds = {
      AdUnitType.rewarded: _rewardedAds,
      AdUnitType.interstitial: _interstitialAds,
      AdUnitType.appOpen: _appOpenAds,
    };
    final mapForIndexes = {
      AdUnitType.rewarded: _rewardedAdIndex,
      AdUnitType.interstitial: _interstitialAdIndex,
      AdUnitType.appOpen: _appOpenAdIndex,
    };

    final ads = mapForAds[adUnitType];
    final index = mapForIndexes[adUnitType];

    return adNetwork != AdNetwork.any
        ? ads?.firstWhereOrNull((e) => adNetwork == e.adNetwork)
        : ads != null && ads.isNotEmpty
            ? ads[index!]
            : null;
  }

  /// This will load both rewarded and interstitial ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad will be loaded
  /// if [adUnitType] is provided, only that unit type will be loaded, otherwise all unit types will be loaded
  void loadAd({AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    if (adUnitType == null || adUnitType == AdUnitType.rewarded) {
      for (final e in _rewardedAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }

    if (adUnitType == null || adUnitType == AdUnitType.interstitial) {
      for (final e in _interstitialAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }

    if (adUnitType == null || adUnitType == AdUnitType.appOpen) {
      for (final e in _appOpenAds) {
        if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
          e.load();
        }
      }
    }
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isRewardedAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _rewardedAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isInterstitialAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _interstitialAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isAppOpenAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _appOpenAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Do not call this method until unless you want to remove ads entirely from the app.
  /// Best user case for this method could be removeAds In app purchase.
  ///
  /// After this, ads would stop loading. You would have to call initialize again.
  ///
  /// if [adNetwork] is provided only that network's ads will be disposed otherwise it will be ignored
  /// if [adUnitType] is provided only that ad unit type will be disposed, otherwise it will be ignored
  void destroyAds(
      {AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    for (final e in _allAds) {
      if ((adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
          (adUnitType == null || adUnitType == e.adUnitType)) {
        e.dispose();
      }
    }
  }

  /// This method is used to show navigation ad after every [showNavigationAdAfterCount] navigation
  /// if [showNavigationAdAfterCount] is not provided, it will show ad after every 1 navigation
  /// This will only show interstitial ad
  bool showAdOnNavigation() {
    if (_navigationCount % (_showNavigationAdAfterCount) == 0) {
      _navigationCount++;
      return showAd(AdUnitType.interstitial);
    } else {
      _navigationCount++;
      return false;
    }
  }

  /// Update add index count after showing ad
  /// This method is called automatically after showing ad
  void _updateAdIndex(AdUnitType adUnitType) {
    switch (adUnitType) {
      case AdUnitType.rewarded:
        _rewardedAdIndex++;
        if (_rewardedAdIndex >= _rewardedAds.length) {
          _rewardedAdIndex = 0;
        }
        break;
      case AdUnitType.interstitial:
        _interstitialAdIndex++;
        if (_interstitialAdIndex >= _interstitialAds.length) {
          _interstitialAdIndex = 0;
        }
        break;
      case AdUnitType.appOpen:
        _appOpenAdIndex++;
        if (_appOpenAdIndex >= _appOpenAds.length) {
          _appOpenAdIndex = 0;
        }
        break;
      default:
        break;
    }
  }
}
