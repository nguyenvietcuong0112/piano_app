import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../constants/app_constants.dart';

class RewardedAdService {
  static void showRewardedAd({
    required BuildContext context,
    required String songId,
    required VoidCallback onRewardEarned,
    VoidCallback? onFailed,
  }) {
    if (AppConstants.isPremiumUser.value) {
      onRewardEarned();
      return;
    }

    bool isRewardEarned = false;
    bool isHandled = false;
    StreamSubscription? subscription;

    void cleanup() {
      subscription?.cancel();
    }

    subscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.rewarded) {
        if (event.type == AdEventType.earnedReward) {
          isRewardEarned = true;
        } else if (event.type == AdEventType.adDismissed) {
          cleanup();
          if (!isHandled) {
            isHandled = true;
            if (isRewardEarned) {
              onRewardEarned();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Bạn cần xem hết quảng cáo để mở khóa bài hát'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              onFailed?.call();
            }
          }
        } else if (event.type == AdEventType.adFailedToShow ||
            event.type == AdEventType.adFailedToLoad) {
          cleanup();
          if (!isHandled) {
            isHandled = true;
            // Fallback for ad loading/showing error -> grant reward to avoid blocking user
            onRewardEarned();
          }
        }
      }
    });

    EasyAds.instance.showRewardAd(
      context,
      adId: MyAdIdName.rewardedAd.getId,
      adDissmissed: () {
        // Dismiss handled by onEvent listener
      },
      onFailed: () {
        cleanup();
        if (!isHandled) {
          isHandled = true;
          onRewardEarned();
        }
      },
    );
  }
}
