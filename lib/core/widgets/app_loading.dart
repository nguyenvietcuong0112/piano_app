import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoading extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const AppLoading({
    super.key,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/json/loading.json',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFFCF6BEE),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
