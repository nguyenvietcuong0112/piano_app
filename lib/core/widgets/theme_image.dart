import 'package:flutter/material.dart';
import 'app_loading.dart';

class ThemeImage extends StatelessWidget {
  final String resName;
  final String? folder;
  final BoxFit fit;
  final BoxFit overlayFit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final bool showOverlay;

  const ThemeImage({
    super.key,
    required this.resName,
    this.folder,
    this.fit = BoxFit.cover,
    this.overlayFit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget baseImage;

    // 1. Network Image (HTTP/HTTPS) with fit crop & center alignment
    if (resName.startsWith('http://') || resName.startsWith('https://')) {
      baseImage = Image.network(
        resName,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF141126),
            child: const AppLoading(width: 40, height: 40),
          );
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/themes/default/theme_1.webp',
          fit: fit,
          alignment: alignment,
          width: width,
          height: height,
          errorBuilder: (context, e, s) => Container(
            color: const Color(0xFF181820),
          ),
        ),
      );
    } else if (resName.startsWith('assets/')) {
      // 2. Direct Asset Path
      baseImage = Image.asset(
        resName,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: const Color(0xFF181820)),
      );
    } else {
      final catFolder = folder ?? 'default';

      // 3. Local Theme Asset Resolution
      baseImage = Image.asset(
        'assets/themes/$catFolder/$resName.webp',
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/themes/default/$resName.webp',
          fit: fit,
          alignment: alignment,
          width: width,
          height: height,
          errorBuilder: (context, err, stack) => Image.asset(
            'assets/themes/default/theme_1.webp',
            fit: fit,
            alignment: alignment,
            width: width,
            height: height,
            errorBuilder: (context, e, s) => Container(
              color: const Color(0xFF181820),
            ),
          ),
        ),
      );
    }

    if (!showOverlay) {
      return baseImage;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: baseImage),
        Positioned.fill(
          child: Image.asset(
            'assets/images/img_vector_piano.png',
            fit: overlayFit,
          ),
        ),
      ],
    );
  }
}
