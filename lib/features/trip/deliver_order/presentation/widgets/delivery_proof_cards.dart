import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class DeliveryProofPhotoCard extends StatelessWidget {
  const DeliveryProofPhotoCard({
    super.key,
    required this.photo,
    required this.onCapture,
  });
  final XFile? photo;
  final VoidCallback onCapture;
  @override
  Widget build(BuildContext context) => _ProofCard(
    title: context.strings.delivery_proof_photo,
    child: InkWell(
      onTap: onCapture,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.blue4,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.blue3),
        ),
        child: photo == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                    size: 42,
                  ),
                  Text(
                    context.strings.delivery_take_photo,
                    style: Styles.base.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(photo!.path),
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    ),
  );
}

class DeliverySignatureCard extends StatelessWidget {
  const DeliverySignatureCard({
    super.key,
    required this.strokes,
    required this.onStart,
    required this.onUpdate,
    required this.onClear,
  });
  final List<List<Offset>> strokes;
  final GestureDragStartCallback onStart;
  final GestureDragUpdateCallback onUpdate;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => _ProofCard(
    title: context.strings.delivery_customer_signature,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onPanStart: onStart,
          onPanUpdate: onUpdate,
          child: Container(
            height: 175,
            decoration: BoxDecoration(
              color: AppColors.grey5,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _SignaturePainter(strokes),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh),
            label: Text(context.strings.delivery_clear_signature),
          ),
        ),
      ],
    ),
  );
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(
            title,
            style: Styles.textStyle18.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black1
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);

      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
