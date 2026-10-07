import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSVG extends StatelessWidget {
  const CustomSVG({
    super.key,
    required this.assetName,
    this.w,
    this.h,
    this.color,
    this.fit,
  });

  final String assetName;
  final double? w, h;
  final Color? color;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h,
      width: w,
      child: SvgPicture.asset(
        assetName,
        width: w,
        height: h,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit ?? BoxFit.contain,
      ),
    );
  }
}
