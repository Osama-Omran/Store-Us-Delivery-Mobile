import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:vibration/vibration.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    this.animated,
    this.vibrate,
    this.strongVibrate,
    this.text,
    this.margin,
    this.isActive,
    this.icon,
    this.circular,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.radius,
    this.spacing,
    this.borderThickness,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.shrink,
    this.withShadow = true,
    this.icon1st,
    this.onTapDown,
    this.alignment,
  });
  final void Function()? onPressed;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final bool? animated, vibrate, strongVibrate, isActive, icon1st;
  final String? text;
  final dynamic margin, padding;
  final Widget? icon;
  final bool? circular, shrink;
  final bool withShadow;
  final double? width, height, radius, spacing, borderThickness;
  final Color? color, borderColor;
  final TextStyle? textStyle;
  final void Function(Alignment alignment)? onTapDown;
  final MainAxisAlignment? alignment;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final tapPosition = details.globalPosition;
        final screenSize = MediaQuery.of(context).size;

        final alignment = Alignment(
          (tapPosition.dx / screenSize.width) * 2 - 1,
          (tapPosition.dy / screenSize.height) * 2 - 1,
        );

        widget.onTapDown?.call(alignment);

        if (widget.vibrate != false && widget.strongVibrate != true) {
          HapticFeedback.lightImpact();
        }

        if (widget.strongVibrate == true) {
          Vibration.vibrate(duration: 300, amplitude: 255);
        }
        widget.animated == false || widget.isActive == false
            ? null
            : (_) => setState(() => scale = 0.95);
      },
      onTapUp: widget.animated == false || widget.isActive == false
          ? null
          : (_) => setState(() => scale = 1),
      onTapCancel: widget.animated == false || widget.isActive == false
          ? null
          : () => setState(() => scale = 1),
      onLongPressStart: widget.onLongPressStart,
      onLongPressEnd: widget.onLongPressEnd,
      onTap: widget.isActive == false
          ? null
          : () {
              widget.onPressed?.call();
              if (widget.vibrate != false && widget.strongVibrate != true) {
                HapticFeedback.lightImpact();
              }
              if (widget.strongVibrate == true) {
                Vibration.vibrate(duration: 300, amplitude: 255);
              }
            },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: widget.margin is EdgeInsetsGeometry
              ? widget.margin
              : widget.margin is num
              ? EdgeInsets.all(widget.margin.toDouble())
              : null,
          padding: widget.padding is EdgeInsetsGeometry
              ? widget.padding
              : widget.padding is num
              ? EdgeInsets.all(widget.padding.toDouble())
              : null,
          height: widget.height ?? 56,
          width: widget.shrink == true ? null : widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: widget.isActive == false
                ? AppColors.grey2
                : widget.color ?? AppColors.primary,
            borderRadius: widget.circular == true
                ? null
                : BorderRadius.circular(widget.radius ?? 20),
            shape: widget.circular == true
                ? BoxShape.circle
                : BoxShape.rectangle,
            border: Border.all(
              color: widget.isActive == false
                  ? AppColors.grey2
                  : widget.borderColor ?? widget.color ?? AppColors.primary,
              width: widget.borderThickness ?? 1,
            ),
            boxShadow: [
              if (widget.withShadow == true)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 4), // changes position of shadow
                ),
            ],
          ),
          child: widget.shrink == true
              ? IntrinsicWidth(child: _buildChild())
              : _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() => Center(
    child: Row(
      spacing: widget.spacing ?? 8,
      mainAxisAlignment: widget.alignment ?? MainAxisAlignment.center,
      children: [
        if (widget.icon != null && widget.icon1st == true) widget.icon!,
        if (widget.text != null)
          Text(
            widget.text!,
            style:
                widget.textStyle ??
                Styles.textStyle16.copyWith(color: AppColors.white0),
          ),
        if (widget.icon != null && widget.icon1st != true) widget.icon!,
      ],
    ),
  );
}
