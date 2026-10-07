import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class CustomInkWell extends StatefulWidget {
  const CustomInkWell({
    super.key,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onTap,
    this.vibrate,
    this.strongVibrate,
    this.child,
    this.borderRadius,
    this.withEffect,
    this.onTapDown,
  });

  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final void Function()? onTap;
  final void Function(Alignment alignment)? onTapDown;
  final bool? vibrate, strongVibrate, withEffect;
  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  State<CustomInkWell> createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: widget.withEffect == false ? Colors.transparent : null,
        highlightColor: widget.withEffect == false ? Colors.transparent : null,
        hoverColor: widget.withEffect == false ? Colors.transparent : null,
        focusColor: widget.withEffect == false ? Colors.transparent : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),

        onHighlightChanged: (isPressed) {
          setState(() => scale = isPressed ? 0.95 : 1);
        },
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
        },
        onTap: () {
          widget.onTap?.call();

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
          child: widget.child,
        ),
      ),
    );
  }
}
