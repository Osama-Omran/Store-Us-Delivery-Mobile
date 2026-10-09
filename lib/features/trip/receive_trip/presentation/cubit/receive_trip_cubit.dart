import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/accept_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/loaded_items_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_state.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/helpers/trip_acceptance_identifiers.dart';

class ReceiveTripCubit extends Cubit<ReceiveTripState> {
  final CurrentTripUsecase _currentTripUsecase;
  final LoadedItemsUsecase _loadedItemsUsecase;
  final AcceptTripUsecase _acceptTripUsecase;

  ReceiveTripCubit(
      this._currentTripUsecase,
      this._loadedItemsUsecase,
      this._acceptTripUsecase,
      ) : super(ReceiveTripInitial());

  static ReceiveTripCubit get(BuildContext context) =>
      BlocProvider.of<ReceiveTripCubit>(context);

  int _currentTripRequestId = 0;
  int _loadedItemsRequestId = 0;

  Future<void> getCurrentTrip() async {
    if (isClosed || state is ReceiveTripLoadingState) {
      return;
    }

    final requestId = ++_currentTripRequestId;
    ++_loadedItemsRequestId;

    emit(ReceiveTripLoadingState());

    final result = await _currentTripUsecase.call();

    if (isClosed || requestId != _currentTripRequestId) {
      return;
    }

    CurrentTripData? activeTrip;

    result.when(
      success: (response) {
        if (!response.success) {
          emit(ReceiveTripFailureState(response.message));
        } else if (response.data == null) {
          emit(ReceiveTripEmptyState());
        } else {
          activeTrip = response.data;

          emit(
            ReceiveTripSuccessState(response.data!),
          );
        }
      },
      failure: (error) {
        emit(
          ReceiveTripFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );

    if (activeTrip != null) {
      await getLoadedItems();
    }
  }

  Future<void> getLoadedItems() async {
    if (isClosed) return;

    final currentState = state;

    if (currentState is! ReceiveTripSuccessState ||
        currentState.loadedItemsStatus ==
            LoadedItemsStatus.loading) {
      return;
    }

    final trip = currentState.trip;
    final requestId = ++_loadedItemsRequestId;

    emit(
      currentState.copyWith(
        loadedItemsStatus: LoadedItemsStatus.loading,
      ),
    );

    final result = await _loadedItemsUsecase.call(
      tripId: trip.id,
    );

    if (isClosed || requestId != _loadedItemsRequestId) {
      return;
    }

    final latestState = state;

    if (latestState is! ReceiveTripSuccessState ||
        latestState.trip.id != trip.id) {
      return;
    }

    result.when(
      success: (response) {
        final data = response.data;

        if (!response.success || data == null) {
          emit(
            latestState.copyWith(
              loadedItemsStatus: LoadedItemsStatus.failure,
              loadedItemsError: response.message,
            ),
          );
          return;
        }

        if (data.trip.isNotEmpty &&
            data.trip != trip.number) {
          emit(
            latestState.copyWith(
              loadedItemsStatus: LoadedItemsStatus.failure,
            ),
          );
          return;
        }

        emit(
          latestState.copyWith(
            loadedItemsStatus: data.items.isEmpty
                ? LoadedItemsStatus.empty
                : LoadedItemsStatus.success,
            loadedItems: data,
          ),
        );
      },
      failure: (error) {
        emit(
          latestState.copyWith(
            loadedItemsStatus: LoadedItemsStatus.failure,
            loadedItemsError: error.apiErrorModel.message,
          ),
        );
      },
    );
  }


  Future<void> acceptTrip({
    required File photo,
  }) async {
    if (isClosed) return;

    final currentState = state;

    if (currentState is! ReceiveTripSuccessState ||
        currentState.acceptTripStatus == AcceptTripStatus.loading ||
        currentState.trip.acceptance?.status.toUpperCase() !=
            'PENDING') {
      return;
    }

    final trip = currentState.trip;

    emit(
      currentState.copyWith(
        acceptTripStatus: AcceptTripStatus.loading,
      ),
    );

    try {
      // 1. Check the approved photo.
      if (!await photo.exists()) {
        _emitAcceptFailure(trip.id, 'photo_missing');
        return;
      }

      // 2. Check location services.
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _emitAcceptFailure(trip.id, 'location_disabled');
        return;
      }

      // 3. Request location permission.
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _emitAcceptFailure(
          trip.id,
          'location_permission_denied',
        );
        return;
      }

      // 4. Get real GPS coordinates.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (isClosed) return;

      // 5. Get persistent identifiers.
      final deviceId =
      await TripAcceptanceIdentifiers.getDeviceId();

      final operationId =
      await TripAcceptanceIdentifiers.getOperationId(
        trip.id,
      );

      if (isClosed) return;

      // 6. Send multipart request.
      final result = await _acceptTripUsecase.call(
        tripId: trip.id,
        photo: photo,
        latitude: position.latitude,
        longitude: position.longitude,
        deviceId: deviceId,
        clientOperationId: operationId,
      );

      if (isClosed) return;

      dynamic response;
      String? requestError;

      result.when(
        success: (data) {
          response = data;
        },
        failure: (error) {
          requestError = error.apiErrorModel.message;
        },
      );

      if (requestError != null) {
        _emitAcceptFailure(trip.id, requestError!);
        return;
      }

      // 7. Check business-level failure.
      if (response is Map &&
          response['success'] == false) {
        _emitAcceptFailure(
          trip.id,
          response['message']?.toString() ??
              'trip_accept_failed',
        );
        return;
      }

      // 8. Use server acceptance time if available.
      DateTime? acceptedAt;

      if (response is Map &&
          response['data'] is Map) {
        final data = response['data'] as Map;

        acceptedAt = DateTime.tryParse(
          data['accepted_at']?.toString() ?? '',
        )?.toLocal();
      }

      // 9. Clear operation ID only after success.
      try {
        await TripAcceptanceIdentifiers.clearOperationId(
          trip.id,
        );
      } catch (_) {
        // Acceptance has already succeeded.
        // Storage cleanup must not change that result.
      }

      if (isClosed) return;

      final latestState = state;

      if (latestState is! ReceiveTripSuccessState ||
          latestState.trip.id != trip.id) {
        return;
      }

      emit(
        ReceiveTripAcceptedState(
          tripNumber: trip.number,
          acceptedAt: acceptedAt ?? DateTime.now(),
        ),
      );
    } on TimeoutException {
      _emitAcceptFailure(
        trip.id,
        'location_timeout',
      );
    } catch (error) {
      _emitAcceptFailure(
        trip.id,
        'trip_accept_failed',
      );
    }
  }

  void _emitAcceptFailure(
      int tripId,
      String message,
      ) {
    if (isClosed) return;

    final currentState = state;

    if (currentState is! ReceiveTripSuccessState ||
        currentState.trip.id != tripId) {
      return;
    }

    emit(
      currentState.copyWith(
        acceptTripStatus: AcceptTripStatus.failure,
        acceptTripError: message,
      ),
    );
  }

}
