
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';

import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_cubit.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_state.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/confirm_receiving_bottom_sheet.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/loaded_items_section.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/receiving_proof_photo.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_data.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/widgets/trip_receiving_confirmation_sheet.dart';

class ReceiveTripScreen extends StatefulWidget {
  const ReceiveTripScreen({super.key});

  @override
  State<ReceiveTripScreen> createState() =>
      _ReceiveTripScreenState();
}

class _ReceiveTripScreenState extends State<ReceiveTripScreen> {
  ReceivingProofModel? _approvedProof;

  // ======= Confirm Receiving ======= //
  Future<void> _confirmReceiving(
      ReceiveTripSuccessState state,
      ) async {
    final proof = _approvedProof;

    if (proof == null ||
        proof.tripNumber != state.trip.number ||
        state.acceptTripStatus == AcceptTripStatus.loading) {
      return;
    }

    final confirmed = await showTripReceivingConfirmationSheet(
      context: context,
      tripNumber: state.trip.number,
    );

    if (!mounted || confirmed != true) return;

    final currentState = context.read<ReceiveTripCubit>().state;

    if (currentState is! ReceiveTripSuccessState ||
        currentState.trip.id != state.trip.id ||
        currentState.acceptTripStatus ==
            AcceptTripStatus.loading) {
      return;
    }

    await context.read<ReceiveTripCubit>().acceptTrip(
      photo: File(proof.image.path),
    );
  }

  // ======= Accept Trip Error Message ======= //
  String _getAcceptTripErrorMessage(
      BuildContext context,
      String? error,
      ) {
    return switch (error) {
      'photo_missing' =>
      context.strings.trip_accept_photo_missing,

      'location_disabled' =>
      context.strings.trip_accept_location_disabled,

      'location_permission_denied' =>
      context.strings.trip_accept_location_permission_denied,

      'location_timeout' =>
      context.strings.trip_accept_location_timeout,

      'trip_accept_failed' || null || '' =>
      context.strings.trip_accept_failed,

      final message => message,
    };
  }

  // ======= Bloc Listener ======= //
  void _receiveTripListener(
      BuildContext context,
      ReceiveTripState state,
      ) {
    // ======= Accept Trip Success ======= //
    if (state is ReceiveTripAcceptedState) {
      context.pushReplacementNamed(
        RoutesNames.receiveTripSuccess,
        extra: {
          'tripNumber': state.tripNumber,
          'receivedAt': state.acceptedAt,
        },
      );
      return;
    }

    // ======= Accept Trip Failure ======= //
    if (state is ReceiveTripSuccessState &&
        state.acceptTripStatus == AcceptTripStatus.failure) {
      final message = _getAcceptTripErrorMessage(
        context,
        state.acceptTripError,
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.red0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    }
  }

  // ======= Bloc Listen When ======= //
  bool _receiveTripListenWhen(
      ReceiveTripState previous,
      ReceiveTripState current,
      ) {
    if (current is ReceiveTripAcceptedState) {
      return true;
    }

    if (current is ReceiveTripSuccessState &&
        current.acceptTripStatus == AcceptTripStatus.failure) {
      return previous is! ReceiveTripSuccessState ||
          previous.acceptTripStatus != AcceptTripStatus.failure;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.strings.confirm_receiving_van,
      ),

      // ======= Screen Body ======= //
      body: BlocConsumer<ReceiveTripCubit, ReceiveTripState>(
        listenWhen: _receiveTripListenWhen,
        listener: _receiveTripListener,
        builder: (context, state) {
          // ======= Loading ======= //
          if (state is ReceiveTripInitial ||
              state is ReceiveTripLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
            final isPending =
                state.trip.acceptance?.status.toUpperCase() ==
                    'PENDING';

            final isAccepting =
                state.acceptTripStatus ==
                    AcceptTripStatus.loading;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ======= Trip Information ======= //
                TripData(
                  trip: state.trip,
                ),

                const Gap(24),

                // ======= Loaded Items ======= //
                LoadedItemsSection(
                  state: state,
                ),

                const Gap(24),

                // ======= Receiving Proof Photo ======= //
                if (isPending) ...[
                  IgnorePointer(
                    ignoring: isAccepting,
                    child: ReceivingProofPhoto(
                      key: ValueKey(state.trip.id),
                      tripNumber: state.trip.number,
                      onPhotoApprovalChanged: (proof) {
                        if (!mounted) return;

                        setState(() {
                          _approvedProof = proof;
                        });
                      },
                    ),
                  ),
                  const Gap(24),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // ======= Confirm Receiving Bottom Bar ======= //
      bottomNavigationBar:
      BlocBuilder<ReceiveTripCubit, ReceiveTripState>(
        builder: (context, state) {
          if (state is! ReceiveTripSuccessState) {
            return const SizedBox.shrink();
          }

          final isPending =
              state.trip.acceptance?.status.toUpperCase() ==
                  'PENDING';

          if (!isPending) {
            return const SizedBox.shrink();
          }

          final isAccepting =
              state.acceptTripStatus ==
                  AcceptTripStatus.loading;

          final isProofApproved =
              _approvedProof != null &&
                  _approvedProof!.tripNumber ==
                      state.trip.number;

          return ConfirmReceivingBottomSheet(
            isProofApproved: isProofApproved,
            isLoading: isAccepting,
            onConfirm: isProofApproved && !isAccepting
                ? () => _confirmReceiving(state)
                : null,
          );
        },
      ),
    );
  }
}

// ======= Empty & Failure Widget ======= //
class _ReceiveTripMessage extends StatelessWidget {
  const _ReceiveTripMessage({
    required this.message,
    required this.onRetry,
  });

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
              message,
              textAlign: TextAlign.center,
            ),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(
                context.strings.current_trip_retry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
