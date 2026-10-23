import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key, this.onHeight, this.background});

  final ValueChanged<double>? onHeight;
  final Color? background;

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> with RouteAware {
  BannerAd? _ad;
  var _loaded = false;
  var _failures = 0;
  var _subscribed = false;
  double? _width;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      adRouteObserver.subscribe(this, route);
      _subscribed = true;
    }
    final width = MediaQuery.sizeOf(context).width;
    final previous = _width;
    _width = width;
    if (previous != null && (width - previous).abs() > 1 && _ad != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _release();
        unawaited(_load());
      });
    }
  }

  @override
  void didPushNext() => _release();

  @override
  void didPopNext() => unawaited(_load());

  Future<void> _load() async {
    if (!mounted || _ad != null || !AdService.instance.isSupported) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0) return;

    AdSize? size;
    try {
      size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    } catch (error) {
      debugPrint('Banner size failed: $error');
      return;
    }
    if (!mounted || _ad != null || ModalRoute.of(context)?.isCurrent == false) {
      return;
    }

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
          widget.onHeight?.call((ad as BannerAd).size.height.toDouble());
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            if (identical(_ad, ad)) _ad = null;
            _loaded = false;
          });
          widget.onHeight?.call(0);
          _failures += 1;
          if (_failures > 6) return;
          Future<void>.delayed(Duration(seconds: 8 * _failures), () {
            if (mounted && _ad == null) unawaited(_load());
          });
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  void _release() {
    final ad = _ad;
    _ad = null;
    _loaded = false;
    widget.onHeight?.call(0);
    if (!mounted) {
      ad?.dispose();
      return;
    }
    setState(() {});
    if (ad != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ad.dispose());
    }
  }

  @override
  void dispose() {
    if (_subscribed) adRouteObserver.unsubscribe(this);
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return ColoredBox(
      color: widget.background ?? Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}
