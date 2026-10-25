import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class DeliveryProofDraft {
  const DeliveryProofDraft({this.photo, this.signature = const []});

  final XFile? photo;
  final List<List<Offset>> signature;

  bool get hasProof => photo != null || signature.isNotEmpty;
}

class DeliveryProofScreen extends StatefulWidget {
  const DeliveryProofScreen({super.key});

  @override
  State<DeliveryProofScreen> createState() => _DeliveryProofScreenState();
}

class _DeliveryProofScreenState extends State<DeliveryProofScreen> {
  XFile? _photo;
  final List<List<Offset>> _strokes = [];

  Future<void> _capturePhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (!mounted || image == null) return;

      setState(() => _photo = image);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.delivery_photo_capture_failed)),
      );
    }
  }

  void _finish() {
    context.pop(
      DeliveryProofDraft(
        photo: _photo,
        signature: [for (final stroke in _strokes) List<Offset>.from(stroke)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProof = _photo != null || _strokes.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.grey0,
        appBar: AppBar(
          title: Text(context.strings.delivery_proof_title),
          backgroundColor: AppColors.grey0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ======= Photo ======= //
            _ProofCard(
              title: context.strings.delivery_proof_photo,
              child: InkWell(
                onTap: _capturePhoto,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 190,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blue4,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.blue3),
                  ),
                  child: _photo == null
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
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(_photo!.path),
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ======= Signature ======= //
            _ProofCard(
              title: context.strings.delivery_customer_signature,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _strokes.add([details.localPosition]);
                      });
                    },
                    onPanUpdate: (details) {
                      if (_strokes.isEmpty) return;

                      setState(() {
                        _strokes.last.add(details.localPosition);
                      });
                    },
                    child: Container(
                      height: 175,
                      decoration: BoxDecoration(
                        color: AppColors.grey5,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          painter: _SignaturePainter(_strokes),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(_strokes.clear);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(context.strings.delivery_clear_signature),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              context.strings.delivery_proof_not_uploaded,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey4, fontSize: 12),
            ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 65,
              child: ElevatedButton(
                onPressed: hasProof ? _finish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white0,
                ),
                child: Text(context.strings.delivery_save_local_proof),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
            style: TextStyle(
              fontSize: 18,
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
