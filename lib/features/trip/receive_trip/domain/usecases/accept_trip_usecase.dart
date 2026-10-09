
import 'dart:io';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';

class AcceptTripUsecase {
  final ReceiveTripRepoInterface _repo;

  AcceptTripUsecase(this._repo);


  Future<ApiResult<dynamic>> call({
    required int tripId,
    required File photo,
    required double latitude,
    required double longitude,
    required String deviceId,
    required String clientOperationId,
  }) async {
    return _repo.acceptTrip(
      tripId: tripId,
      photo: photo,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      clientOperationId: clientOperationId,
    );
  }

}
