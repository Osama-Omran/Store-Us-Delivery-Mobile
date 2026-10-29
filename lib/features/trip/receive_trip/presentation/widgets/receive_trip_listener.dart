import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

import '../cubit/receive_trip_cubit.dart';
import '../cubit/receive_trip_state.dart';

class ReceiveTripListener extends StatelessWidget {
  const ReceiveTripListener({super.key, required this.child});
  final Widget child;

  // ======= Accept Trip Error Message ======= //
  String _getAcceptTripErrorMessage(BuildContext context, String? error) {
    return switch (error) {
      'photo_missing' => context.strings.trip_accept_photo_missing,

      'location_disabled' => context.strings.trip_accept_location_disabled,

      'location_permission_denied' =>
        context.strings.trip_accept_location_permission_denied,

      'location_timeout' => context.strings.trip_accept_location_timeout,

      'trip_accept_failed' || null || '' => context.strings.trip_accept_failed,

      final message => message,
    };
  }

  // ======= Bloc Listener ======= //
  Future<void> _receiveTripListener(
    BuildContext context,
    ReceiveTripState state,
  ) async {
    // ======= Accept Trip Success ======= //
    if (state is ReceiveTripAcceptedState) {
      await context.pushNamed<void>(
        RoutesNames.receiveTripSuccess,
        extra: {'tripNumber': state.tripNumber, 'receivedAt': state.acceptedAt},
      );

      if (!context.mounted) return;

      context.pop(true);
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
            content: Text(context.localizedErrorMessage(message)),
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
  Widget build(BuildContext context) =>
      BlocListener<ReceiveTripCubit, ReceiveTripState>(
        listenWhen: _receiveTripListenWhen,
        listener: _receiveTripListener,
        child: child,
      );
}
