import 'package:flutter/material.dart';
import 'app_loading.dart';

class ThemeImage extends StatelessWidget {
  final String resName;
  final String? folder;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  const ThemeImage({
    super.key,
    required this.resName,
    this.folder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Network Image (HTTP/HTTPS) with fit crop & center alignment
    if (resName.startsWith('http://') || resName.startsWith('https://')) {
      return Image.network(
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
    }

    // 2. Direct Asset Path
    if (resName.startsWith('assets/')) {
      return Image.asset(
        resName,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: const Color(0xFF181820)),
      );
    }

    final catFolder = folder ?? 'default';

    // 3. Local Theme Asset Resolution
    return Image.asset(
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
}
