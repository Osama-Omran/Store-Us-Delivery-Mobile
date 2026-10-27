import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_image.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextRoute});

  final String nextRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final Timer _timer;
  late final AnimationController _floatingController;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        GoRouter.of(context).go(widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.splashNavigationBar,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = constraints.maxHeight < 700;

            final logoSize = (width * (isCompact ? .40 : .46)).clamp(
              145.0,
              205.0,
            );

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
                    fillColor: AppColors.splashCircleLight.withValues(
                      alpha: .17,
                    ),
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
                    fillColor: AppColors.splashCircleDark.withValues(
                      alpha: .47,
                    ),
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
                              animation: _floatingController,
                              builder: (context, child) {
                                final movement = Curves.easeInOut.transform(
                                  _floatingController.value,
                                );

                                return Transform.translate(
                                  offset: Offset(0, -4 * movement),
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ===== Logo Card =====
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.white0.withValues(
                                        alpha: .10,
                                      ),
                                      borderRadius: BorderRadius.circular(39),
                                      border: Border.all(
                                        color: AppColors.white0.withValues(
                                          alpha: .26,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.white0,
                                        borderRadius: BorderRadius.circular(31),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.splashShadow
                                                .withValues(alpha: .28),
                                            blurRadius: 38,
                                            offset: const Offset(0, 18),
                                          ),
                                        ],
                                      ),
                                      child: CustomImage(
                                        imagePath: AppAssets.logo,
                                        w: logoSize,
                                        h: logoSize,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 26),

                                  // ===== Decorative Divider =====
                                  Container(
                                    width: 36,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppColors.white0.withValues(
                                        alpha: .80,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    context.strings.splash_tagline,
                                    textAlign: TextAlign.center,
                                    style: Styles.base.copyWith(
                                      fontSize: isCompact ? 13 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white0.withValues(
                                        alpha: .90,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
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
        ),
      ),
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
