import 'package:flutter/material.dart';
import '../../core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'splash_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  final VoidCallback? onFinished;
  const SplashPage({Key? key, this.onFinished}) : super(key: key);

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider).init(
        context,
        onFinished: widget.onFinished ?? () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/bg_splash.webp",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.background),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/png/splash_thumb.png",
                        width: 121,
                        height: 121,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.piano, size: 80, color: Colors.amber),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Real Piano",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: Column(
                      children: [
                        const Text(
                          "This action can contain advertising",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: const AppLoading(width: 80, height: 80),
                        ),
                        if (!AppConstants.isPremiumUser.value) ...[
                          const SizedBox(height: 10),
                          EasyBannerAd(
                            adId: MyAdIdName.bannerSplash.getId,
                            adIdName: MyAdIdName.bannerSplash,
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
