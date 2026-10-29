import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';
import 'receiving_proof_photo.dart';
import 'confirm_receiving_bottom_sheet.dart';

class ReceiveTripConfirmBar extends StatelessWidget {
  const ReceiveTripConfirmBar({
    super.key,
    required this.approvedProof,
    required this.onConfirm,
  });
  final ReceivingProofModel? approvedProof;
  final ValueChanged<ReceiveTripSuccessState> onConfirm;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ReceiveTripCubit, ReceiveTripState>(
        builder: (context, state) {
          if (state is! ReceiveTripSuccessState) {
            return const SizedBox.shrink();
          }

          final isPending =
              state.trip.acceptance?.status.toUpperCase() == 'PENDING';

          if (!isPending) {
            return const SizedBox.shrink();
          }

          final isAccepting =
              state.acceptTripStatus == AcceptTripStatus.loading;

          final isProofApproved =
              approvedProof != null &&
              approvedProof!.tripNumber == state.trip.number;

          return ConfirmReceivingBottomSheet(
            isProofApproved: isProofApproved,
            isLoading: isAccepting,
            onConfirm: isProofApproved && !isAccepting
                ? () => onConfirm(state)
                : null,
          );
        },
      );
}
