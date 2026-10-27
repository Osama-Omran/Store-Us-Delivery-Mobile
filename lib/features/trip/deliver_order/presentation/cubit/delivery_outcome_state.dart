import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';

sealed class DeliveryOutcomeState {}

final class DeliveryOutcomeInitial extends DeliveryOutcomeState {}

final class DeliveryOutcomeLoading extends DeliveryOutcomeState {}

final class DeliveryOutcomeSuccess extends DeliveryOutcomeState {
  DeliveryOutcomeSuccess({required this.outcome, required this.response});

  final DeliveryOutcomeType outcome;
  final dynamic response;
}

final class DeliveryOutcomeFailure extends DeliveryOutcomeState {
  DeliveryOutcomeFailure(this.message);

  final String message;
}
