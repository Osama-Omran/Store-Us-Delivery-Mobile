import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/widgets/custom_app_bar.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';
import '../widgets/receive_trip_body.dart';
import '../widgets/receive_trip_confirm_bar.dart';
import '../widgets/receive_trip_listener.dart';
import '../widgets/receiving_proof_photo.dart';
import '../widgets/trip_receiving_confirmation_sheet.dart';

class ReceiveTripScreen extends StatefulWidget {
  const ReceiveTripScreen({super.key});

  @override
  State<ReceiveTripScreen> createState() => _ReceiveTripScreenState();
}

class _ReceiveTripScreenState extends State<ReceiveTripScreen> {
  ReceivingProofModel? _approvedProof;

  // ======= Confirm Receiving ======= //
  Future<void> _confirmReceiving(ReceiveTripSuccessState state) async {
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
        currentState.acceptTripStatus == AcceptTripStatus.loading) {
      return;
    }

    await context.read<ReceiveTripCubit>().acceptTrip(
      photo: File(proof.image.path),
    );
  }

  @override
  Widget build(BuildContext context) => ReceiveTripListener(
    child: Scaffold(
      appBar: CustomAppBar(title: context.strings.confirm_receiving_van),
      body: ReceiveTripBody(
        onProofChanged: (proof) {
          if (!mounted) return;
          setState(() => _approvedProof = proof);
        },
      ),
      bottomNavigationBar: ReceiveTripConfirmBar(
        approvedProof: _approvedProof,
        onConfirm: _confirmReceiving,
      ),
    ),
  );
}
