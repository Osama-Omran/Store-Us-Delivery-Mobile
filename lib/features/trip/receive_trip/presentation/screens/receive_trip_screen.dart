import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_goods_details.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_data.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_receiving_confirmation_sheet.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/van_products.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/confirm_receiving_bottom_sheet.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_proof_photo.dart';

class ReceiveTripScreen extends StatefulWidget {
  const ReceiveTripScreen({super.key});

  @override
  State<ReceiveTripScreen> createState() => _ReceiveTripScreenState();
}

class _ReceiveTripScreenState extends State<ReceiveTripScreen> {
  ReceivingProofModel? _approvedProof;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.strings.confirm_receiving_van),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TripData(),
          const Gap(24),
          const LoadedGoodsDetails(),
          const Gap(16),
          const VanProducts(),
          const Gap(24),
          ReceivingProofPhoto(
            tripNumber: 'TRIP-0025',
            onPhotoApprovalChanged: (proof) {
              setState(() {
                _approvedProof = proof;
              });
            },
          ),
          const Gap(24),
        ],
      ),
      bottomNavigationBar: ConfirmReceivingBottomSheet(
        isProofApproved: _approvedProof != null,
        onConfirm: _approvedProof == null
            ? null
            : () async {
                final proof = _approvedProof;
                if (proof == null) return;

                final confirmed = await showTripReceivingConfirmationSheet(
                  context: context,
                  tripNumber: proof.tripNumber,
                );

                if (!context.mounted || confirmed != true) return;

                // TODO: Call API to confirm receiving trip
                // Send trip number and approved proof photo
              },
      ),
    );
  }
}
