import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';

sealed class DeliveryReasonsState {
  const DeliveryReasonsState();
}

class DeliveryReasonsInitial extends DeliveryReasonsState {
  const DeliveryReasonsInitial();
}

class DeliveryReasonsLoading extends DeliveryReasonsState {
  const DeliveryReasonsLoading();
}

class DeliveryReasonsSuccess extends DeliveryReasonsState {
  const DeliveryReasonsSuccess(this.data);
  final DeliveryReasonsData data;
}

class DeliveryReasonsFailure extends DeliveryReasonsState {
  const DeliveryReasonsFailure(this.message);
  final String message;
}
