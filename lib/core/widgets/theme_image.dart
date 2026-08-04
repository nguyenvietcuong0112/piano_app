import 'package:flutter/material.dart';

class ThemeImage extends StatelessWidget {
  final String resName;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ThemeImage({
    super.key,
    required this.resName,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (resName.startsWith('assets/')) {
      return Image.asset(
        resName,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: const Color(0xFF181820)),
      );
    }

    // Attempt 1: assets/themes/backgrounds/$resName.webp
    return Image.asset(
      'assets/themes/backgrounds/$resName.webp',
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        // Attempt 2: assets/images/$resName.jpg
        'assets/images/$resName.jpg',
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, err, stack) => Image.asset(
          // Attempt 3: assets/images/$resName.png
          'assets/images/$resName.png',
          fit: fit,
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
