import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../widgets/delivery_proof_cards.dart';

import 'package:storeus_delivery/core/theme/text_styles.dart';

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
            DeliveryProofPhotoCard(photo: _photo, onCapture: _capturePhoto),

            const SizedBox(height: 18),

            // ======= Signature ======= //
            DeliverySignatureCard(
              strokes: _strokes,
              onStart: (details) =>
                  setState(() => _strokes.add([details.localPosition])),
              onUpdate: (details) {
                if (_strokes.isEmpty) return;
                setState(() => _strokes.last.add(details.localPosition));
              },
              onClear: () => setState(_strokes.clear),
            ),

            const SizedBox(height: 16),

            Text(
              context.strings.delivery_proof_not_uploaded,
              textAlign: TextAlign.center,
              style: Styles.base.copyWith(color: AppColors.grey4, fontSize: 12),
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
