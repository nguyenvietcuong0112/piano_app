import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'easy_loading_splash.dart';
import '../easy_ads.dart';

class EasyRewardAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final void Function()? onShowed;
  final void Function()? onFailed;
  final void Function()? adDismissed;
  const EasyRewardAd({
    Key? key,
    this.adNetwork = AdNetwork.admob,
    required this.adId,
    this.onShowed,
    this.adDismissed,
    this.onFailed,
  }) : super(key: key);

  @override
  State<EasyRewardAd> createState() => _EasyRewardAdState();
}

class _EasyRewardAdState extends State<EasyRewardAd>
    with WidgetsBindingObserver {
  late final EasyAdBase? _rewardAd = EasyAds.instance.createReward(
    adNetwork: widget.adNetwork,
    adId: widget.adId,
    immersiveModeEnabled: true,
  );

  StreamSubscription? _streamSubscription;

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _rewardAd?.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    EasyAds.instance.setFullscreenAdShowing(true);
    _rewardAd?.load();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      final resolvedId = EasyAds.instance.resolveAdUnitId(widget.adId);
      if (event.adUnitType == AdUnitType.rewarded &&
          (event.adUnitId == widget.adId || event.adUnitId == resolvedId)) {
        switch (event.type) {
          case AdEventType.adLoaded:
            if (_appLifecycleState == AppLifecycleState.resumed) {
              _showAd();
            } else {
              _adFailedToShow = true;
            }
            break;
          case AdEventType.adShowed:
            widget.onShowed?.call();
            break;
          case AdEventType.adFailedToLoad:
            EasyAds.instance.setFullscreenAdShowing(false);
            _streamSubscription?.cancel();
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            widget.onFailed?.call();
            break;
          case AdEventType.adDismissed:
            EasyAds.instance.setFullscreenAdShowing(false);
            _streamSubscription?.cancel();
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            widget.adDismissed?.call();
            break;
          case AdEventType.adFailedToShow:
            if (_appLifecycleState != AppLifecycleState.resumed) {
              _adFailedToShow = true;
            } else {
              EasyAds.instance.setFullscreenAdShowing(false);
              _streamSubscription?.cancel();
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              widget.onFailed?.call();
            }
            break;
          default:
            break;
        }
      }
    });
    super.initState();
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rewardAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: EasyLoadingSplash(
        customSplash: EasyAds.configuredLoadingSplash,
        message: EasyAds.configuredLoadingMessage,
      ),
    );
  }
}
