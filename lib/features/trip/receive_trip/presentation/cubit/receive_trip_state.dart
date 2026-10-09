
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';

enum LoadedItemsStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}

enum AcceptTripStatus {
  initial,
  loading,
  failure,
}

sealed class ReceiveTripState {}

final class ReceiveTripInitial extends ReceiveTripState {}

final class ReceiveTripLoadingState extends ReceiveTripState {}

final class ReceiveTripSuccessState extends ReceiveTripState {
  final CurrentTripData trip;
  final LoadedItemsStatus loadedItemsStatus;
  final LoadedItemsData? loadedItems;
  final String? loadedItemsError;

  final AcceptTripStatus acceptTripStatus;
  final String? acceptTripError;

  ReceiveTripSuccessState(
      this.trip, {
        this.loadedItemsStatus = LoadedItemsStatus.initial,
        this.loadedItems,
        this.loadedItemsError,
        this.acceptTripStatus = AcceptTripStatus.initial,
        this.acceptTripError,
      });

  ReceiveTripSuccessState copyWith({
    LoadedItemsStatus? loadedItemsStatus,
    LoadedItemsData? loadedItems,
    String? loadedItemsError,
    AcceptTripStatus? acceptTripStatus,
    String? acceptTripError,
  }) {
    return ReceiveTripSuccessState(
      trip,
      loadedItemsStatus:
      loadedItemsStatus ?? this.loadedItemsStatus,
      loadedItems: loadedItems ?? this.loadedItems,
      loadedItemsError:
      loadedItemsError ?? this.loadedItemsError,
      acceptTripStatus:
      acceptTripStatus ?? this.acceptTripStatus,
      acceptTripError:
      acceptTripError ?? this.acceptTripError,
    );
  }
}

final class ReceiveTripAcceptedState extends ReceiveTripState {
  final String tripNumber;
  final DateTime acceptedAt;

  ReceiveTripAcceptedState({
    required this.tripNumber,
    required this.acceptedAt,
  });
}

final class ReceiveTripEmptyState extends ReceiveTripState {}

final class ReceiveTripFailureState extends ReceiveTripState {
  final String? errorMessage;

  ReceiveTripFailureState(this.errorMessage);
}
