import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ===== Background =====
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashGradientStart,
                AppColors.primary,
                AppColors.splashGradientEnd,
              ],
              stops: [0, .55, 1],
            ),
          ),
        ),

        // ===== Top decorative circles =====
        Positioned(
          top: -width * .57,
          right: -width * .43,
          child: _SplashCircle(
            size: width * 1.22,
            fillColor: AppColors.splashCircleLight.withValues(alpha: .17),
            borderColor: AppColors.white0.withValues(alpha: .16),
          ),
        ),

        Positioned(
          top: -width * .39,
          right: -width * .26,
          child: _SplashCircle(
            size: width * .92,
            fillColor: AppColors.transparent,
            borderColor: AppColors.white0.withValues(alpha: .13),
          ),
        ),

        // ===== Bottom decorative circles =====
        Positioned(
          bottom: -width * .58,
          left: -width * .47,
          child: _SplashCircle(
            size: width * 1.1,
            fillColor: AppColors.splashCircleDark.withValues(alpha: .47),
            borderColor: AppColors.white0.withValues(alpha: .10),
          ),
        ),

        Positioned(
          bottom: -width * .43,
          left: -width * .30,
          child: _SplashCircle(
            size: width * .76,
            fillColor: AppColors.transparent,
            borderColor: AppColors.white0.withValues(alpha: .09),
          ),
        ),
      ],
    );
  }
}

class _SplashCircle extends StatelessWidget {
  const _SplashCircle({
    required this.size,
    required this.fillColor,
    required this.borderColor,
  });

  final double size;
  final Color fillColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.5),
      ),
    );
  }
}
