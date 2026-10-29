import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/splash/presentation/widgets/splash_background.dart';
import 'package:storeus_delivery/features/splash/presentation/widgets/splash_brand.dart';

class SplashBody extends StatelessWidget {
  const SplashBody({super.key, required this.floatingAnimation});

  final Animation<double> floatingAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = constraints.maxHeight < 700;

        final logoSize = (width * (isCompact ? .40 : .46)).clamp(145.0, 205.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            SplashBackground(width: width),

            // ===== Foreground =====
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: child,
                            ),
                          );
                        },
                        child: AnimatedBuilder(
                          animation: floatingAnimation,
                          builder: (context, child) {
                            final movement = Curves.easeInOut.transform(
                              floatingAnimation.value,
                            );

                            return Transform.translate(
                              offset: Offset(0, -4 * movement),
                              child: child,
                            );
                          },
                          child: SplashBrand(
                            logoSize: logoSize,
                            isCompact: isCompact,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== Bottom Loading =====
                  Padding(
                    padding: EdgeInsets.only(bottom: isCompact ? 14 : 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomLoadingIndicator(size: 88),

                        const SizedBox(height: 8),

                        Text(
                          context.strings.splash_loading,
                          textAlign: TextAlign.center,
                          style: Styles.textStyle13.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.white0.withValues(alpha: .80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
