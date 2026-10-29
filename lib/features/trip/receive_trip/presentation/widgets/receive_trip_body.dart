import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';
import 'receive_trip_content.dart';
import 'receive_trip_shimmer.dart';
import 'receiving_proof_photo.dart';

class ReceiveTripBody extends StatelessWidget {
  const ReceiveTripBody({super.key, required this.onProofChanged});
  final ValueChanged<ReceivingProofModel?> onProofChanged;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ReceiveTripCubit, ReceiveTripState>(
        buildWhen: (previous, current) =>
            previous is! ReceiveTripSuccessState ||
            current is! ReceiveTripSuccessState ||
            previous.trip != current.trip ||
            previous.acceptTripStatus != current.acceptTripStatus,
        builder: (context, state) {
          // ======= Loading ======= //
          if (state is ReceiveTripInitial || state is ReceiveTripLoadingState) {
            return const ReceiveTripShimmer();
          }

          // ======= Failure ======= //
          if (state is ReceiveTripFailureState) {
            return _ReceiveTripMessage(
              message: state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage!
                  : context.strings.current_trip_load_failed,
              onRetry: () {
                ReceiveTripCubit.get(context).getCurrentTrip();
              },
            );
          }

          // ======= Empty ======= //
          if (state is ReceiveTripEmptyState) {
            return _ReceiveTripMessage(
              message: context.strings.current_trip_empty,
              onRetry: () {
                ReceiveTripCubit.get(context).getCurrentTrip();
              },
            );
          }

          // ======= Success ======= //
          if (state is ReceiveTripSuccessState) {
            return ReceiveTripContent(onProofChanged: onProofChanged);
          }

          return const SizedBox.shrink();
        },
      );
}

// ======= Empty & Failure Widget ======= //
class _ReceiveTripMessage extends StatelessWidget {
  const _ReceiveTripMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              context.localizedErrorMessage(message),
              textAlign: TextAlign.center,
            ),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.strings.current_trip_retry),
            ),
          ],
        ),
      ),
    );
  }
}
