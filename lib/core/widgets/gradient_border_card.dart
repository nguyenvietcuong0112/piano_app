import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double strokeWidth;
  final Gradient? backgroundGradient;
  final Gradient? borderGradient;
  final String? bgImageAsset;
  final String? bgImageUrl;
  final BoxFit imageFit;
  final double imageOpacity;
  final VoidCallback? onTap;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.strokeWidth = 1.0,
    this.backgroundGradient,
    this.borderGradient,
    this.bgImageAsset,
    this.bgImageUrl,
    this.imageFit = BoxFit.fill, // fitXY
    this.imageOpacity = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgGradient = backgroundGradient ??
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF141126),
            AppColors.background,
          ],
        );

    final effectiveBorderGradient = borderGradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            Color(0x80FFFFFF),
            Color(0x00FFFFFF),
            Color(0x80AD57E6),
          ],
        );

    // Build Background Image Widget if provided
    Widget? bgImageWidget;
    if (bgImageAsset != null && bgImageAsset!.isNotEmpty) {
      bgImageWidget = Opacity(
        opacity: imageOpacity,
        child: Image.asset(
          bgImageAsset!,
          width: double.infinity,
          height: double.infinity,
          fit: imageFit, // BoxFit.fill = fitXY
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    } else if (bgImageUrl != null && bgImageUrl!.isNotEmpty) {
      bgImageWidget = Opacity(
        opacity: imageOpacity,
        child: Image.network(
          bgImageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: imageFit, // BoxFit.fill = fitXY
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    }

    Widget innerContent = Stack(
      children: [
        if (bgImageWidget != null)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius.r),
              child: bgImageWidget,
            ),
          ),
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ],
    );

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        gradient: bgImageWidget == null ? effectiveBgGradient : null,
      ),
      child: CustomPaint(
        painter: GradientBorderPainter(
          radius: borderRadius.r,
          strokeWidth: strokeWidth,
          gradient: effectiveBorderGradient,
        ),
        child: innerContent,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
