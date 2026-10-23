import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const adMobAppId = 'ca-app-pub-2119321376671262~7906090260';
const bannerAdUnitId = 'ca-app-pub-2119321376671262/2214779887';
const interstitialAdUnitId = 'ca-app-pub-2119321376671262/6401436902';

final RouteObserver<PageRoute<dynamic>> adRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

class AdService with WidgetsBindingObserver {
  AdService._();

  static final AdService instance = AdService._();

  static const _interval = Duration(minutes: 5);
  static const _gapAfterAd = Duration(seconds: 45);

  InterstitialAd? _interstitial;
  Timer? _timer;
  var _initialized = false;
  var _loading = false;
  var _showing = false;
  var _foreground = true;
  var _showWhenLoaded = false;
  var _pendingPeriodic = false;
  var _failures = 0;
  var _observed = false;
  Duration _accrued = Duration.zero;
  DateTime _foregroundSince = DateTime.now();
  DateTime? _shownAt;

  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;
    try {
      await MobileAds.instance.initialize();
    } catch (error, stack) {
      debugPrint('AdMob init failed: $error\n$stack');
      return;
    }
    _initialized = true;
    if (!_observed) {
      WidgetsBinding.instance.addObserver(this);
      _observed = true;
    }
    _foregroundSince = DateTime.now();
    _loadInterstitial();
    _timer ??= Timer.periodic(const Duration(seconds: 15), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (_foreground && !resumed) {
      _accrued += DateTime.now().difference(_foregroundSince);
    } else if (!_foreground && resumed) {
      _foregroundSince = DateTime.now();
      if (_interstitial == null) _loadInterstitial();
    }
    _foreground = resumed;
  }

  /// Shows an interstitial for an image download. Completes when that ad
  /// closes, or immediately when one cannot be shown yet.
  Future<void> showForDownload() {
    if (!isSupported || _showing) return Future<void>.value();
    if (!_initialized) {
      _showWhenLoaded = true;
      return Future<void>.value();
    }
    final ad = _interstitial;
    if (ad == null) {
      _showWhenLoaded = true;
      _loadInterstitial();
      return Future<void>.value();
    }
    return _present(ad);
  }

  void _tick() {
    if (!_initialized || !_foreground || _showing) return;
    final used = _accrued + DateTime.now().difference(_foregroundSince);
    if (used < _interval || _recentlyShown) return;
    final ad = _interstitial;
    if (ad == null) {
      _pendingPeriodic = true;
      _loadInterstitial();
      return;
    }
    _pendingPeriodic = false;
    _accrued = Duration.zero;
    _foregroundSince = DateTime.now();
    _present(ad);
  }

  bool get _recentlyShown {
    final shown = _shownAt;
    return shown != null && DateTime.now().difference(shown) < _gapAfterAd;
  }

  Future<void> _present(InterstitialAd ad) {
    final completer = Completer<void>();
    _showWhenLoaded = false;
    if (identical(_interstitial, ad)) _interstitial = null;
    _showing = true;
    _shownAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        if (!completer.isCompleted) completer.complete();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        _showing = false;
        if (!completer.isCompleted) completer.complete();
        _loadInterstitial();
      },
    );
    try {
      ad.show();
    } catch (error) {
      debugPrint('Interstitial show threw: $error');
      ad.dispose();
      _showing = false;
      if (!completer.isCompleted) completer.complete();
      _loadInterstitial();
    }
    return completer.future;
  }

  void _loadInterstitial() {
    if (!_initialized || _loading || _interstitial != null || _showing) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _failures = 0;
          final wantsNow =
              (_showWhenLoaded || _pendingPeriodic) && _foreground && !_showing;
          if (wantsNow) {
            if (_pendingPeriodic) {
              _accrued = Duration.zero;
              _foregroundSince = DateTime.now();
            }
            _pendingPeriodic = false;
            _present(ad);
            return;
          }
          _interstitial?.dispose();
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('Interstitial failed to load: $error');
          _failures += 1;
          if (_failures > 8) return;
          final seconds = (4 * _failures).clamp(4, 60);
          Future<void>.delayed(Duration(seconds: seconds), () {
            if (_interstitial == null && !_showing) _loadInterstitial();
          });
        },
      ),
    );
  }
}
