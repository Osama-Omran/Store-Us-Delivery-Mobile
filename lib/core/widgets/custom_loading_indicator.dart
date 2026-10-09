import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LottieBuilder.asset(
        AppAssets.loading,
        frameRate: const FrameRate(900),
      ),
    );
  }
}
