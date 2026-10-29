import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';
import 'loaded_items_section.dart';
import 'receiving_proof_photo.dart';
import 'trip_data.dart';

class ReceiveTripContent extends StatelessWidget {
  const ReceiveTripContent({super.key, required this.onProofChanged});
  final ValueChanged<ReceivingProofModel?> onProofChanged;

  @override
  Widget build(BuildContext context) {
    final state = ReceiveTripCubit.get(context).state;
    if (state is! ReceiveTripSuccessState) return const SizedBox.shrink();
    final isPending = state.trip.acceptance?.status.toUpperCase() == 'PENDING';
    final isAccepting = state.acceptTripStatus == AcceptTripStatus.loading;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ======= Trip Information ======= //
        const TripData(),

        const Gap(24),

        // ======= Loaded Items ======= //
        const LoadedItemsSection(),

        const Gap(24),

        // ======= Receiving Proof Photo ======= //
        if (isPending) ...[
          IgnorePointer(
            ignoring: isAccepting,
            child: ReceivingProofPhoto(
              key: ValueKey(state.trip.id),
              tripNumber: state.trip.number,
              onPhotoApprovalChanged: onProofChanged,
            ),
          ),
          const Gap(24),
        ],
      ],
    );
  }
}
